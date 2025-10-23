# mod_server_loader.R
# Maneja la carga y validación de datasets externos para el Data Hub Interface.

mod_server_loader <- function(id) {
  moduleServer(id, function(input, output, session) {
    dataset <- reactiveVal(NULL)
    
    # Cargar dataset según la fuente seleccionada
    load_dataset <- function(source) {
      log_message("INFO", paste("Loading dataset:", source), .module = "SERVER_LOADER")
      
      if (source == "mock") {
        # Dataset simulado desde mod_data
        data <- readRDS("data/mock_dataset.rds")
      } else if (source == "iecs") {
        load("data/iecs_data.RData")
        data <- iecs_data
      } else {
        stop("Unknown dataset source.")
      }
      data
    }
    
    # Validar estructura mínima
    validate_dataset <- function(data) {
      required_cols <- c("time", "S", "E", "I", "R")
      missing <- setdiff(required_cols, names(data))
      if (length(missing) > 0) {
        stop(paste("Dataset missing required columns:", paste(missing, collapse = ", ")))
      }
      TRUE
    }
    
    observeEvent(input$load_dataset_trigger, {
      req(input$dataset_source)
      data <- load_dataset(input$dataset_source)
      validate_dataset(data)
      dataset(data)
      log_message("INFO", "Dataset loaded and validated successfully", .module = "SERVER_LOADER")
    })
    
    return(dataset)
  })
}
