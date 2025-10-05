# mod_index.R
# Módulo para la pantalla de selección de datos (Index)

mod_index_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fluidPage(
      titlePanel("Seleccionar Set de Datos para Simulación"),
      br(),
      p("Este tablero permite simular escenarios epidemiológicos usando distintos conjuntos de datos."),
      p("Seleccioná el origen de los datos que querés usar para la simulación:"),
      selectInput(
        inputId = ns("dataset_selector"),
        label = "Conjunto de Datos",
        choices = c(
          "Datos Simulados (por defecto)" = "mock",
          "Modelo IECS (Santoro)" = "iecs"
        ),
        selected = "mock"
      ),
      actionButton(ns("go_to_model"), "Ir al Modelo", class = "btn-primary")
    )
  )
}

mod_index_server <- function(id, pantalla, dataset_selector) {
  moduleServer(id, function(input, output, session) {
    
    observeEvent(input$go_to_model, {
      dataset_selector(input$dataset_selector)  # Guardar en reactiveVal
      pantalla("main")
    })
  })
}

