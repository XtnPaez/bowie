# ============================================================
# File: app.R
# ------------------------------------------------------------
# Description: Main SEIR Shiny application. Integrates Entry,
#              Menu, Simple and Advanced views with correct
#              module wiring for data, model and visualisation.
#
# NOTE: global.R and all R/ modules are loaded automatically
# by Shiny's loadSupport() mechanism because the project
# contains a DESCRIPTION file (R package structure).
# Manual source() calls are therefore NOT required here.
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
  # Dynamic UI
  # --------------------------------------------------------
  output$main_ui <- renderUI({
    current  <- screen()
    menu_ui  <- if (current != "entry") mod_menu_ui("menu") else NULL

    main_content <- switch(
      current,
      "entry"    = mod_entry_ui("entry"),
      "simple"   = ui_main("viz_simple"),
      "advanced" = ui_main("viz_advanced"),
      div(h3("Unknown view"))
    )

    tagList(menu_ui, main_content)
  })

  # --------------------------------------------------------
  # Entry and menu servers
  # --------------------------------------------------------
  mod_entry_server("entry", screen, dataset_selector, dataset_loaded, trigger_sim)
  mod_menu_server("menu", screen, dataset_selector)

  # --------------------------------------------------------
  # Advanced view
  # --------------------------------------------------------
  # Guard flag prevents duplicate module registration if the
  # user navigates away and back to this view.
  # The id "viz_advanced" must match ui_main("viz_advanced")
  # so that input widgets and output plots share the same namespace.
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
  # Simple view
  # --------------------------------------------------------
  simple_initialised <- reactiveVal(FALSE)

  observeEvent(screen(), {
    req(screen() == "simple", dataset_loaded())
    if (simple_initialised()) return()
    simple_initialised(TRUE)

    out <- mod_server("viz_simple", reactive({ dataset_selector() }))

    viz_plot_server(
      id                            = "viz_simple",
      model_data                    = out$model_data,
      icu_capacity_input            = out$icu_capacity,
      ventilator_availability_input = out$ventilator_availability
    )
  })
}

# ============================================================
# Launch
# ============================================================
shinyApp(ui, server)
