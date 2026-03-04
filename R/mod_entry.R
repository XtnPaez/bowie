# ============================================================
# File: mod_entry.R
# ------------------------------------------------------------
# Description: Entry screen module for dataset selection and
#              navigation to the Advanced view.
#              Simple View is currently disabled pending
#              implementation (shown as "Coming soon").
# Author: Cristian Paez
# Created: 2025-11-07
# ============================================================

mod_entry_ui <- function(id) {
  ns <- NS(id)

  fluidPage(
    useShinyjs(),
    theme = bs_theme(version = 5, bootswatch = "flatly"),

    tags$head(
      tags$style(HTML("
        .entry-container {
          margin-top: 10%;
          text-align: center;
        }
        .entry-row {
          display: flex;
          justify-content: center;
          align-items: center;
          gap: 15px;
          flex-wrap: wrap;
        }
        .mode-button {
          width: 160px;
        }
        .alert {
          width: 360px;
          margin: 15px auto;
          text-align: center;
        }
      "))
    ),

    div(
      class = "entry-container",
      h2("SEIR Epidemiological Dashboard"),
      p("Select a dataset to initialise the simulation, then choose a view mode."),
      br(),

      div(
        class = "entry-row",
        selectInput(
          inputId = ns("dataset_selector"),
          label   = "Dataset Source",
          choices = c(
            "Simulated (mock)"    = "mock",
            "IECS \u2013 Santoro model" = "iecs"
          ),
          selected = "mock"
        ),
        actionButton(ns("load_dataset"), "Load Dataset",
                     class = "btn btn-primary"),

        # Simple View: disabled with tooltip
        # Wrapped in span so the tooltip fires even when
        # the button is disabled (disabled elements do not
        # trigger mouse events in some browsers).
        tags$span(
          title = "Coming soon",
          style = "cursor: not-allowed;",
          tags$button(
            "Simple View",
            class    = "btn btn-secondary mode-button",
            disabled = "disabled",
            style    = "opacity: 0.5; pointer-events: none;"
          )
        ),

        actionButton(ns("go_advanced"), "Advanced View",
                     class = "btn btn-info mode-button")
      ),

      br(),
      uiOutput(ns("status_message"))
    )
  )
}

mod_entry_server <- function(id, screen, dataset_selector, dataset_loaded, trigger_sim) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    first_load <- reactiveVal(TRUE)

    # --------------------------------------------------------
    # Local loader
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
          if (is.list(iecs_data)) {
            pop        <- iecs_data$poblacion
            start_date <- as.Date("2020-03-01")
            days       <- 200
            data <- data.frame(
              time = 0:days,
              date = start_date + 0:days,
              S    = pop - 10000 - 0:days * 10,
              E    = 500 + sin(0:days / 10) * 200,
              I    = 10000 + cos(0:days / 15) * 500,
              R    = 0:days * 50
            )
          } else if (is.data.frame(iecs_data)) {
            data <- iecs_data
          }
        }
      }
      data
    }

    # --------------------------------------------------------
    # Reset UI when returning to entry screen
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

    # --------------------------------------------------------
    # Load dataset
    # --------------------------------------------------------
    observeEvent(input$load_dataset, {
      shinyjs::disable("load_dataset")
      shinyjs::runjs("document.body.style.opacity = 0.5;")

      dataset_selector(input$dataset_selector)

      tryCatch({
        ds <- safe_load_dataset(input$dataset_selector)
        req(ds)
        dataset_loaded(ds)

        output$status_message <- renderUI({
          div(class = "alert alert-success", id = ns("alert_box"),
              "\u2705 Dataset loaded successfully.")
        })
        shinyjs::delay(3000, shinyjs::hide(id = ns("alert_box"),
                                           anim = TRUE, animType = "fade"))

      }, error = function(e) {
        output$status_message <- renderUI({
          div(class = "alert alert-danger", id = ns("alert_box"),
              paste("\u26a0\ufe0f Error loading dataset:", e$message))
        })
        shinyjs::delay(4000, shinyjs::hide(id = ns("alert_box"),
                                           anim = TRUE, animType = "fade"))
      })

      shinyjs::runjs("document.body.style.opacity = 1;")
      shinyjs::enable("load_dataset")
    })

    # --------------------------------------------------------
    # Navigation — Simple View observer removed (button disabled)
    # --------------------------------------------------------
    observeEvent(input$go_advanced, {
      req(dataset_loaded())
      screen("advanced")
      log_message("INFO", "User navigated to Advanced View", .module = "ENTRY")
    })
  })
}
