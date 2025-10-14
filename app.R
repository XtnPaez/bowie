# app.R
# Este es el archivo principal de la aplicación Shiny que une todos los módulos.

message("Shiny app starting...")

# Cargar el archivo global para las configuraciones y librerías
source("R/global.R")

# Cargar los módulos
source("R/mod_ui.R")
source("R/mod_server.R")
source("R/mod_data.R")
source("R/mod_model.R")
source("R/mod_viz.R")
source("R/mod_index.R")

# UI principal
ui <- fluidPage(
  uiOutput("pantalla_actual")
)

# Servidor
server <- function(input, output, session) {
  # ReactiveVal para controlar qué pantalla mostrar
  pantalla <- reactiveVal("index")
  
  # ReactiveVal para guardar la selección del dataset
  dataset_selector <- reactiveVal("mock")
  
  # Renderizar la pantalla según el estado
  output$pantalla_actual <- renderUI({
    if (pantalla() == "index") {
      mod_index_ui("index")
    } else {
      ui_main("main_viz")
    }
  })
  
  # Servidor del index
  mod_index_server("index", pantalla, dataset_selector)
  
  # Variable reactiva para guardar el resultado de mod_server
  server_outputs <- reactiveVal(NULL)
  
  # Llamar al servidor principal y guardar sus outputs
  observe({
    if (pantalla() != "index") {
      outputs <- mod_server("main_viz", dataset_selector)
      server_outputs(outputs)
    }
  })
  
  # Llamar a viz_plot_server SOLO cuando tengamos datos
  observe({
    req(server_outputs())
    
    viz_plot_server(
      "main_viz",
      model_data = server_outputs()$model_data,
      icu_capacity_input = server_outputs()$icu_capacity,
      ventilator_availability_input = server_outputs()$ventilator_availability
    )
  })
  
} # ← Cierre de la función server

shinyApp(ui = ui, server = server)