# ============================================================
# File: data-raw/prepare_iecs.R
# ------------------------------------------------------------
# Description:
#   Reproducible preparation script for the IECS / Santoro
#   dataset. Builds the canonical .rds file consumed by
#   data_interface.R from documented parameter values.
#
#   This script is the institutional memory of how the dataset
#   was constructed. It replaces the legacy iecs_data.RData,
#   whose preparation script was not preserved in the
#   repository. All parameter values are sourced from:
#
#     Santoro A et al. Development and application of a dynamic
#     transmission model of health systems' preparedness and
#     response to COVID-19 in twenty-six Latin American and
#     Caribbean countries. PLOS Glob Public Health. 2022;
#     2(3):e0000186. https://doi.org/10.1371/journal.pgph.0000186
#
#   Additional sources for healthcare resource parameters are
#   cited inline below.
#
# Usage:
#   Run this script once from the project root to generate
#   data/iecs_data.rds. Re-run whenever source parameters
#   need to be updated.
#
#     source("data-raw/prepare_iecs.R")
#
# Output:
#   data/iecs_data.rds — named list with three elements:
#     $parametros  — epidemiological model parameters
#     $recursos    — healthcare resource parameters
#     $poblacion   — total population baseline
#
# Author: Cristian Paez
# Created: 2026-05-27
# ============================================================


# ============================================================
# 1. Epidemiological parameters
# ------------------------------------------------------------
# Source: Santoro et al. (2022), Table 1 and Methods section.
# R0 reflects the estimated basic reproduction number for
# Argentina at the start of the simulation period (March 2020),
# calibrated against national mortality data.
# ============================================================

parametros <- list(

  # Basic reproduction number — calibrated for Argentina,
  # March 2020. Santoro et al. (2022), Methods.
  R0 = 2.5,

  # Mean incubation period (days): average time from exposure
  # to becoming infectious. Santoro et al. (2022), Methods;
  # consistent with WHO COVID-19 technical guidance (2020).
  incubation_period = 5,

  # Mean infectious period (days): average time an individual
  # remains infectious. Santoro et al. (2022), Methods.
  infectious_period = 7,

  # Infection Fatality Rate — stored as a proportion [0, 1].
  # Value: 0.01 = 1%. Source: IECS seroprevalence estimates
  # for Argentina, cited in Santoro et al. (2022).
  # Note: mod_server.R normalises this to percentage [0, 100]
  # via normalise_ifr_to_pct() before passing to the UI.
  IFR = 0.01
)


# ============================================================
# 2. Healthcare resource parameters
# ------------------------------------------------------------
# Sources cited inline. All capacity values reflect Argentina
# at the start of the COVID-19 pandemic (March 2020).
# Rates are stored as proportions [0, 1]; mod_server.R
# converts them to percentages for the UI sliders.
# ============================================================

recursos <- list(

  # Total ICU beds available nationally.
  # Source: Sociedad Argentina de Terapia Intensiva (SATI).
  # https://www.scielo.org.ar/scielo.php?script=sci_arttext&pid=S0025-76802022000100035
  INITIAL_ICU_CAPACITY = 6000,

  # Total mechanical ventilators available nationally.
  # Source: SATI (2020).
  INITIAL_VENTILATOR_AVAILABILITY = 2000,

  # Healthcare staff engaged in critical COVID-19 care.
  # Source: Comes Y et al. CONICET Digital.
  # https://ri.conicet.gov.ar/bitstream/handle/11336/161336/
  INITIAL_HEALTHCARE_STAFF = 10000,

  # Proportion of infectious individuals requiring ICU admission.
  # Source: IECS model calibration; Santoro et al. (2022).
  INITIAL_ICU_RATE = 0.136,

  # Proportion of infectious individuals requiring mechanical
  # ventilation. Source: Grasselli G et al. JAMA. 2020;
  # 323(16):1574-1581. https://doi.org/10.1371/journal.pone.0246318
  INITIAL_VENTILATOR_RATE = 0.02,

  # Average hospital stay for ICU patients (days).
  # Source: IECS model / CDC guidance (2020).
  INITIAL_HOSPITAL_STAY_DAYS = 10
)


# ============================================================
# 3. Population baseline
# ------------------------------------------------------------
# Total population of Argentina used as the N in the SEIR
# model. Source: Instituto Nacional de Estadistica y Censos
# (INDEC). Proyecciones de poblacion.
# https://www.indec.gob.ar/indec/web/Nivel4-Tema-2-24-84
# ============================================================

poblacion <- 45000000


# ============================================================
# 4. Assemble canonical dataset object
# ------------------------------------------------------------
# The dataset is a named list with three top-level elements.
# This structure is the contract between data_interface.R and
# all downstream consumers (mod_server.R, mod_server_simple.R).
#
# Design note: dates are NOT stored in the dataset. Simulation
# start and end dates are parameters of the simulation run,
# not properties of the dataset. They are controlled by the
# user via dateInput() in the Advanced View parameter panel,
# and initialised from global.R (START_DATE, END_DATE).
# ============================================================

iecs_data <- list(
  parametros = parametros,
  recursos   = recursos,
  poblacion  = poblacion
)


# ============================================================
# 5. Validate structure before saving
# ------------------------------------------------------------
# Defensive checks to catch any missing fields before the
# file is written. Stops with a descriptive message if the
# structure does not match the expected contract.
# ============================================================

required_parametros <- c("R0", "incubation_period",
                         "infectious_period", "IFR")
required_recursos   <- c("INITIAL_ICU_CAPACITY",
                         "INITIAL_VENTILATOR_AVAILABILITY",
                         "INITIAL_HEALTHCARE_STAFF",
                         "INITIAL_ICU_RATE",
                         "INITIAL_VENTILATOR_RATE",
                         "INITIAL_HOSPITAL_STAY_DAYS")

missing_p <- setdiff(required_parametros, names(iecs_data$parametros))
missing_r <- setdiff(required_recursos,   names(iecs_data$recursos))

if (length(missing_p) > 0) {
  stop(paste("Missing parametros fields:",
             paste(missing_p, collapse = ", ")))
}
if (length(missing_r) > 0) {
  stop(paste("Missing recursos fields:",
             paste(missing_r, collapse = ", ")))
}
if (!is.numeric(iecs_data$poblacion) ||
    length(iecs_data$poblacion) != 1) {
  stop("poblacion must be a single numeric value.")
}

message("Structure validated successfully.")


# ============================================================
# 6. Save as .rds
# ------------------------------------------------------------
# saveRDS() stores a single R object without injecting names
# into the caller's environment — unlike save() / load() which
# use RData and require knowing the object name in advance.
# The .rds format is the canonical format for all datasets
# in this project.
# ============================================================

output_path <- file.path("data", "iecs_data.rds")

if (!dir.exists("data")) {
  dir.create("data", recursive = TRUE)
}

saveRDS(iecs_data, file = output_path)

message(sprintf(
  "IECS dataset saved to %s (%.1f KB)",
  output_path,
  file.info(output_path)$size / 1024
))


# ============================================================
# 7. Verify round-trip
# ------------------------------------------------------------
# Read back the file and confirm the structure is intact.
# ============================================================

verify <- readRDS(output_path)

stopifnot(
  identical(names(verify), c("parametros", "recursos", "poblacion")),
  verify$parametros$R0              == parametros$R0,
  verify$parametros$IFR             == parametros$IFR,
  verify$recursos$INITIAL_ICU_CAPACITY == recursos$INITIAL_ICU_CAPACITY,
  verify$poblacion                  == poblacion
)

message("Round-trip verification passed. Dataset is ready.")
message(sprintf("  R0              : %s", verify$parametros$R0))
message(sprintf("  IFR             : %s%%", verify$parametros$IFR * 100))
message(sprintf("  Incubation      : %s days", verify$parametros$incubation_period))
message(sprintf("  Infectious      : %s days", verify$parametros$infectious_period))
message(sprintf("  ICU capacity    : %s beds", verify$recursos$INITIAL_ICU_CAPACITY))
message(sprintf("  Population      : %s", format(verify$poblacion, big.mark = ",")))
