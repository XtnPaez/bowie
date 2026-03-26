# ============================================================
# File: mod_server_simple.R
# ------------------------------------------------------------
# Description: Simple View server module for the SEIR Dashboard.
#   Handles isolated SEIR model execution and reactive alarm
#   logic for the three KPI cards.
#
#   Design contract:
#     - State is FULLY ISOLATED from the Advanced View.
#       The Simple View maintains its own reactiveValues with
#       parameters always initialised from global.R defaults.
#       No shared reactive state with mod_server.R or app.R
#       Advanced-view observers.
#     - The ODE solver is re-run when either slider changes
#       (simple_r0, simple_compliance).
#     - Alarm thresholds are committed via the "Apply thresholds"
#       button (input$apply_thresholds) into a dedicated
#       reactiveValues object (thresholds). The alarm state
#       reactives depend on thresholds$*, not directly on
#       input$thr_*. This pattern is robust against Shiny's
#       known limitation where numericInputs inside hidden
#       panels may not be reliably registered on keypress.
#     - mod_data_server() and model_seir_server() are called
#       internally under "simple_data" and "simple_seir"
#       namespace ids to avoid collision with the Advanced View.
#
#   Shared helpers (alarm_shape_svg, state_label_ui,
#   metric_value_ui, resolve_alarm_state, coalesce_num) are
#   defined in mod_helpers_simple.R, which loadSupport() sources
#   before this file (alphabetical order: h < s).
#
#   Alarm states per card:
#     "controlled" | "warning" | "critical"
#
#   PPT palette used for alarm shapes:
#     #3EA27F (sea green) | #F59342 (orange) | #752111 (dark red)
#
# Author: Cristian Paez
# Created: 2026-03-19
# Updated: 2026-03-19 - Threshold logic moved to Apply button
#   pattern to fix input registration issue with hidden panels.
# ============================================================


# ------------------------------------------------------------
# Function: mod_server_simple()
# Description:
#   Server logic for the Simple View. Maintains isolated SEIR
#   model state initialised from global.R. Runs the ODE solver
#   when sliders change. Updates alarm indicators when the
#   Apply Thresholds button is clicked.
# Parameters:
#   id               - Shiny module identifier.
#   dataset_selector - reactiveVal(character); active source key
#                      passed through for logging only.
# Returns:
#   None (side effects only: renderUI calls for the three cards).
# ------------------------------------------------------------
mod_server_simple <- function(id, dataset_selector) {
  moduleServer(id, function(input, output, session) {

    # --------------------------------------------------------
    # Log module start
    # --------------------------------------------------------
    log_message("INFO", "mod_server_simple started", .module = "SIMPLE")

    # --------------------------------------------------------
    # Toggle Settings panel via shinyjs
    # Uses shinyjs::toggle() bound to the actionButton so the
    # panel open/close state is managed by Shiny, not raw JS.
    # --------------------------------------------------------
    observeEvent(input$toggle_settings, {
      shinyjs::toggle(id = "settings_panel", anim = TRUE)
    })

    # --------------------------------------------------------
    # Threshold store
    # Holds the committed threshold values. Initialised to the
    # same defaults shown in the numericInputs. Updated only
    # when the user clicks "Apply thresholds". Alarm state
    # reactives depend on this object, not on input$thr_* directly.
    # --------------------------------------------------------
    thresholds <- reactiveValues(
      icu_warn     = 70,
      icu_crit     = 100,
      growth_warn  = 1,
      growth_crit  = 20,
      deaths_warn  = 0.05,
      deaths_crit  = 0.20
    )

    # --------------------------------------------------------
    # Apply Thresholds button
    # Reads the six numericInput values and commits them to
    # thresholds. coalesce_num() guards against NULL/NA if a
    # field is empty when the button is clicked.
    # ignoreInit = TRUE so the defaults in thresholds$* above
    # are used on first load without requiring a button click.
    # --------------------------------------------------------
    observeEvent(input$apply_thresholds, {
      thresholds$icu_warn    <- coalesce_num(input$thr_icu_warn,    70)
      thresholds$icu_crit    <- coalesce_num(input$thr_icu_crit,   100)
      thresholds$growth_warn <- coalesce_num(input$thr_growth_warn,  1)
      thresholds$growth_crit <- coalesce_num(input$thr_growth_crit, 20)
      thresholds$deaths_warn <- coalesce_num(input$thr_deaths_warn,  0.05)
      thresholds$deaths_crit <- coalesce_num(input$thr_deaths_crit,  0.20)

      log_message("INFO", "Alarm thresholds updated", .module = "SIMPLE",
                  icu_warn    = thresholds$icu_warn,
                  icu_crit    = thresholds$icu_crit,
                  growth_warn = thresholds$growth_warn,
                  growth_crit = thresholds$growth_crit,
                  deaths_warn = thresholds$deaths_warn,
                  deaths_crit = thresholds$deaths_crit)
    }, ignoreInit = TRUE)

    # --------------------------------------------------------
    # Isolated parameter store
    # Always initialised from global.R constants.
    # Sliders in the Simple View write ONLY to these values.
    # The Advanced View has no access to this reactiveValues.
    # --------------------------------------------------------
    simple_params <- reactiveValues(
      r0_value         = INITIAL_R0,
      compliance_level = 50,

      # Fixed parameters -- not exposed in Simple View sliders
      incubation_period = INITIAL_INCUBATION_PERIOD,
      infectious_period = INITIAL_INFECTIOUS_PERIOD,
      ifr_value         = INITIAL_IFR * 100,    # percent [0, 100]

      icu_capacity            = INITIAL_ICU_CAPACITY,
      icu_admission_rate      = INITIAL_ICU_RATE * 100,    # percent
      ventilator_availability = INITIAL_VENTILATOR_AVAILABILITY,
      ventilator_usage_rate   = INITIAL_VENTILATOR_RATE * 100, # percent
      healthcare_staff        = INITIAL_HEALTHCARE_STAFF,

      # phased_mitigation: compliance slider has meaningful effect
      policy_type = "phased_mitigation",

      start_date  = START_DATE,
      end_date    = END_DATE,
      population  = POPULATION_ARGENTINA,

      trigger_sim = 0L
    )

    # --------------------------------------------------------
    # Slider observers -- update isolated params and trigger sim.
    # ignoreInit = FALSE so the initial slider value fires
    # immediately on load and the first simulation runs.
    # --------------------------------------------------------
    observeEvent(input$simple_r0, {
      req(!is.null(input$simple_r0))
      simple_params$r0_value    <- input$simple_r0
      simple_params$trigger_sim <- simple_params$trigger_sim + 1L
      log_message("DEBUG",
                  paste("Simple View R0 changed to:", input$simple_r0),
                  .module = "SIMPLE")
    }, ignoreInit = FALSE)

    observeEvent(input$simple_compliance, {
      req(!is.null(input$simple_compliance))
      simple_params$compliance_level <- input$simple_compliance
      simple_params$trigger_sim      <- simple_params$trigger_sim + 1L
    }, ignoreInit = FALSE)

    # --------------------------------------------------------
    # Data module -- generates raw initial state for the ODE.
    # Uses "simple_data" namespace to avoid collision with the
    # Advanced View data module ("data_sim").
    # --------------------------------------------------------
    simple_raw_data <- mod_data_server(
      "simple_data",
      params = reactive({
        list(
          start_date  = simple_params$start_date,
          end_date    = simple_params$end_date,
          population  = simple_params$population,
          trigger_sim = simple_params$trigger_sim
        )
      })
    )

    # --------------------------------------------------------
    # SEIR model -- runs under "simple_seir" namespace.
    # Receives only the isolated simple_params.
    # --------------------------------------------------------
    simple_model_output <- model_seir_server(
      "simple_seir",
      input_params = reactive({
        list(
          r0_value          = simple_params$r0_value,
          incubation_period = simple_params$incubation_period,
          infectious_period = simple_params$infectious_period,
          ifr_value         = simple_params$ifr_value,

          icu_capacity            = simple_params$icu_capacity,
          ventilator_availability = simple_params$ventilator_availability,
          healthcare_staff        = simple_params$healthcare_staff,

          icu_admission_rate    = simple_params$icu_admission_rate,
          ventilator_usage_rate = simple_params$ventilator_usage_rate,

          policy_type      = simple_params$policy_type,
          compliance_level = simple_params$compliance_level,

          start_date  = simple_params$start_date,
          end_date    = simple_params$end_date,
          population  = simple_params$population,

          trigger_sim = simple_params$trigger_sim
        )
      }),
      raw_data_df = simple_raw_data
    )

    # --------------------------------------------------------
    # Computed KPI metrics
    # Kept as separate reactive expressions so threshold changes
    # re-evaluate alarm states without re-running the ODE solver.
    # --------------------------------------------------------

    # --- KPI 1: Weekly growth rate of I ---
    # Compares the mean of the infectious compartment (I) over
    # the final 7 simulation days to the preceding 7 days.
    # Returns a percentage change; negative values = declining.
    kpi_growth_rate <- reactive({
      df <- simple_model_output()
      req(df, nrow(df) >= 14)

      n     <- nrow(df)
      last7 <- mean(df$I[(n - 6):n],        na.rm = TRUE)
      prev7 <- mean(df$I[(n - 13):(n - 7)], na.rm = TRUE)

      if (is.na(prev7) || prev7 == 0) return(0)
      ((last7 - prev7) / prev7) * 100
    })

    # --- KPI 2: Peak daily ICU admissions as % of capacity ---
    # Uses the maximum value of ICU_Daily_Demand across the full
    # simulation horizon:
    #   ICU_Daily_Demand[t] = I[t] * icu_admission_rate
    #
    # Display logic (capped scale):
    #   - If peak demand <= capacity (<=100%): show exact percentage.
    #   - If peak demand > capacity (>100%):   show "> 100%" and
    #     force "critical" state regardless of threshold settings.
    #
    # Rationale: under high-transmission scenarios the peak of
    # ICU_Daily_Demand can reach millions of admissions (e.g.
    # R0=2.5 produces I_peak ~3.4M → ICU_peak ~466K vs 6K capacity
    # = 7772%). The difference between 500% and 7000% does not
    # change any decision — the system has collapsed in both cases.
    # Capping at "> 100%" keeps the card readable and honest.
    #
    # The reactive returns the raw numeric value for alarm
    # classification. The renderUI applies the display cap.
    kpi_icu_pct <- reactive({
      df <- simple_model_output()
      req(df)

      peak_daily_demand <- max(df$ICU_Daily_Demand, na.rm = TRUE)
      cap               <- simple_params$icu_capacity
      if (is.na(cap) || cap == 0) return(NA_real_)
      (peak_daily_demand / cap) * 100
    })

    # --- KPI 3: Cumulative deaths on the final simulation day as % of population ---
    kpi_deaths_pct <- reactive({
      df <- simple_model_output()
      req(df)

      last_deaths <- df$Cumulative_Deaths[nrow(df)]
      pop         <- simple_params$population
      if (is.na(pop) || pop == 0) return(NA_real_)
      (last_deaths / pop) * 100
    })

    # --------------------------------------------------------
    # Alarm state computations
    # Each reactive reads from thresholds$* (committed values),
    # not from input$thr_* directly. Updates fire when either
    # the KPI value changes (slider moved) or the Apply button
    # is clicked (thresholds$* updated).
    # --------------------------------------------------------

    alarm_trajectory <- reactive({
      resolve_alarm_state(
        value = kpi_growth_rate(),
        warn  = thresholds$growth_warn,
        crit  = thresholds$growth_crit
      )
    })

    alarm_icu <- reactive({
      resolve_alarm_state(
        value = kpi_icu_pct(),
        warn  = thresholds$icu_warn,
        crit  = thresholds$icu_crit
      )
    })

    alarm_deaths <- reactive({
      resolve_alarm_state(
        value = kpi_deaths_pct(),
        warn  = thresholds$deaths_warn,
        crit  = thresholds$deaths_crit
      )
    })

    # --------------------------------------------------------
    # Rendered outputs -- Card 1: Epidemic Trajectory
    # --------------------------------------------------------
    output$shape_trajectory <- renderUI({
      alarm_shape_svg(alarm_trajectory(), size = 64)
    })

    output$label_trajectory <- renderUI({
      state_label_ui(alarm_trajectory())
    })

    output$value_trajectory <- renderUI({
      val <- kpi_growth_rate()
      if (is.na(val) || !is.finite(val)) {
        metric_value_ui("N/A", "weekly growth rate of I")
      } else {
        formatted <- paste0(ifelse(val >= 0, "+", ""), round(val, 2), "%")
        metric_value_ui(formatted, "weekly growth rate of I")
      }
    })

    # --------------------------------------------------------
    # Rendered outputs -- Card 2: ICU Pressure
    # --------------------------------------------------------
    output$shape_icu <- renderUI({
      alarm_shape_svg(alarm_icu(), size = 64)
    })

    output$label_icu <- renderUI({
      state_label_ui(alarm_icu())
    })

    output$value_icu <- renderUI({
      val <- kpi_icu_pct()
      if (is.na(val) || !is.finite(val)) {
        metric_value_ui("N/A", "peak daily ICU admissions as % of capacity")
      } else if (val > 100) {
        # Cap display at "> 100%" -- exact values above capacity are not
        # actionable for a decision-maker; "collapsed" is the signal.
        metric_value_ui("> 100%", "peak daily ICU admissions as % of capacity")
      } else {
        metric_value_ui(paste0(round(val, 2), "%"),
                        "peak daily ICU admissions as % of capacity")
      }
    })

    # --------------------------------------------------------
    # Rendered outputs -- Card 3: Cumulative Impact
    # --------------------------------------------------------
    output$shape_deaths <- renderUI({
      alarm_shape_svg(alarm_deaths(), size = 64)
    })

    output$label_deaths <- renderUI({
      state_label_ui(alarm_deaths())
    })

    output$value_deaths <- renderUI({
      val <- kpi_deaths_pct()
      if (is.na(val) || !is.finite(val)) {
        metric_value_ui("N/A", "cumulative deaths as % of population (final day)")
      } else {
        metric_value_ui(paste0(round(val, 2), "%"),
                        "cumulative deaths as % of population (final day)")
      }
    })

    log_message("INFO", "mod_server_simple observers registered",
                .module = "SIMPLE")
  })
}
