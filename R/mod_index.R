# mod_index.R
# Module for the initial data selection screen (Index)

mod_index_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fluidPage(
      titlePanel("Select Data Set for Simulation"),
      br(),
      p("This dashboard allows you to simulate epidemiological scenarios using different data sets."),
      p("Select the data source you would like to use for the simulation:"),
      selectInput(
        inputId = ns("dataset_selector"),
        label = "Data Set",
        choices = c(
          "Simulated Data (default)" = "mock",
          "IECS Model (Santoro)" = "iecs"
        ),
        selected = "mock"
      ),
      actionButton(ns("go_to_model"), "Go to Model", class = "btn-primary")
    )
  )
}

mod_index_server <- function(id, screen, dataset_selector) {
  moduleServer(id, function(input, output, session) {
    
    observeEvent(input$go_to_model, {
      dataset_selector(input$dataset_selector)  # Save in reactiveVal
      screen("main")
    })
  })
}
