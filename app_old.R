# ============================================================
# File: app.R
# ------------------------------------------------------------
# Description: Main SEIR Shiny app integrating Entry,
#              Menu, Simple and Advanced Views.
# ============================================================

library(shiny)
library(shinyjs)
source("R/global.R")

mods <- list.files("R", pattern = "^mod_.*\\.R$", full.names = TRUE)
sapply(mods, source)

ui <- fluidPage(
  useShinyjs(),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")  # << aquí
  ),
  uiOutput("main_ui")
)

server <- function(input, output, session) {
  
  screen <- reactiveVal("entry")
  dataset_selector <- reactiveVal(NULL)
  dataset_loaded <- reactiveVal(NULL)
  trigger_sim <- reactiveVal(0)
  
  output$main_ui <- renderUI({
    current <- screen()
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
  
  mod_entry_server("entry", screen, dataset_selector, dataset_loaded, trigger_sim)
  mod_menu_server("menu", screen, dataset_selector)
  
  # --- Launch model when entering Advanced View ---
  observe({
    req(screen() == "advanced", dataset_loaded())
    mod_server("seir_server", reactive({ dataset_selector() }))
  })
}

shinyApp(ui, server)
