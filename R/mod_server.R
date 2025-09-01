#mod_server.R

# Este archivo define la lógica del servidor de la aplicación Shiny,
# orquestando los módulos de datos, modelo y visualización.

# Función principal para la lógica del servidor
server <- function(input, output, session) {
  #bs_themer() #Selector de temas
  
  ##Selector de tema oscuro/claro
  observeEvent(input$theme_selector, {
    shinyjs::addClass(selector = "body", class = "fade-transition")
    shinyjs::runjs("document.body.style.opacity = 0.5;")
    
    new_theme <- bs_theme(version = 5, bootswatch = input$theme_selector)
    session$setCurrentTheme(new_theme)
    
    shinyjs::runjs("document.body.style.opacity = 1;")
  })
  
  
  #' Función que actualiza los parámetros reactivos de la app a partir de los inputs de la UI
  #'
  #' Toma los valores actuales de los inputs y los asigna
  #' a los campos correspondientes en el objeto `app_params`.
  #' En futuras versiones puede migrarse a un módulo de helpers.
  #'
  #' @param input Objeto `input` de Shiny
  #' @param app_params Objeto `reactiveValues` que contiene los parámetros de la app
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
  
  # ReactiveValues para pasar parámetros y triggers entre módulos
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
    trigger_sim = 0 # Usado para activar la simulación cuando se presiona el botón
  )
  
  
  # Actualizar los parámetros reactivos cuando cambian los inputs de la UI
  # Observar los inputs de la UI y actualizar app_params. Esto asegura que app_params
  # siempre refleje los valores más recientes de los inputs.
  observe({
    update_app_params(input, app_params)
  })
  
  # Trigger la simulación cuando se presiona el botón "Ejecutar Simulación"
  observeEvent(input$run_simulation, {
    app_params$trigger_sim <- app_params$trigger_sim + 1
  })
  
  
  # Llamar al módulo de datos para simular la ingesta de datos
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
  
  # Llamar al módulo del modelo para ejecutar la simulación SEIR
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
        policy_type = app_params$policy_type, # Aunque no se usa en este MVP, se pasa
        compliance_level = app_params$compliance_level, # Idem
        start_date = app_params$start_date,
        end_date = app_params$end_date,
        population = app_params$population,
        trigger_sim = app_params$trigger_sim
      )
    }),
    raw_data_df = simulated_raw_data # Pasar los datos base del módulo de datos
  )
  
  # Llamar al módulo de visualización para renderizar los gráficos
  # Usar el mismo ID que se pasa a ui_main y pasar también los inputs de capacidad directamente
  viz_plot_server(
    "main_viz",
    model_data = seir_model_output,
    icu_capacity_input = reactive(input$icu_capacity), # Pasar input$icu_capacity como reactive()
    ventilator_availability_input = reactive(input$ventilator_availability) # Pasar input$ventilator_availability como reactive()
  )
  
  # Renderizar la tabla de datos simulados en la pestaña "Datos Simulados"
  output$simulated_data_table <- renderTable({
    req(seir_model_output())
    
    # Obtener los datos del modelo
    data_for_table <- seir_model_output()
    
    # 1. Modificar el formato de la columna 'date'
    data_for_table$date <- format(data_for_table$date, "%d-%m-%Y") # Formato DD-MM-YYYY
    
    # 2. Modificar los nombres de las columnas
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
      # 3. Aplicar formato regional a los valores numéricos
      mutate(
        across(
          where(is.numeric),
          ~format(round(., 2), big.mark = ".", decimal.mark = ",", nsmall = 2)
        )
      )
    
    # Mostrar un resumen o las primeras/últimas filas para no abrumar
    head(data_for_table, 10)
  },
  # Opciones adicionales para renderTable
  striped = TRUE, # Añade un estilo de filas alternadas
  hover = TRUE,   # Resalta la fila al pasar el ratón por encima
  bordered = TRUE # Añade bordes a las celdas
  )
}
