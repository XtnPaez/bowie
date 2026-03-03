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
DATA_DIR  <- "data"
CACHE_DIR <- file.path(DATA_DIR, "cache")
if (!dir.exists(CACHE_DIR)) dir.create(CACHE_DIR, recursive = TRUE)

# ============================================================
# Function: load_iecs_data()
# ------------------------------------------------------------
# Description:
#   Loads the IECS (Santoro) dataset from data/iecs_data.RData
#   and returns it as a structured list compatible with the
#   SEIR model parameter contract.
# Returns:
#   Named list with elements: parametros, recursos, poblacion.
# ============================================================
load_iecs_data <- function() {
  file_path <- file.path(DATA_DIR, "iecs_data.RData")

  if (!file.exists(file_path)) {
    stop(paste(
      "IECS dataset not found at", file_path,
      "— please ensure iecs_data.RData is present in the data/ folder."
    ))
  }

  # load() injects objects into a local environment to avoid
  # polluting the global workspace
  env <- new.env(parent = emptyenv())
  load(file_path, envir = env)

  if (!exists("iecs_data", envir = env)) {
    stop("iecs_data.RData loaded but object 'iecs_data' was not found inside it.")
  }

  iecs <- env$iecs_data

  # --- Normalise legacy field names ---
  # Earlier versions used INICIAL_ prefix; standardise to INITIAL_
  if (!is.null(iecs$recursos$INICIAL_HEALTHCARE_STAFF) &&
      is.null(iecs$recursos$INITIAL_HEALTHCARE_STAFF)) {
    iecs$recursos$INITIAL_HEALTHCARE_STAFF <- iecs$recursos$INICIAL_HEALTHCARE_STAFF
    iecs$recursos$INICIAL_HEALTHCARE_STAFF <- NULL
  }

  log_message("INFO", "IECS dataset loaded successfully",
              .module = "DATA_INTERFACE")

  return(iecs)
}

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
    file_path <- file.path(DATA_DIR, "mock_dataset.rds")
    if (!file.exists(file_path))
      stop("Mock dataset not found at data/mock_dataset.rds")
    data <- readRDS(file_path)

  } else if (source == "iecs") {
    iecs <- load_iecs_data()

    # Build a SEIR-compatible data frame from IECS structure
    pop        <- iecs$poblacion
    start_date <- as.Date("2020-03-01")
    days       <- 200

    data <- data.frame(
      time = 0:days,
      date = start_date + 0:days,
      S    = pop - 10000 - 0:days * 10,
      E    = 500 + sin(0:days / 10) * 200,
      I    = 10000 + cos(0:days / 15) * 500,
      R    = 0:days * 50
    )

  } else if (source == "file") {
    if (is.null(params$path))
      stop("params$path is required for source = 'file'")
    ext <- tools::file_ext(params$path)

    if (ext == "csv") {
      data <- read.csv(params$path, stringsAsFactors = FALSE)
    } else if (ext %in% c("rds", "RData")) {
      env2 <- new.env(parent = emptyenv())
      load(params$path, envir = env2)
      data <- get(ls(env2)[1], envir = env2)
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
#   Saves a validated dataset into /data/cache/.
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
    Name    = basename(files),
    Path    = normalizePath(files),
    Size_MB = round(file.info(files)$size / 1024^2, 3)
  )
}

# ============================================================
# Local self-test (interactive sessions only)
# ============================================================
if (interactive()) {
  log_message("INFO", "=== Data Hub self-test ===", .module = "DATA_INTERFACE")
  df   <- get_data("mock")
  validate_schema(df)
  path <- save_dataset(df, "test_mock")
  print(list_datasets())
}
