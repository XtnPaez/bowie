# ============================================================
# File: app.R
# ------------------------------------------------------------
# Description: Main entry point for the SEIR Shiny application.
# Integrates all UI and server modules, controls navigation
# between screens, and manages reactive module coordination.
# Author: Cristian Paez
# Created: 2025-11-07
# ============================================================

# --- Application startup message ---
message("Shiny app starting...")

# ------------------------------------------------------------
# Load global configuration and required libraries
# ------------------------------------------------------------
source("R/global.R")

# ------------------------------------------------------------
# Load module definitions
# ------------------------------------------------------------
source("R/mod_ui.R")
source("R/mod_server.R")
source("R/mod_data.R")
source("R/mod_model.R")
source("R/mod_viz.R")
source("R/mod_index.R")

# ------------------------------------------------------------
# UI definition
# ------------------------------------------------------------
ui <- fluidPage(
  uiOutput("current_screen")
)

# ------------------------------------------------------------
# Server logic
# ------------------------------------------------------------
server <- function(input, output, session) {
  
  # --- Reactive: controls which screen is active (index/main) ---
  screen <- reactiveVal("index")
  
  # --- Reactive: stores selected dataset type ---
  dataset_selector <- reactiveVal("mock")
  
  # --- Dynamic screen rendering ---
  output$current_screen <- renderUI({
    if (screen() == "index") {
      mod_index_ui("index")
    } else {
      ui_main("main_viz")
    }
  })
  
  # --- Index server module (dataset selection screen) ---
  mod_index_server("index", screen, dataset_selector)
  
  # --- ReactiveVal: stores output list from main server ---
  server_outputs <- reactiveVal(NULL)
  
  # --- Initialise core server once user proceeds to main screen ---
  observe({
    if (screen() != "index") {
      outputs <- mod_server("main_viz", dataset_selector)
      server_outputs(outputs)
    }
  })
  
  # --- Initialise visualisation module once data is ready ---
  observe({
    req(server_outputs())
    
    viz_plot_server(
      "main_viz",
      model_data = server_outputs()$model_data,
      icu_capacity_input = server_outputs()$icu_capacity,
      ventilator_availability_input = server_outputs()$ventilator_availability
    )
  })
}

# ------------------------------------------------------------
# Launch Shiny application
# ------------------------------------------------------------
shinyApp(ui = ui, server = server)
