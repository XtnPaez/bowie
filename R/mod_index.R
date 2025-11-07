# ============================================================
# File: mod_index.R
# ------------------------------------------------------------
# Description: Provides the initial entry screen for selecting
# the dataset source used in the SEIR simulation.
# Allows switching between mock and IECS data inputs.
# Author: Cristian Paez
# Created: 2025-11-07
# ============================================================

# ------------------------------------------------------------
# Function: mod_index_ui()
# Description:
#   Defines the UI for the dataset selection screen.
#   Displays basic project information and a dropdown
#   for selecting the simulation data source.
# Parameters:
#   id – Shiny module identifier.
# Returns:
#   UI elements as a tagList.
# ------------------------------------------------------------
mod_index_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fluidPage(
      titlePanel("Select Data Source for Simulation"),
      br(),
      p("This dashboard allows users to simulate epidemiological scenarios using different data sources."),
      p("Choose the dataset to initialise the SEIR model:"),
      selectInput(
        inputId = ns("dataset_selector"),
        label = "Available Datasets",
        choices = c(
          "Simulated Data (default)" = "mock",
          "IECS Model (Santoro)" = "iecs"
        ),
        selected = "mock"
      ),
      actionButton(ns("go_to_model"), "Proceed to Model", class = "btn-primary")
    )
  )
}

# ------------------------------------------------------------
# Function: mod_index_server()
# Description:
#   Server logic for the dataset selection screen.
#   Stores the selected dataset in a reactive variable and
#   switches to the main simulation view.
# Parameters:
#   id – Shiny module identifier.
#   screen – reactive value controlling visible screen ("index"/"main").
#   dataset_selector – reactiveVal for storing selected dataset.
# Returns:
#   None (side-effect: updates screen and dataset_selector).
# ------------------------------------------------------------
mod_index_server <- function(id, screen, dataset_selector) {
  moduleServer(id, function(input, output, session) {
    
    # --- Reactive block: handle dataset selection ---
    observeEvent(input$go_to_model, {
      dataset_selector(input$dataset_selector)  # Store selected dataset
      screen("main")                            # Navigate to main app view
    })
    # --- End of reactive block ---
  })
}
