# ============================================================
# File: mod_server_loader.R
# ------------------------------------------------------------
# Description: Handles dataset loading and schema validation
#              for the Data Hub Interface.
# ============================================================

mod_server_loader <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    load_dataset <- function(source) {
      data <- NULL
      if (source == "mock" && file.exists("data/mock_dataset.rds")) {
        data <- readRDS("data/mock_dataset.rds")
      }
      
      if (source == "iecs" && file.exists("data/iecs_data.RData")) {
        load("data/iecs_data.RData", envir = environment())
        # Extract simplified structure if object is a list
        if (is.list(iecs_data)) {
          params <- iecs_data$parametros
          pop <- iecs_data$poblacion
          start_date <- as.Date("2020-03-01")
          days <- 200
          df <- data.frame(
            time = 0:days,
            date = start_date + 0:days,
            S = pop - 10000 - 0:days * 10,
            E = 500 + sin(0:days / 10) * 200,
            I = 10000 + cos(0:days / 15) * 500,
            R = 0:days * 50
          )
          data <- df
        }
      }
      
      if (is.null(data)) log_message("WARN", paste("Dataset not found:", source), .module = "SERVER_LOADER")
      return(data)
    }
    
    validate_dataset <- function(data) {
      req(is.data.frame(data))
      required_cols <- c("time", "S", "E", "I", "R")
      missing <- setdiff(required_cols, names(data))
      if (length(missing) > 0) return(FALSE)
      TRUE
    }
    
    loader <- function(source) {
      data <- load_dataset(source)
      if (is.null(data)) return(NULL)
      if (!validate_dataset(data)) return(NULL)
      log_message("INFO", paste(source, "dataset loaded OK"), .module = "SERVER_LOADER")
      return(data)
    }
    
    return(loader)
  })
}
