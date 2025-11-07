# ============================================================
# File: mod_server.R
# ------------------------------------------------------------
# Description: Defines the main server logic for the Shiny app.
# Orchestrates data, model, and visualisation modules to build
# a complete SEIR simulation workflow.
# Author: Cristian Paez
# Created: 2025-11-07
# ============================================================

# ------------------------------------------------------------
# Function: mod_server()
# Description:
#   Main server module integrating the data, SEIR model, and
#   visualisation layers. Manages parameter reactivity,
#   theme switching, and dataset selection.
# Parameters:
#   id – Shiny module identifier.
#   dataset_selector – reactive value specifying the data source.
# Returns:
#   List containing model outputs and capacity reactives.
# ------------------------------------------------------------
mod_server <- function(id, dataset_selector) {
  moduleServer(id, function(input, output, session) {
    
    log_message("INFO",
                paste0("mod_server started with dataset: ",
                       dataset_selector()),
                .module = "SERVER")
    
    # --------------------------------------------------------
    # --- Theme selector: light/dark mode ---
    # --------------------------------------------------------
    observeEvent(input$theme_selector, {
      shinyjs::addClass(selector = "body", class = "fade-transition")
      shinyjs::runjs("document.body.style.opacity = 0.5;")
      
      new_theme <- bs_theme(version = 5, bootswatch = input$theme_selector)
      session$setCurrentTheme(new_theme)
      
      shinyjs::runjs("document.body.style.opacity = 1;")
    })
    
    # --------------------------------------------------------
    # --- Helper: update reactive parameter list ---
    # --------------------------------------------------------
    update_app_params <- function(input, app_params) {
      app_params$r0_value <- input$r0_value
      app_params$incubation_period <- input$incubation_period
      app_params$infectious_period <- input$infectious_period
      app_params$ifr_value <- input$ifr_value
      app_params$icu_capacity <- input$icu_capacity
      app_params$ventilator_availability <- input$ventilator_availability
      app_params$healthcare_staff <- input$healthcare_staff
      app_params$icu_admission_rate <- input$icu_admission_rate
      app_params$ventilator_usage_rate <- input$ventilator_usage_rate
      app_params$policy_type <- input$policy_type
      app_params$compliance_level <- input$compliance_level
    }
    
    # --------------------------------------------------------
    # --- ReactiveValues: global simulation parameters ---
    # --------------------------------------------------------
    app_params <- reactiveValues(
      r0_value = INITIAL_R0,
      incubation_period = INITIAL_INCUBATION_PERIOD,
      infectious_period = INITIAL_INFECTIOUS_PERIOD,
      ifr_value = INITIAL_IFR * 100,
      icu_capacity = INITIAL_ICU_CAPACITY,
      ventilator_availability = INITIAL_VENTILATOR_AVAILABILITY,
      healthcare_staff = INITIAL_HEALTHCARE_STAFF,
      icu_admission_rate = INITIAL_ICU_RATE * 100,
      ventilator_usage_rate = INITIAL_VENTILATOR_RATE * 100,
      policy_type = "no_intervention",
      compliance_level = 50,
      start_date = START_DATE,
      end_date = END_DATE,
      population = POPULATION_ARGENTINA,
      trigger_sim = 0
    )
    
    # --------------------------------------------------------
    # --- Data loading based on user selection ---
    # --------------------------------------------------------
    observe({
      req(dataset_selector())
      
      if (dataset_selector() == "iecs") {
        log_message("INFO", "Loading IECS dataset...", .module = "SERVER")
        load("data/iecs_data.RData")
        
        # Overwrite parameters using IECS data
        app_params$r0_value <- iecs_data$parametros$R0
        app_params$incubation_period <- iecs_data$parametros$incubation_period
        app_params$infectious_period <- iecs_data$parametros$infectious_period
        app_params$ifr_value <- iecs_data$parametros$IFR * 100
        
        app_params$icu_capacity <- iecs_data$recursos$INITIAL_ICU_CAPACITY
        app_params$ventilator_availability <- iecs_data$recursos$INITIAL_VENTILATOR_AVAILABILITY
        app_params$healthcare_staff <- iecs_data$recursos$INICIAL_HEALTHCARE_STAFF
        app_params$icu_admission_rate <- iecs_data$recursos$INITIAL_ICU_RATE * 100
        app_params$ventilator_usage_rate <- iecs_data$recursos$INITIAL_VENTILATOR_RATE * 100
        
        app_params$population <- iecs_data$poblacion
        
        log_message("INFO", "IECS data loaded successfully", .module = "SERVER")
      } else {
        log_message("INFO", "Using simulated mock dataset", .module = "SERVER")
      }
      
      # Trigger first simulation
      app_params$trigger_sim <- 1
    })
    
    # --------------------------------------------------------
    # --- Update parameters on input change ---
    # --------------------------------------------------------
    observe({
      update_app_params(input, app_params)
    })
    
    # --------------------------------------------------------
    # --- Manual simulation trigger (Run Simulation button) ---
    # --------------------------------------------------------
    observeEvent(input$run_simulation, {
      app_params$trigger_sim <- app_params$trigger_sim + 1
      log_message("INFO", "Simulation manually triggered",
                  .module = "SERVER")
    })
    
    # --------------------------------------------------------
    # --- Data Module: generate or simulate initial dataset ---
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
    # --- Model Module: run SEIR model simulation ---
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
    # --- Render data preview table ---
    # --------------------------------------------------------
    output$simulated_data_table <- renderTable({
      req(seir_model_output())
      
      data_for_table <- seir_model_output()
      data_for_table$date <- format(data_for_table$date, "%d-%m-%Y")
      
      data_for_table <- data_for_table %>%
        select(
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
        mutate(
          across(
            where(is.numeric),
            ~format(round(., 2),
                    big.mark = ".",
                    decimal.mark = ",",
                    nsmall = 2)
          )
        )
      
      head(data_for_table, 10)
    },
    striped = TRUE,
    hover = TRUE,
    bordered = TRUE)
    
    # --------------------------------------------------------
    # --- Return reactive model data for app.R integration ---
    # --------------------------------------------------------
    return(list(
      model_data = seir_model_output,
      icu_capacity = reactive(input$icu_capacity),
      ventilator_availability = reactive(input$ventilator_availability)
    ))
  })
}
