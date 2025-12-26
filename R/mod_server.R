# ============================================================
# File: R/mod_server.R
# ------------------------------------------------------------
# Description:
#   Main server module for the Shiny application. Integrates:
#     - Dataset selection (mock / IECS)
#     - Parameter management and validation
#     - SEIR model execution
#     - Outputs wiring for downstream visualisation modules
#
# Notes (design decisions):
#   - Internal contract: ifr_value is ALWAYS a percentage in [0, 100].
#   - Simulation trigger: trigger_sim is incremented ONLY on:
#       * dataset change
#       * explicit user action (Run Simulation)
#       * user parameter edits (field-level events)
#     This avoids reactive feedback loops.
#   - IECS loading must be performed via load_iecs_data() (data_interface.R).
#
# Author: Cristian Paez
# Created: 2025-11-07
# ============================================================

mod_server <- function(id, dataset_selector) {
  moduleServer(id, function(input, output, session) {
    
    # --------------------------------------------------------
    # Local helpers
    # --------------------------------------------------------
    
    # Convert IFR to a percentage in [0, 100] with strict rules.
    # - If IFR <= 1  : treat as proportion and convert to percent.
    # - If IFR <= 100: treat as percent already.
    # - Otherwise    : fail explicitly (wrong scale).
    normalise_ifr_to_pct <- function(ifr_raw) {
      if (!is.numeric(ifr_raw) || length(ifr_raw) != 1 || is.na(ifr_raw)) {
        stop("IECS invalid: IFR must be a non-NA scalar numeric value.")
      }
      
      if (ifr_raw <= 1) {
        return(ifr_raw * 100)
      }
      
      if (ifr_raw <= 100) {
        return(ifr_raw)
      }
      
      stop(sprintf(
        "IECS invalid: IFR out of scale (value=%s). Expected proportion (<=1) or percent (<=100).",
        as.character(ifr_raw)
      ))
    }
    
    # Apply a full parameter refresh from IECS data into app_params.
    # isolate() is used to avoid intermediate reactive states.
    apply_iecs_to_params <- function(iecs_data, app_params) {
      ifr_pct <- normalise_ifr_to_pct(iecs_data$parametros$IFR)
      
      isolate({
        app_params$r0_value <- iecs_data$parametros$R0
        app_params$incubation_period <- iecs_data$parametros$incubation_period
        app_params$infectious_period <- iecs_data$parametros$infectious_period
        app_params$ifr_value <- ifr_pct
        
        app_params$icu_capacity <- iecs_data$recursos$INITIAL_ICU_CAPACITY
        app_params$ventilator_availability <- iecs_data$recursos$INITIAL_VENTILATOR_AVAILABILITY
        app_params$healthcare_staff <- iecs_data$recursos$INITIAL_HEALTHCARE_STAFF
        
        # Rates are stored internally as percentages for UI + validation consistency.
        app_params$icu_admission_rate <- iecs_data$recursos$INITIAL_ICU_RATE * 100
        app_params$ventilator_usage_rate <- iecs_data$recursos$INITIAL_VENTILATOR_RATE * 100
        
        app_params$population <- iecs_data$poblacion
      })
    }
    
    # --------------------------------------------------------
    # Logging on module start (best-effort)
    # --------------------------------------------------------
    log_message(
      "INFO",
      paste0("mod_server started; dataset_selector() = ", dataset_selector()),
      .module = "SERVER"
    )
    
    # --------------------------------------------------------
    # Theme selector: light/dark mode
    # --------------------------------------------------------
    observeEvent(input$theme_selector, {
      shinyjs::addClass(selector = "body", class = "fade-transition")
      shinyjs::runjs("document.body.style.opacity = 0.5;")
      
      new_theme <- bslib::bs_theme(version = 5, bootswatch = input$theme_selector)
      session$setCurrentTheme(new_theme)
      
      shinyjs::runjs("document.body.style.opacity = 1;")
    }, ignoreInit = TRUE)
    
    # --------------------------------------------------------
    # ReactiveValues: global simulation parameters
    # --------------------------------------------------------
    app_params <- reactiveValues(
      r0_value = INITIAL_R0,
      incubation_period = INITIAL_INCUBATION_PERIOD,
      infectious_period = INITIAL_INFECTIOUS_PERIOD,
      
      # Internal contract: percent in [0, 100]
      ifr_value = INITIAL_IFR * 100,
      
      icu_capacity = INITIAL_ICU_CAPACITY,
      ventilator_availability = INITIAL_VENTILATOR_AVAILABILITY,
      healthcare_staff = INITIAL_HEALTHCARE_STAFF,
      
      # Internal contract: percent in [0, 100]
      icu_admission_rate = INITIAL_ICU_RATE * 100,
      ventilator_usage_rate = INITIAL_VENTILATOR_RATE * 100,
      
      policy_type = "no_intervention",
      compliance_level = 50,
      
      start_date = START_DATE,
      end_date = END_DATE,
      population = POPULATION_ARGENTINA,
      
      # Integer counter used as a simulation trigger
      trigger_sim = 0L
    )
    
    # --------------------------------------------------------
    # Dataset loading based on user selection (NO reactive loop)
    # --------------------------------------------------------
    observeEvent(dataset_selector(), {
      req(dataset_selector())
      
      if (dataset_selector() == "iecs") {
        log_message("INFO", "Loading IECS dataset...", .module = "SERVER")
        
        # load_iecs_data() must exist (from R/data_interface.R)
        iecs_data <- load_iecs_data()
        
        # Push IECS parameters into internal contract
        apply_iecs_to_params(iecs_data, app_params)
        
        log_message("INFO", "IECS data loaded successfully", .module = "SERVER")
      } else {
        log_message("INFO", "Using simulated mock dataset", .module = "SERVER")
      }
      
      # Trigger simulation after dataset selection is applied.
      app_params$trigger_sim <- app_params$trigger_sim + 1L
    }, ignoreInit = FALSE)
    
    # --------------------------------------------------------
    # Parameter updates (field-level observers, no global observe())
    # --------------------------------------------------------
    
    observeEvent(input$r0_value, {
      app_params$r0_value <- input$r0_value
      app_params$trigger_sim <- app_params$trigger_sim + 1L
    }, ignoreInit = TRUE)
    
    observeEvent(input$incubation_period, {
      app_params$incubation_period <- input$incubation_period
      app_params$trigger_sim <- app_params$trigger_sim + 1L
    }, ignoreInit = TRUE)
    
    observeEvent(input$infectious_period, {
      app_params$infectious_period <- input$infectious_period
      app_params$trigger_sim <- app_params$trigger_sim + 1L
    }, ignoreInit = TRUE)
    
    observeEvent(input$ifr_value, {
      # Enforce internal contract (percent) and clamp validation at source.
      if (!is.null(input$ifr_value) && is.numeric(input$ifr_value)) {
        if (input$ifr_value < 0 || input$ifr_value > 100) {
          stop("'ifr_value' must be within range [0, 100]")
        }
      }
      app_params$ifr_value <- input$ifr_value
      app_params$trigger_sim <- app_params$trigger_sim + 1L
    }, ignoreInit = TRUE)
    
    observeEvent(input$icu_capacity, {
      app_params$icu_capacity <- input$icu_capacity
      app_params$trigger_sim <- app_params$trigger_sim + 1L
    }, ignoreInit = TRUE)
    
    observeEvent(input$ventilator_availability, {
      app_params$ventilator_availability <- input$ventilator_availability
      app_params$trigger_sim <- app_params$trigger_sim + 1L
    }, ignoreInit = TRUE)
    
    observeEvent(input$healthcare_staff, {
      app_params$healthcare_staff <- input$healthcare_staff
      app_params$trigger_sim <- app_params$trigger_sim + 1L
    }, ignoreInit = TRUE)
    
    observeEvent(input$icu_admission_rate, {
      app_params$icu_admission_rate <- input$icu_admission_rate
      app_params$trigger_sim <- app_params$trigger_sim + 1L
    }, ignoreInit = TRUE)
    
    observeEvent(input$ventilator_usage_rate, {
      app_params$ventilator_usage_rate <- input$ventilator_usage_rate
      app_params$trigger_sim <- app_params$trigger_sim + 1L
    }, ignoreInit = TRUE)
    
    observeEvent(input$policy_type, {
      app_params$policy_type <- input$policy_type
      app_params$trigger_sim <- app_params$trigger_sim + 1L
    }, ignoreInit = TRUE)
    
    observeEvent(input$compliance_level, {
      app_params$compliance_level <- input$compliance_level
      app_params$trigger_sim <- app_params$trigger_sim + 1L
    }, ignoreInit = TRUE)
    
    observeEvent(input$start_date, {
      app_params$start_date <- input$start_date
      app_params$trigger_sim <- app_params$trigger_sim + 1L
    }, ignoreInit = TRUE)
    
    observeEvent(input$end_date, {
      app_params$end_date <- input$end_date
      app_params$trigger_sim <- app_params$trigger_sim + 1L
    }, ignoreInit = TRUE)
    
    observeEvent(input$population, {
      app_params$population <- input$population
      app_params$trigger_sim <- app_params$trigger_sim + 1L
    }, ignoreInit = TRUE)
    
    # --------------------------------------------------------
    # Manual simulation trigger (Run Simulation button)
    # --------------------------------------------------------
    observeEvent(input$run_simulation, {
      app_params$trigger_sim <- app_params$trigger_sim + 1L
      log_message("INFO", "Simulation manually triggered", .module = "SERVER")
    }, ignoreInit = TRUE)
    
    # --------------------------------------------------------
    # Data Module: generate/simulate initial dataset
    # --------------------------------------------------------
    simulated_raw_data <- mod_data_server(
      "data_sim",
      params = reactive({
        list(
          start_date = app_params$start_date,
          end_date = app_params$end_date,
          population = app_params$population,
          trigger_sim = app_params$trigger_sim
        )
      })
    )
    
    # --------------------------------------------------------
    # Model Module: run SEIR simulation
    # --------------------------------------------------------
    seir_model_output <- model_seir_server(
      "seir_model",
      input_params = reactive({
        list(
          r0_value = app_params$r0_value,
          incubation_period = app_params$incubation_period,
          infectious_period = app_params$infectious_period,
          ifr_value = app_params$ifr_value,
          
          icu_capacity = app_params$icu_capacity,
          ventilator_availability = app_params$ventilator_availability,
          healthcare_staff = app_params$healthcare_staff,
          
          icu_admission_rate = app_params$icu_admission_rate,
          ventilator_usage_rate = app_params$ventilator_usage_rate,
          
          policy_type = app_params$policy_type,
          compliance_level = app_params$compliance_level,
          
          start_date = app_params$start_date,
          end_date = app_params$end_date,
          population = app_params$population,
          
          trigger_sim = app_params$trigger_sim
        )
      }),
      raw_data_df = simulated_raw_data
    )
    
    # --------------------------------------------------------
    # Render data preview table (top 10 rows)
    # --------------------------------------------------------
    output$simulated_data_table <- renderTable({
      req(seir_model_output())
      
      data_for_table <- seir_model_output()
      data_for_table$date <- format(data_for_table$date, "%d-%m-%Y")
      
      data_for_table <- data_for_table %>%
        dplyr::select(
          Fecha = date,
          Susceptibles = S,
          Expuestos = E,
          Infectados = I,
          Recuperados = R,
          `Casos Acumulados` = Cumulative_Cases,
          `Muertes Acumuladas` = Cumulative_Deaths,
          `Ocupación UCI Simulada` = ICU_Occupancy_Sim,
          `Uso de Ventiladores Sim.` = Vent_Usage_Sim
        ) %>%
        dplyr::mutate(
          dplyr::across(
            where(is.numeric),
            ~format(round(., 2),
                    big.mark = ".",
                    decimal.mark = ",",
                    nsmall = 2)
          )
        )
      
      head(data_for_table, 10)
    }, striped = TRUE, hover = TRUE, bordered = TRUE)
    
    # --------------------------------------------------------
    # Return outputs for integration
    # --------------------------------------------------------
    return(list(
      model_data = seir_model_output,
      icu_capacity = reactive(app_params$icu_capacity),
      ventilator_availability = reactive(app_params$ventilator_availability)
    ))
  })
}
