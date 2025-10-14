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
      ui_main("main_viz")  # ⚠️ Este ID debe coincidir con el del servidor
    }
  })
  
  # Servidor del index
  mod_index_server("index", pantalla, dataset_selector)
  
  # llamar al servidor principal como módulo
  # Solo se activa cuando pantalla != "index"
  observe({
    if (pantalla() != "index") {
      mod_server("main_viz", dataset_selector)  # ← ID debe coincidir con ui_main
    }
  })
}

shinyApp(ui = ui, server = server)