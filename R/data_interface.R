# ============================================================
# File: data_interface.R
# ------------------------------------------------------------
# Description: Central Data Hub Interface.
# Provides unified functions to load, validate, and persist
# datasets from different sources (mock, IECS, CSV/API).
# Ensures schema compatibility for SEIR models.
# Author: Cristian Paez
# Created: 2025-11-07
# ============================================================

# --- Dependencies ---
source_if_exists <- function(path) if (file.exists(path)) source(path)
source_if_exists("R/utils/utils_validation.R")
source_if_exists("R/utils/utils_logging.R")

# --- Base directories ---
DATA_DIR <- "data"
CACHE_DIR <- file.path(DATA_DIR, "cache")
if (!dir.exists(CACHE_DIR)) dir.create(CACHE_DIR, recursive = TRUE)

# ============================================================
# Function: get_data()
# ------------------------------------------------------------
# Description:
#   Returns a dataset based on the selected source.
# Parameters:
#   source – character; one of "mock", "iecs", or "file".
#   params – list; used for manual file loading.
# Returns:
#   Data frame containing the loaded dataset.
# ============================================================

get_data <- function(source = "mock", params = list()) {
  log_message("INFO", paste("get_data() loading source:", source),
              .module = "DATA_INTERFACE")
  
  if (source == "mock") {
    # Load mock dataset from local cache
    file_path <- file.path(DATA_DIR, "mock_dataset.rds")
    if (!file.exists(file_path))
      stop("Mock dataset not found at data/mock_dataset.rds")
    data <- readRDS(file_path)
    
  } else if (source == "iecs") {
    # Load IECS dataset (RData format)
    file_path <- file.path(DATA_DIR, "iecs_data.RData")
    if (!file.exists(file_path))
      stop("IECS dataset not found at data/iecs_data.RData")
    load(file_path)
    data <- iecs_data
    
  } else if (source == "file") {
    # Load external file manually
    req(params$path)
    ext <- tools::file_ext(params$path)
    
    if (ext == "csv") {
      data <- read.csv(params$path, stringsAsFactors = FALSE)
    } else if (ext %in% c("rds", "RData")) {
      load(params$path)
    } else {
      stop("Unsupported file format provided")
    }
    
  } else {
    stop(paste("Unknown data source:", source))
  }
  
  validate_schema(data)
  return(data)
}

# ============================================================
# Function: validate_schema()
# ------------------------------------------------------------
# Description:
#   Validates dataset structure for SEIR model compatibility.
#   Ensures required columns exist and have numeric types.
# Parameters:
#   data – data frame to validate.
# Returns:
#   TRUE if schema is valid, stops otherwise.
# ============================================================

validate_schema <- function(data) {
  required_cols <- c("time", "S", "E", "I", "R")
  missing <- setdiff(required_cols, names(data))
  
  if (length(missing) > 0) {
    log_message("ERROR",
                paste("Missing columns:", paste(missing, collapse = ", ")),
                .module = "DATA_INTERFACE")
    stop(paste("Dataset schema invalid:",
               paste(missing, collapse = ", ")))
  }
  
  # Check column types
  for (col in required_cols) {
    if (!is.numeric(data[[col]])) {
      stop(paste("Column", col, "must be numeric"))
    }
  }
  
  log_message("INFO", "Schema validated successfully",
              .module = "DATA_INTERFACE")
  return(TRUE)
}

# ============================================================
# Function: save_dataset()
# ------------------------------------------------------------
# Description:
#   Saves a validated dataset into /data/cache/ using a unique name.
# Parameters:
#   data – data frame already validated.
#   name – optional custom dataset name.
# Returns:
#   Full file path of the saved dataset.
# ============================================================

save_dataset <- function(data, name = NULL) {
  validate_schema(data)
  if (is.null(name))
    name <- paste0("dataset_", format(Sys.time(), "%Y%m%d_%H%M%S"))
  
  file_path <- file.path(CACHE_DIR, paste0(name, ".rds"))
  saveRDS(data, file_path)
  
  log_message("INFO", paste("Dataset saved to cache:", file_path),
              .module = "DATA_INTERFACE")
  
  return(file_path)
}

# ============================================================
# Function: list_datasets()
# ------------------------------------------------------------
# Description:
#   Lists all cached datasets within /data/cache/.
# Returns:
#   Data frame with Name, Path, and Size_MB.
# ============================================================

list_datasets <- function() {
  files <- list.files(CACHE_DIR, pattern = "\\.rds$", full.names = TRUE)
  
  if (length(files) == 0)
    return(data.frame(Name = NA, Path = NA, Size_MB = NA))
  
  data.frame(
    Name = basename(files),
    Path = normalizePath(files),
    Size_MB = round(file.info(files)$size / 1024^2, 3)
  )
}

# ============================================================
# Local self-test (interactive only)
# ------------------------------------------------------------
# Purpose:
#   Provides manual verification of loading, validation,
#   saving, and listing of datasets.
# ============================================================

if (interactive()) {
  log_message("INFO", "=== Data Hub self-test ===", .module = "DATA_INTERFACE")
  
  df <- get_data("mock")
  validate_schema(df)
  path <- save_dataset(df, "test_mock")
  print(list_datasets())
}
