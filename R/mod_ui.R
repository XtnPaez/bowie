# ui_module.R
# Este archivo define la interfaz de usuario (UI) para el tablero.

# Función para definir los parámetros del modelo SEIR en la UI
ui_seir_params <- function() {
  div(
    h4("Parámetros del Modelo Epidemiológico"),
    sliderInput(
      inputId = "r0_value",
      label = HTML("Número Reproductivo Básico (R<sub>0</sub>)"),
      min = 0.5, max = 5.0, value = INITIAL_R0, step = 0.1
    ),
    sliderInput(
      inputId = "incubation_period",
      label = "Período de Incubación (días)",
      min = 1, max = 14, value = INITIAL_INCUBATION_PERIOD, step = 1
    ),
    sliderInput(
      inputId = "infectious_period",
      label = "Período Infeccioso (días)",
      min = 1, max = 21, value = INITIAL_INFECTIOUS_PERIOD, step = 1
    ),
    sliderInput(
      inputId = "ifr_value",
      label = "Tasa de Letalidad por Infección (IFR - %)",
      min = 0.01, max = 5.0, value = INITIAL_IFR * 100, step = 0.01
    )
  )
}

# Función para definir los parámetros de políticas públicas en la UI
ui_policy_params <- function() {
  div(
    h4("Parámetros de Políticas Públicas"),
    selectInput(
      inputId = "policy_type",
      label = "Tipo de Intervención",
      choices = c(
        "Sin Intervención" = "no_intervention",
        "Mitigación por Fases" = "phased_mitigation",
        "Intervención Intermitente" = "intermittent",
        "Medidas Gatilladas por Ocupación UTI" = "icu_triggered"
      ),
      selected = "no_intervention"
    ),
    sliderInput(
      inputId = "compliance_level",
      label = "Nivel de Cumplimiento (%)",
      min = 0, max = 100, value = 50, step = 5
    )
  )
}

# Función para definir los parámetros de recursos críticos en la UI
ui_resource_params <- function() {
  div(
    h4("Parámetros de Recursos Críticos"),
    numericInput(
      inputId = "icu_capacity",
      label = "Capacidad de Camas UCI",
      value = INITIAL_ICU_CAPACITY, min = 0
    ),
    numericInput(
      inputId = "ventilator_availability",
      label = "Disponibilidad de Respiradores",
      value = INITIAL_VENTILATOR_AVAILABILITY, min = 0
    ),
    numericInput(
      inputId = "healthcare_staff",
      label = "Personal de Salud Disponible",
      value = INITIAL_HEALTHCARE_STAFF, min = 0
    ),
    sliderInput(
      inputId = "icu_admission_rate",
      label = "Tasa de Admisión a UCI (%)",
      min = 0.1, max = 30.0, value = INITIAL_ICU_RATE * 100, step = 0.1
    ),
    sliderInput(
      inputId = "ventilator_usage_rate",
      label = "Tasa de Uso de Respiradores (%)",
      min = 0.1, max = 10.0, value = INITIAL_VENTILATOR_RATE * 100, step = 0.1
    )
  )
}

# Función principal para la interfaz de usuario
# Acepta un 'viz_id' para el namespacing de los outputs de visualización
ui_main <- function(viz_id) {
  ns_viz <- NS(viz_id) # Crear el namespace para los outputs de visualización
  fluidPage(
    useShinyjs(),
    
    theme = bs_theme(
      version = 5,
      bootswatch = "flatly"  
    ),
    
    tags$head(
      tags$style(HTML("
    .fade-transition {
      transition: opacity 0.5s ease-in-out;
    }
  "))
    ),
    
    
    titlePanel("Prototipo Tablero Epidemiológico SEIR - Argentina"),
    
    
    column(12, 
           div(style = "display: flex; align-items: center; justify-content: flex-start; gap: 10px; padding: 10px;",
               selectInput("theme_selector", NULL,
                           choices = c("Claro" = "flatly", "Oscuro" = "darkly"),
                           selected = "flatly",
                           width = "100px"
               ) %>% 
                 tagAppendAttributes(style = "text-align: left; margin-left: 0;"),
               uiOutput("tema_icono")
           )
    ),
    
    sidebarLayout(
      sidebarPanel(
        # Controles del modelo
        wellPanel(ui_seir_params()),
        hr(), # Separador
        # Controles de políticas
        wellPanel(ui_policy_params()),
        hr(),
        # Controles de recursos
        wellPanel(ui_resource_params()),
        hr(),
        actionButton("run_simulation", "Ejecutar Simulación")
      ),
      mainPanel(
        tabsetPanel(
          tabPanel(
            "Curvas Epidemiológicas",
            h3("Simulación del Modelo SEIR (S, E, I, R)"),
            plotOutput(ns_viz("seir_plot")), # Usar el namespace aquí
            h3("Casos y Muertes Simuladas"),
            plotOutput(ns_viz("cases_deaths_plot")) # Usar el namespace aquí
          ),
          tabPanel(
            "Presión sobre Recursos",
            h3("Ocupación de Recursos Críticos"),
            plotOutput(ns_viz("resource_pressure_plot")) # Usar el namespace aquí
          ),
          tabPanel(
            "Datos Simulados",
            h3("Tabla de Datos Simulados"),
            tableOutput("simulated_data_table") # Esta tabla no es parte del módulo de visualización
          )
        )
      )
    )
  )
}
