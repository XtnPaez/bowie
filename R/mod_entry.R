# ============================================================
# File: mod_entry.R
# ------------------------------------------------------------
# Description: Entry screen module for dataset selection and
#              navigation between Simple and Advanced views.
# Author: Cristian Paez
# Created: 2025-11-07
# ============================================================

# ------------------------------------------------------------
# Function: mod_entry_ui()
# Description: Defines the user interface for the entry screen,
#              including dataset selection, loading and navigation
#              controls for different view modes.
# ------------------------------------------------------------
mod_entry_ui <- function(id) {
  ns <- NS(id)
  
  fluidPage(
    useShinyjs(),
    theme = bs_theme(version = 5, bootswatch = "flatly"),
    
    # --- Inline style for layout and typography ---
    tags$head(
      tags$style(HTML("
        .entry-container {
          margin-top: 10%;
          text-align: centre;
        }
        .entry-row {
          display: flex;
          justify-content: centre;
          align-items: centre;
          gap: 15px;
          flex-wrap: wrap;
        }
        .mode-button {
          width: 160px;
        }
        /* Enlarge combo font both in control and dropdown list */
        select.form-select {
          font-size: 1.6rem !important;
          font-weight: 600 !important;
          min-width: 320px;
          padding: 10px 14px;
          line-height: 1.4 !important;
        }
        select.form-select option {
          font-size: 1.5rem !important;
          font-weight: 500 !important;
          line-height: 1.4 !important;
        }
        .alert {
          width: 360px;
          margin: 15px auto;
          text-align: centre;
        }
      "))
    ),
    
    # --- Entry layout container ---
    div(
      class = "entry-container",
      h2("SEIR Epidemiological Dashboard"),
      p("Select a dataset to initialise the simulation, then choose a view mode."),
      br(),
      
      # --- Dataset selection and control buttons ---
      div(
        class = "entry-row",
        selectInput(
          inputId = ns("dataset_selector"),
          label = "Dataset Source",
          choices = c(
            "Simulated (mock)" = "mock",
            "IECS – Santoro model" = "iecs"
          ),
          selected = "mock"
        ),
        actionButton(ns("load_dataset"), "Load Dataset", class = "btn btn-primary"),
        actionButton(ns("go_simple"), "Simple View", class = "btn btn-success mode-button"),
        actionButton(ns("go_advanced"), "Advanced View", class = "btn btn-info mode-button")
      ),
      
      br(),
      uiOutput(ns("status_message"))
    )
  )
}

# ------------------------------------------------------------
# Function: mod_entry_server()
# Description: Handles dataset loading, validation, user feedback
#              and navigation between Simple and Advanced views.
# Parameters:
#   id              - Shiny module id
#   screen          - reactiveVal controlling the active screen
#   dataset_selector - reactiveVal storing dataset name
#   dataset_loaded   - reactiveVal storing loaded dataset
#   trigger_sim      - reactiveVal controlling model simulation
# ------------------------------------------------------------
mod_entry_server <- function(id, screen, dataset_selector, dataset_loaded, trigger_sim) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    first_load <- reactiveVal(TRUE)
    
    # --------------------------------------------------------
    # Local loader: loads dataset safely without submodule use
    # --------------------------------------------------------
    safe_load_dataset <- function(source) {
      log_message("INFO",
                  paste("Loading dataset (local call):", source),
                  .module = "ENTRY")
      
      data <- NULL
      if (source == "mock" && file.exists("data/mock_dataset.rds")) {
        data <- readRDS("data/mock_dataset.rds")
        
      } else if (source == "iecs" && file.exists("data/iecs_data.RData")) {
        iecs_data <- load_iecs_data()
        if (exists("iecs_data")) {
          # If dataset is a list, build minimal SEIR-like data frame
          if (is.list(iecs_data)) {
            pop <- iecs_data$poblacion
            start_date <- as.Date("2020-03-01")
            days <- 200
            data <- data.frame(
              time = 0:days,
              date = start_date + 0:days,
              S = pop - 10000 - 0:days * 10,
              E = 500 + sin(0:days / 10) * 200,
              I = 10000 + cos(0:days / 15) * 500,
              R = 0:days * 50
            )
          } else if (is.data.frame(iecs_data)) {
            data <- iecs_data
          }
        }
      }
      data
    }
    
    # --------------------------------------------------------
    # Reset UI and reactivity when returning to entry screen
    # --------------------------------------------------------
    observeEvent(screen(), {
      if (screen() == "entry") {
        output$status_message <- renderUI(NULL)
        if (!first_load()) {
          dataset_selector(NULL)
          dataset_loaded(NULL)
              }
        first_load(FALSE)
      }
    })
    # --- End of reactive block ---
    
    # --------------------------------------------------------
    # Load dataset and provide feedback to the user
    # --------------------------------------------------------
    observeEvent(input$load_dataset, {
      shinyjs::disable("load_dataset")
      shinyjs::runjs("document.body.style.opacity = 0.5;")
      
      dataset_selector(input$dataset_selector)
      
      tryCatch({
        ds <- safe_load_dataset(input$dataset_selector)
        req(ds)
        dataset_loaded(ds)
     
        # Success alert (auto-hides after 3 seconds)
        output$status_message <- renderUI({
          div(class = "alert alert-success", id = ns("alert_box"),
              "✅ Dataset loaded successfully.")
        })
        shinyjs::delay(3000, shinyjs::hide(id = ns("alert_box"),
                                           anim = TRUE, animType = "fade"))
        
      }, error = function(e) {
        # Error alert (auto-hides after 4 seconds)
        output$status_message <- renderUI({
          div(class = "alert alert-danger", id = ns("alert_box"),
              paste("⚠️ Error loading dataset:", e$message))
        })
        shinyjs::delay(4000, shinyjs::hide(id = ns("alert_box"),
                                           anim = TRUE, animType = "fade"))
      })
      
      shinyjs::runjs("document.body.style.opacity = 1;")
      shinyjs::enable("load_dataset")
    })
    # --- End of reactive block ---
    
    # --------------------------------------------------------
    # Navigation buttons to switch views
    # --------------------------------------------------------
    observeEvent(input$go_simple, {
      req(dataset_loaded())
      screen("simple")
      log_message("INFO", "User navigated to Simple View", .module = "ENTRY")
    })
    
    observeEvent(input$go_advanced, {
      req(dataset_loaded())
      screen("advanced")
      log_message("INFO", "User navigated to Advanced View", .module = "ENTRY")
    })
    # --- End of reactive block ---
  })
}
