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
#
# Namespace contract for plot outputs:
#   ui_main("viz_advanced") generates plotOutput ids of the
#   form "viz_advanced-seir_plot", "viz_advanced-cases_deaths_plot",
#   and "viz_advanced-resource_pressure_plot".
#
#   For output$seir_plot registered inside viz_plot_server() to
#   resolve to "viz_advanced-seir_plot", viz_plot_server() must
#   be called with id = "viz_advanced" from the TOP-LEVEL server
#   function — never from inside another moduleServer() call.
#
#   If viz_plot_server() were called from inside mod_server()
#   (which itself runs under the "viz_advanced" namespace), the
#   resulting output id would be "viz_advanced-viz_advanced-seir_plot",
#   which does not match any plotOutput in the UI.
#
#   mod_server() therefore does NOT call viz_plot_server().
#   It returns model_data, icu_capacity, and
#   ventilator_availability for app.R to pass through.
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
    current <- screen()

    # Menu bar is shown on all views except the entry screen
    menu_ui <- if (current != "entry") mod_menu_ui("menu") else NULL

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
  #
  # mod_server() runs under the "viz_advanced" namespace.
  # viz_plot_server() is called here at the top level so that
  # output ids resolve to "viz_advanced-*" — matching the
  # plotOutput calls in ui_main("viz_advanced").
  # --------------------------------------------------------
  advanced_initialised <- reactiveVal(FALSE)

  observeEvent(screen(), {
    req(screen() == "advanced", dataset_loaded())
    if (advanced_initialised()) return()
    advanced_initialised(TRUE)

    out <- mod_server("viz_advanced", reactive({ dataset_selector() }))

    # Called at top level — output$seir_plot resolves to
    # "viz_advanced-seir_plot", matching plotOutput in ui_main()
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
  # Same namespace contract as the Advanced view.
  # viz_plot_server() called at top level so output ids
  # resolve to "viz_simple-*".
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
