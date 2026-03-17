# ============================================================
# File: mod_menu.R
# ------------------------------------------------------------
# Description: Top navigation menu module. Renders a Bootstrap
#   navbar that persists across all non-entry views. Provides:
#     - An active dataset indicator (read-only, italic text).
#     - Three view navigation buttons: Home, Simple, Advanced.
#   The Simple View button is intentionally disabled pending
#   implementation (Block 5 of the roadmap). It renders as a
#   plain HTML <button> with a native browser tooltip rather
#   than a Shiny actionButton so that the disabled state and
#   tooltip work correctly without JavaScript intervention.
# Author: Cristian Paez
# Created: 2025-11-07
# ============================================================


# ------------------------------------------------------------
# Function: mod_menu_ui()
# Description:
#   Renders the top navigation bar as a Bootstrap navbar.
#   The bar is right-aligned and contains the dataset indicator
#   and the three view buttons. It is injected into the page
#   above the main content by app.R whenever screen() != "entry".
# Parameters:
#   id – Shiny module identifier; used to namespace outputs and
#        inputs so they do not collide with other modules.
# Returns:
#   A tagList() containing the <nav> element.
# ------------------------------------------------------------
mod_menu_ui <- function(id) {
  ns <- NS(id)

  tagList(
    tags$nav(
      class = "navbar navbar-expand-lg border",
      style = "background-color:#E9ECEF; padding:0.6rem 1rem;",

      div(
        class = "container-fluid d-flex justify-content-end align-items-center gap-3",

        # Dataset indicator: shows the active source (e.g. "Dataset: MOCK")
        # Rendered server-side so it updates reactively on dataset change
        span(textOutput(ns("active_dataset")),
             class = "text-dark small fst-italic me-3"),

        # View navigation buttons
        div(
          class = "d-flex align-items-center gap-2",

          # Home: returns the user to the entry/dataset-selection screen
          actionButton(ns("btn_home"), "Home",
                       class = "btn btn-outline-secondary btn-sm"),

          # Simple View: disabled — Block 5 implementation pending.
          # Rendered as a raw <button> (not actionButton) so that the
          # disabled attribute and native tooltip work in all browsers.
          # pointer-events: none prevents click events reaching Shiny.
          tags$button(
            "Simple",
            class    = "btn btn-outline-secondary btn-sm",
            disabled = "disabled",
            title    = "Coming soon",
            style    = "cursor: not-allowed; opacity: 0.5;"
          ),

          # Advanced View: navigates to the full parameter dashboard
          actionButton(ns("btn_advanced"), "Advanced",
                       class = "btn btn-outline-info btn-sm")
        )
      )
    )
  )
}


# ------------------------------------------------------------
# Function: mod_menu_server()
# Description:
#   Server logic for the navigation menu. Renders the active
#   dataset label and wires navigation button click events to
#   the shared screen() reactive value in app.R.
#   No observer is registered for btn_simple because the button
#   is disabled in the UI and cannot emit click events.
# Parameters:
#   id              – Shiny module identifier.
#   screen          – reactiveVal(character); controls which view
#                     is rendered by output$main_ui in app.R.
#                     Accepted values: "entry", "advanced".
#                     ("simple" reserved for Block 5.)
#   dataset_selector – reactiveVal(character); holds the active
#                     dataset source key (e.g. "mock", "iecs").
# Returns:
#   None (side effects: updates screen() and renders output).
# ------------------------------------------------------------
mod_menu_server <- function(id, screen, dataset_selector) {
  moduleServer(id, function(input, output, session) {

    # --- Reactive block: render active dataset label ---
    # Displays "No dataset loaded" until a source is selected,
    # then shows the source key in upper case for visibility
    output$active_dataset <- renderText({
      ds <- dataset_selector()
      if (is.null(ds)) return("No dataset loaded")
      paste("Dataset:", toupper(ds))
    })
    # --- End of reactive block ---

    # --- Reactive block: Home button navigation ---
    observeEvent(input$btn_home, {
      screen("entry")
    })
    # --- End of reactive block ---

    # btn_simple observer intentionally omitted — button is
    # disabled in the UI and will be wired in Block 5

    # --- Reactive block: Advanced button navigation ---
    observeEvent(input$btn_advanced, {
      screen("advanced")
    })
    # --- End of reactive block ---
  })
}
