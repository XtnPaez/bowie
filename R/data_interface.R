# ============================================================
# R/data_interface.R
# ------------------------------------------------------------
# Data Hub Interface
# Unifica carga, validación y persistencia de datasets.
# Implementa funciones genéricas para acceder a datos desde
# distintas fuentes (mock, IECS, CSV/API) y asegurar esquemas válidos.
# ============================================================

# --- Dependencias ---
source_if_exists <- function(path) if (file.exists(path)) source(path)
source_if_exists("R/utils/utils_validation.R")
source_if_exists("R/utils/utils_logging.R")

# --- Rutas base ---
DATA_DIR <- "data"
CACHE_DIR <- file.path(DATA_DIR, "cache")
if (!dir.exists(CACHE_DIR)) dir.create(CACHE_DIR, recursive = TRUE)

# ============================================================
# 1. get_data(source, params)
# ------------------------------------------------------------
# Devuelve un dataset según la fuente seleccionada:
# - "mock": dataset de prueba simulado
# - "iecs": dataset del IECS (si existe en /data/)
# - "file": ruta manual a CSV o RData
# ============================================================

get_data <- function(source = "mock", params = list()) {
  log_message("INFO", paste("get_data() loading source:", source), .module = "DATA_INTERFACE")
  
  if (source == "mock") {
    file_path <- file.path(DATA_DIR, "mock_dataset.rds")
    if (!file.exists(file_path)) stop("Mock dataset not found at data/mock_dataset.rds")
    data <- readRDS(file_path)
    
  } else if (source == "iecs") {
    file_path <- file.path(DATA_DIR, "iecs_data.RData")
    if (!file.exists(file_path)) stop("IECS dataset not found at data/iecs_data.RData")
    load(file_path)
    data <- iecs_data
    
  } else if (source == "file") {
    req(params$path)
    ext <- tools::file_ext(params$path)
    if (ext == "csv") {
      data <- read.csv(params$path, stringsAsFactors = FALSE)
    } else if (ext %in% c("rds", "RData")) {
      load(params$path)
    } else {
      stop("Unsupported file format")
    }
    
  } else {
    stop(paste("Unknown data source:", source))
  }
  
  validate_schema(data)
  return(data)
}

# ============================================================
# 2. validate_schema(data)
# ------------------------------------------------------------
# Verifica que el dataset tenga las columnas requeridas y
# que los tipos sean coherentes para el modelo SEIR.
# ============================================================

validate_schema <- function(data) {
  required_cols <- c("time", "S", "E", "I", "R")
  missing <- setdiff(required_cols, names(data))
  if (length(missing) > 0) {
    log_message("ERROR", paste("Missing columns:", paste(missing, collapse = ", ")), .module = "DATA_INTERFACE")
    stop(paste("Dataset schema invalid:", paste(missing, collapse = ", ")))
  }
  
  # Validación básica de tipos
  for (col in required_cols) {
    if (!is.numeric(data[[col]])) {
      stop(paste("Column", col, "must be numeric"))
    }
  }
  
  log_message("INFO", "Schema validated successfully", .module = "DATA_INTERFACE")
  return(TRUE)
}

# ============================================================
# 3. save_dataset(data, name)
# ------------------------------------------------------------
# Guarda un dataset validado en /data/cache/ bajo nombre único.
# ============================================================

save_dataset <- function(data, name = NULL) {
  validate_schema(data)
  if (is.null(name)) name <- paste0("dataset_", format(Sys.time(), "%Y%m%d_%H%M%S"))
  
  file_path <- file.path(CACHE_DIR, paste0(name, ".rds"))
  saveRDS(data, file_path)
  log_message("INFO", paste("Dataset saved to cache:", file_path), .module = "DATA_INTERFACE")
  return(file_path)
}

# ============================================================
# 4. list_datasets()
# ------------------------------------------------------------
# Lista los datasets actualmente guardados en /data/cache/.
# ============================================================

list_datasets <- function() {
  files <- list.files(CACHE_DIR, pattern = "\\.rds$", full.names = TRUE)
  if (length(files) == 0) return(data.frame(Name = NA, Path = NA, Size_MB = NA))
  
  data.frame(
    Name = basename(files),
    Path = normalizePath(files),
    Size_MB = round(file.info(files)$size / 1024^2, 3)
  )
}

# ============================================================
# 5. Prueba local (ejemplo)
# ------------------------------------------------------------
# Ejecutar manualmente para verificar funcionamiento.
# ============================================================

if (interactive()) {
  log_message("INFO", "=== Data Hub self-test ===", .module = "DATA_INTERFACE")
  
  df <- get_data("mock")
  validate_schema(df)
  path <- save_dataset(df, "test_mock")
  print(list_datasets())
}
