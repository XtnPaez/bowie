# global.R
# Este archivo contiene las configuraciones globales y carga de librerías necesarias.

# --- Librerías principales ---
library(shiny)
library(dplyr)
library(bslib)       # Para temas
library(deSolve)     # Para resolver ecuaciones diferenciales (EDOs)
library(ggplot2)     # Para visualizaciones
library(lubridate)   # Para manejo de fechas
library(RcppRoll)    # Para rolling sum (ocupación de UCI)
library(tidyr)       # Para replace_na(), pivot_longer, etc.
library(scales)      # Para formato de ejes (scales::comma)
library(purrr)       # Para listas de parámetros
library(plotly)      # Para gráficos interactivos
library(shinyjs)     # Para UI
options(scipen = 999)

# --- Definiciones globales ---
POPULATION_ARGENTINA <- 45000000

# Parámetros básicos del modelo SEIR
INITIAL_R0 <- 2.5
INITIAL_INCUBATION_PERIOD <- 5
INITIAL_INFECTIOUS_PERIOD <- 7
INITIAL_IFR <- 0.01  # 1%

# Parámetros de simulación de recursos
INITIAL_ICU_RATE <- 0.136
INITIAL_VENTILATOR_RATE <- 0.02
INITIAL_HOSPITAL_STAY_DAYS <- 10
INITIAL_ICU_CAPACITY <- 6000
INITIAL_VENTILATOR_AVAILABILITY <- 2000
INITIAL_HEALTHCARE_STAFF <- 10000

# Fechas por defecto
START_DATE <- as.Date("2020-03-01")
END_DATE   <- as.Date("2021-03-01")

# --- Cargar funciones utilitarias ---
utils_path <- file.path("R", "utils")
if (dir.exists(utils_path)) {
  utils_files <- list.files(utils_path, pattern = "\\.R$", full.names = TRUE)
  sapply(utils_files, source)
  message(sprintf("Se cargaron %d archivos de utilidades desde %s", length(utils_files), utils_path))
} else {
  warning("⚠️  No se encontró el directorio R/utils/. Las funciones log_message(), validate_params(), etc. no estarán disponibles.")
}