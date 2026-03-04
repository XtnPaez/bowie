# ============================================================
# File: mod_menu.R
# ------------------------------------------------------------
# Description: Top navigation menu with dataset indicator
#              and view buttons. Simple View is currently
#              disabled and shows a "Coming soon" tooltip.
# ============================================================

mod_menu_ui <- function(id) {
  ns <- NS(id)

  tagList(
    tags$nav(
      class = "navbar navbar-expand-lg border",
      style = "background-color:#E9ECEF; padding:0.6rem 1rem;",
      div(
        class = "container-fluid d-flex justify-content-end align-items-center gap-3",

        # Dataset indicator
        span(textOutput(ns("active_dataset")),
             class = "text-dark small fst-italic me-3"),

        # View buttons
        div(
          class = "d-flex align-items-center gap-2",

          actionButton(ns("btn_home"), "Home",
                       class = "btn btn-outline-secondary btn-sm"),

          # Simple View: disabled with tooltip
          # title= renders as native browser tooltip on hover
          tags$button(
            "Simple",
            class    = "btn btn-outline-secondary btn-sm",
            disabled = "disabled",
            title    = "Coming soon",
            style    = "cursor: not-allowed; opacity: 0.5;"
          ),

          actionButton(ns("btn_advanced"), "Advanced",
                       class = "btn btn-outline-info btn-sm")
        )
      )
    )
  )
}

mod_menu_server <- function(id, screen, dataset_selector) {
  moduleServer(id, function(input, output, session) {

    output$active_dataset <- renderText({
      ds <- dataset_selector()
      if (is.null(ds)) return("No dataset loaded")
      paste("Dataset:", toupper(ds))
    })

    observeEvent(input$btn_home,     { screen("entry") })
    # btn_simple observer removed — button is disabled in UI
    observeEvent(input$btn_advanced, { screen("advanced") })
  })
}
