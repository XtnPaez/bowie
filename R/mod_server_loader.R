# ============================================================
# File: mod_server_loader.R
# ------------------------------------------------------------
# Description: Handles loading and validation of external
# datasets for the Data Hub Interface. Supports mock and IECS
# sources, ensuring schema consistency for SEIR simulation.
# Author: Cristian Paez
# Created: 2025-11-07
# ============================================================

# ------------------------------------------------------------
# Function: mod_server_loader()
# Description:
#   Provides server-side logic for dataset ingestion and
#   validation. Loads datasets from predefined sources and
#   checks minimal SEIR schema integrity.
# Parameters:
#   id – Shiny module identifier.
# Returns:
#   reactiveVal containing the loaded dataset.
# ------------------------------------------------------------
mod_server_loader <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    # Initialise reactive container for dataset
    dataset <- reactiveVal(NULL)
    
    # --------------------------------------------------------
    # Function: load_dataset()
    # Description:
    #   Loads dataset based on user-selected source.
    # Parameters:
    #   source – string ("mock" or "iecs").
    # Returns:
    #   Data frame with loaded dataset.
    # --------------------------------------------------------
    load_dataset <- function(source) {
      log_message("INFO", paste("Loading dataset:", source),
                  .module = "SERVER_LOADER")
      
      if (source == "mock") {
        # Load mock dataset
        data <- readRDS("data/mock_dataset.rds")
        
      } else if (source == "iecs") {
        # Load IECS dataset
        load("data/iecs_data.RData")
        data <- iecs_data
        
      } else {
        stop("Unknown dataset source.")
      }
      
      return(data)
    }
    
    # --------------------------------------------------------
    # Function: validate_dataset()
    # Description:
    #   Validates that dataset contains mandatory columns for
    #   SEIR model compatibility.
    # Parameters:
    #   data – data frame to validate.
    # Returns:
    #   TRUE if schema is valid; stops otherwise.
    # --------------------------------------------------------
    validate_dataset <- function(data) {
      required_cols <- c("time", "S", "E", "I", "R")
      missing <- setdiff(required_cols, names(data))
      
      if (length(missing) > 0) {
        stop(paste("Dataset missing required columns:",
                   paste(missing, collapse = ", ")))
      }
      
      return(TRUE)
    }
    
    # --- Reactive block: trigger dataset load ---
    observeEvent(input$load_dataset_trigger, {
      req(input$dataset_source)
      
      # Load and validate dataset
      data <- load_dataset(input$dataset_source)
      validate_dataset(data)
      dataset(data)
      
      log_message("INFO",
                  "Dataset loaded and validated successfully",
                  .module = "SERVER_LOADER")
    })
    # --- End of reactive block ---
    
    # Return reactive dataset
    return(dataset)
  })
}
