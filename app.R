# ============================================================
# File: app.R
# ------------------------------------------------------------
# Description: Main SEIR Shiny application. Integrates Entry,
#              Menu, Simple and Advanced views with correct
#              module wiring for data, model and visualisation.
#
# NOTE: global.R and all R/ modules are loaded automatically
# by Shiny's loadSupport() mechanism (DESCRIPTION file present).
# Manual source() calls are NOT required here.
#
# Namespace contract — Advanced View plot outputs:
#   ui_main("viz_advanced") generates plotOutput ids of the
#   form "viz_advanced-seir_plot", etc.
#   viz_plot_server() must be called with id = "viz_advanced"
#   from the TOP-LEVEL server — never from inside another
#   moduleServer() call — to prevent double-prefixed ids.
#   See Block 4b notes for full explanation.
#
# Namespace contract — Simple View:
#   mod_ui_simple("viz_simple") / mod_server_simple("viz_simple").
#   The Simple View does NOT use viz_plot_server() — it renders
#   KPI cards via renderUI inside mod_server_simple().
#   State is fully isolated: mod_server_simple() maintains its
#   own reactiveValues always initialised from global.R defaults.
#   Internal sub-modules use "simple_data" and "simple_seir"
#   namespace ids to avoid collision with "data_sim"/"seir_model"
#   used by the Advanced View.
#
# Block 5 — Simplified View implemented: 2026-03-19
# ============================================================

library(shiny)
library(shinyjs)

# ============================================================
# UI
# ============================================================
ui <- fluidPage(
  useShinyjs(),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
  ),
  uiOutput("main_ui")
)

# ============================================================
# Server
# ============================================================
server <- function(input, output, session) {

  # --------------------------------------------------------
  # Reactive state
  # --------------------------------------------------------
  screen           <- reactiveVal("entry")
  dataset_selector <- reactiveVal(NULL)
  dataset_loaded   <- reactiveVal(NULL)
  trigger_sim      <- reactiveVal(0)

  # --------------------------------------------------------
  # Dynamic UI routing
  # Menu bar shown on all views except entry.
  # --------------------------------------------------------
  output$main_ui <- renderUI({
    current <- screen()

    menu_ui <- if (current != "entry") mod_menu_ui("menu") else NULL

    main_content <- switch(
      current,
      "entry"    = mod_entry_ui("entry"),
      "simple"   = mod_ui_simple("viz_simple"),
      "advanced" = ui_main("viz_advanced"),
      div(h3("Unknown view"))
    )

    tagList(menu_ui, main_content)
  })

  # --------------------------------------------------------
  # Entry and menu servers — always active
  # --------------------------------------------------------
  mod_entry_server("entry", screen, dataset_selector,
                   dataset_loaded, trigger_sim)
  mod_menu_server("menu", screen, dataset_selector)

  # --------------------------------------------------------
  # Advanced view
  # --------------------------------------------------------
  # Guard flag prevents duplicate module registration when
  # the user navigates away and back to this view.
  #
  # viz_plot_server() is called at the top level so output ids
  # resolve to "viz_advanced-*", matching the plotOutput calls
  # inside ui_main("viz_advanced").
  # --------------------------------------------------------
  advanced_initialised <- reactiveVal(FALSE)

  observeEvent(screen(), {
    req(screen() == "advanced", dataset_loaded())
    if (advanced_initialised()) return()
    advanced_initialised(TRUE)

    out <- mod_server("viz_advanced", reactive({ dataset_selector() }))

    viz_plot_server(
      id                            = "viz_advanced",
      model_data                    = out$model_data,
      icu_capacity_input            = out$icu_capacity,
      ventilator_availability_input = out$ventilator_availability
    )
  })

  # --------------------------------------------------------
  # Simple view — Block 5
  # --------------------------------------------------------
  # mod_server_simple() is self-contained: it calls
  # mod_data_server() and model_seir_server() internally.
  # It does NOT use viz_plot_server() — KPI cards are rendered
  # via renderUI inside the module itself.
  #
  # dataset_selector is passed through for logging only.
  # All SEIR parameters are driven exclusively by the Simple
  # View sliders, always initialised from global.R defaults.
  # --------------------------------------------------------
  simple_initialised <- reactiveVal(FALSE)

  observeEvent(screen(), {
    req(screen() == "simple", dataset_loaded())
    if (simple_initialised()) return()
    simple_initialised(TRUE)

    mod_server_simple("viz_simple", reactive({ dataset_selector() }))

    log_message("INFO", "Simple View server initialised", .module = "APP")
  })
}

# ============================================================
# Launch
# ============================================================
shinyApp(ui, server)
