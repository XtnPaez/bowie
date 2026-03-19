# ============================================================
# File: mod_entry.R
# ------------------------------------------------------------
# Description: Entry screen module for dataset selection and
#              navigation to the Advanced or Simple views.
#              Layout aligned with PPT brand guidelines:
#              dark green navbar, card-centred layout, PPT
#              colour palette throughout.
# Author: Cristian Paez
# Created: 2025-11-07
# Updated: 2026-03-19 — Block 5: Simple View button enabled.
# ============================================================


# ------------------------------------------------------------
# Function: mod_entry_ui()
# Description:
#   Renders the full entry screen. Includes a PPT-branded
#   navbar at the top and a centred card containing the
#   dataset selector, load button, status badge, and view
#   mode buttons. The footer bar anchors the page at the
#   bottom with project attribution.
# Parameters:
#   id – Shiny module identifier.
# Returns:
#   A tagList() with navbar, body, and footer elements.
# ------------------------------------------------------------
mod_entry_ui <- function(id) {
  ns <- NS(id)

  tagList(
    useShinyjs(),

    # --------------------------------------------------------
    # Top navbar — PPT dark green, no Bootstrap fluidPage
    # wrapper so the navbar sits flush at the top of the page
    # --------------------------------------------------------
    tags$nav(
      class = "navbar",
      style = paste(
        "background-color:#324027;",
        "padding:0 1rem;",
        "height:52px;",
        "display:flex;",
        "align-items:center;",
        "justify-content:space-between;",
        "border-bottom:1px solid #1E2A16;"
      ),
      tags$span(
        style = "font-size:18px; font-weight:500; color:#F4F6F5;",
        "SEIR Dashboard"
      ),
      tags$span(
        style = paste(
          "font-size:18px;",
          "color:rgba(244,246,245,0.55);",
          "font-style:italic;"
        ),
        "Pandemic Preparedness Toolkit \u00b7 Argentina Unit"
      )
    ),

    # --------------------------------------------------------
    # Main body — centred card layout on PPT tint background
    # --------------------------------------------------------
    tags$div(
      style = paste(
        "min-height:calc(100vh - 100px);",
        "background-color:#F4F6F5;",
        "display:flex;",
        "flex-direction:column;",
        "align-items:center;",
        "justify-content:center;",
        "padding:40px 16px;"
      ),

      # Header text above the card
      tags$div(
        style = "text-align:center; margin-bottom:28px;",
        tags$h1(
          "Epidemiological Modelling Platform",
          style = paste(
            "font-size:2.4rem;",
            "font-weight:600;",
            "color:#1E2A16;",
            "margin-bottom:8px;"
          )
        ),
        tags$p(
          "Select a dataset to initialise the simulation,",
          "then choose a view mode to explore epidemic scenarios.",
          style = "font-size:1rem; color:#48553F; max-width:440px;"
        )
      ),

      # Central card
      tags$div(
        style = paste(
          "background:#ffffff;",
          "border:0.5px solid #D0D4CE;",
          "border-radius:12px;",
          "padding:28px 32px;",
          "width:100%;",
          "max-width:480px;"
        ),

        # --- Dataset selector ---
        tags$div(
          style = "margin-bottom:16px;",
          tags$div(
            "Dataset source",
            style = paste(
              "font-size:18px;",
              "font-weight:500;",
              "color:#48553F;",
              "text-transform:uppercase;",
              "letter-spacing:0.05em;",
              "margin-bottom:6px;"
            )
          ),
          selectInput(
            inputId  = ns("dataset_selector"),
            label    = NULL,
            choices  = c(
              "Simulated (mock)"          = "mock",
              "IECS \u2013 Santoro model" = "iecs"
            ),
            selected = "mock",
            width    = "100%"
          )
        ),

        # --- Load Dataset button ---
        actionButton(
          ns("load_dataset"),
          "Load dataset",
          class = "btn btn-primary w-100",
          style = "margin-bottom:12px;"
        ),

        # --- Status message (success / error badge) ---
        uiOutput(ns("status_message")),

        tags$hr(style = "border-color:#D0D4CE; margin:16px 0;"),

        # --- View mode label ---
        tags$div(
          "View mode",
          style = paste(
            "font-size:18px;",
            "font-weight:500;",
            "color:#48553F;",
            "text-transform:uppercase;",
            "letter-spacing:0.05em;",
            "margin-bottom:8px;"
          )
        ),

        # --- View buttons row ---
        # Both buttons active — Simple View enabled in Block 5.
        tags$div(
          style = "display:flex; gap:10px;",

          actionButton(
            ns("go_advanced"),
            "Advanced view",
            class = "btn btn-primary flex-fill"
          ),

          actionButton(
            ns("go_simple"),
            "Simple view",
            class = "btn btn-outline-secondary flex-fill"
          )
        )
      )
    ),

    # --------------------------------------------------------
    # Footer bar — attribution strip
    # --------------------------------------------------------
    tags$div(
      style = paste(
        "background:#F8F5F1;",
        "border-top:0.5px solid #D0D4CE;",
        "padding:10px 24px;",
        "display:flex;",
        "justify-content:space-between;",
        "align-items:center;"
      ),
      tags$span(
        tags$span(
          style = paste(
            "display:inline-block;",
            "width:6px; height:6px;",
            "border-radius:50%;",
            "background:#F59342;",
            "margin-right:6px;",
            "vertical-align:middle;"
          )
        ),
        tags$span(
          "Pandemic Preparedness Toolkit \u00b7 Argentina Unit \u00b7 WP5",
          style = "font-size:18px; color:#7A8A72;"
        )
      ),
      tags$span(
        "Funded by Wellcome \u00b7 CEMIC",
        style = "font-size:18px; color:#A8B09F;"
      )
    )
  )
}


# ------------------------------------------------------------
# Function: mod_entry_server()
# Description:
#   Server logic for the entry screen. Handles dataset loading,
#   status feedback, and navigation to the Advanced or Simple
#   views. Resets state when the user returns to the entry
#   screen.
# Parameters:
#   id               – Shiny module identifier.
#   screen           – reactiveVal(character); controls active view.
#   dataset_selector – reactiveVal(character); active source key.
#   dataset_loaded   – reactiveVal(data.frame); loaded dataset.
#   trigger_sim      – reactiveVal(integer); simulation trigger.
# Returns:
#   None (side effects only).
# ------------------------------------------------------------
mod_entry_server <- function(id, screen, dataset_selector,
                             dataset_loaded, trigger_sim) {
  moduleServer(id, function(input, output, session) {
    ns         <- session$ns
    first_load <- reactiveVal(TRUE)

    # --------------------------------------------------------
    # Local dataset loader
    # --------------------------------------------------------
    safe_load_dataset <- function(source) {
      log_message("INFO",
                  paste("Loading dataset (local call):", source),
                  .module = "ENTRY")

      data <- NULL

      if (source == "mock" && file.exists("data/mock_dataset.rds")) {
        data <- readRDS("data/mock_dataset.rds")

      } else if (source == "iecs" &&
                 file.exists("data/iecs_data.RData")) {
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
    # Load dataset — shows status badge inside the card
    # --------------------------------------------------------
    observeEvent(input$load_dataset, {
      shinyjs::disable("load_dataset")
      shinyjs::runjs("document.body.style.opacity = 0.6;")

      dataset_selector(input$dataset_selector)

      tryCatch({
        ds <- safe_load_dataset(input$dataset_selector)
        req(ds)
        dataset_loaded(ds)

        # Success badge — PPT green tint
        output$status_message <- renderUI({
          tags$div(
            id    = ns("alert_box"),
            style = paste(
              "display:flex; align-items:center; gap:8px;",
              "padding:10px 14px;",
              "background:#C0DD97;",
              "border:0.5px solid #3B6D11;",
              "border-radius:6px;",
              "margin-bottom:12px;"
            ),
            tags$span(
              style = paste(
                "width:8px; height:8px;",
                "border-radius:50%;",
                "background:#27500A;",
                "flex-shrink:0;",
                "display:inline-block;"
              )
            ),
            tags$span(
              "Dataset loaded successfully.",
              style = "font-size:16px; color:#27500A; font-weight:500;"
            )
          )
        })

        shinyjs::delay(3000,
                       shinyjs::hide(id       = ns("alert_box"),
                                     anim     = TRUE,
                                     animType = "fade"))

      }, error = function(e) {
        # Error badge — PPT earthy red tint
        output$status_message <- renderUI({
          tags$div(
            id    = ns("alert_box"),
            style = paste(
              "display:flex; align-items:center; gap:8px;",
              "padding:10px 14px;",
              "background:#F9EDEA;",
              "border:0.5px solid #E8B8AD;",
              "border-radius:6px;",
              "margin-bottom:12px;"
            ),
            tags$span(
              style = paste(
                "width:8px; height:8px;",
                "border-radius:50%;",
                "background:#752111;",
                "flex-shrink:0;",
                "display:inline-block;"
              )
            ),
            tags$span(
              paste("Error loading dataset:", e$message),
              style = "font-size:16px; color:#752111;"
            )
          )
        })

        shinyjs::delay(4000,
                       shinyjs::hide(id       = ns("alert_box"),
                                     anim     = TRUE,
                                     animType = "fade"))
      })

      shinyjs::runjs("document.body.style.opacity = 1;")
      shinyjs::enable("load_dataset")
    })

    # --------------------------------------------------------
    # Navigation to Advanced view
    # --------------------------------------------------------
    observeEvent(input$go_advanced, {
      req(dataset_loaded())
      screen("advanced")
      log_message("INFO", "User navigated to Advanced View",
                  .module = "ENTRY")
    })

    # --------------------------------------------------------
    # Navigation to Simple view — Block 5
    # --------------------------------------------------------
    observeEvent(input$go_simple, {
      req(dataset_loaded())
      screen("simple")
      log_message("INFO", "User navigated to Simple View",
                  .module = "ENTRY")
    })
  })
}
