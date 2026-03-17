# ============================================================
# File: mod_menu.R
# ------------------------------------------------------------
# Description: Top navigation menu module. Renders a PPT-branded
#   dark green navbar that persists across all non-entry views.
#   Provides:
#     - Brand name with orange accent slash.
#     - Active dataset indicator (italic, muted).
#     - Three view buttons: Home, Simple (disabled), Advanced.
#   Simple View button renders as a plain HTML <button> so
#   the disabled state and native tooltip work correctly.
# Author: Cristian Paez
# Created: 2025-11-07
# ============================================================


# ------------------------------------------------------------
# Function: mod_menu_ui()
# Description:
#   Renders the top navigation bar as a PPT dark green navbar.
#   Injected above main content by app.R when screen() != "entry".
# Parameters:
#   id – Shiny module identifier.
# Returns:
#   A tagList() containing the <nav> element.
# ------------------------------------------------------------
mod_menu_ui <- function(id) {
  ns <- NS(id)

  tagList(
    tags$nav(
      style = paste(
        "background-color:#324027;",
        "border-bottom:1px solid #1E2A16;",
        "padding:0 1rem;",
        "height:52px;",
        "display:flex;",
        "align-items:center;",
        "justify-content:space-between;"
      ),

      # Left: brand name
      tags$span(
        style = "font-size:14px; font-weight:500; color:#F4F6F5;",
        "SEIR Dashboard"
      ),

      # Centre: active dataset indicator
      tags$span(
        textOutput(ns("active_dataset"), inline = TRUE),
        style = paste(
          "font-size:11px;",
          "color:rgba(244,246,245,0.55);",
          "font-style:italic;"
        )
      ),

      # Right: navigation buttons
      tags$div(
        style = "display:flex; gap:6px; align-items:center;",

        # Home button — neutral outline on dark background
        actionButton(
          ns("btn_home"), "Home",
          style = paste(
            "font-size:11px;",
            "padding:4px 12px;",
            "border-radius:5px;",
            "background:transparent;",
            "border:0.5px solid rgba(244,246,245,0.3);",
            "color:#F4F6F5;"
          )
        ),

        # Simple View — disabled, Coming soon tooltip
        # Raw <button> so disabled + title work in all browsers
        tags$button(
          "Simple",
          disabled = "disabled",
          title    = "Coming soon",
          style    = paste(
            "font-size:11px;",
            "padding:4px 12px;",
            "border-radius:5px;",
            "background:transparent;",
            "border:0.5px solid rgba(244,246,245,0.15);",
            "color:rgba(244,246,245,0.3);",
            "cursor:not-allowed;"
          )
        ),

        # Advanced button — orange accent outline (active state)
        actionButton(
          ns("btn_advanced"), "Advanced",
          style = paste(
            "font-size:11px;",
            "padding:4px 12px;",
            "border-radius:5px;",
            "background:transparent;",
            "border:0.5px solid #F59342;",
            "color:#F59342;"
          )
        )
      )
    )
  )
}


# ------------------------------------------------------------
# Function: mod_menu_server()
# Description:
#   Server logic for the navigation menu. Renders the active
#   dataset label and wires navigation buttons to screen().
# Parameters:
#   id               – Shiny module identifier.
#   screen           – reactiveVal(character); active view.
#   dataset_selector – reactiveVal(character); active source key.
# Returns:
#   None (side effects only).
# ------------------------------------------------------------
mod_menu_server <- function(id, screen, dataset_selector) {
  moduleServer(id, function(input, output, session) {

    # --- Reactive block: render active dataset label ---
    output$active_dataset <- renderText({
      ds <- dataset_selector()
      if (is.null(ds)) return("No dataset loaded")
      paste("Dataset:", toupper(ds))
    })
    # --- End of reactive block ---

    # --- Reactive block: Home button ---
    observeEvent(input$btn_home, {
      screen("entry")
    })
    # --- End of reactive block ---

    # btn_simple intentionally omitted — button is disabled in UI

    # --- Reactive block: Advanced button ---
    observeEvent(input$btn_advanced, {
      screen("advanced")
    })
    # --- End of reactive block ---
  })
}
