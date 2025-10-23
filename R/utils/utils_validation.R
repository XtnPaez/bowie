# utils_validation.R
# Validate epidemiological and resource parameters

validate_params <- function(params) {
  stop_if_missing <- function(nm) {
    if (is.null(params[[nm]])) stop(sprintf("Parámetro faltante: %s", nm), call. = FALSE)
  }
  req_names <- c("r0_value","incubation_period","infectious_period","ifr_value",
                 "icu_admission_rate","ventilator_usage_rate",
                 "start_date","end_date","population")
  lapply(req_names, stop_if_missing)
  
  num_pos <- c("r0_value","incubation_period","infectious_period","population")
  for (nm in num_pos) if (!is.numeric(params[[nm]]) || params[[nm]] <= 0)
    stop(sprintf("'%s' debe ser numérico y > 0", nm), call. = FALSE)
  
  pct_01 <- c("ifr_value","icu_admission_rate","ventilator_usage_rate")
  for (nm in pct_01) if (!is.numeric(params[[nm]]) || params[[nm]] < 0 || params[[nm]] > 100)
    stop(sprintf("'%s' debe estar en el rango [0,100]", nm), call. = FALSE)
  
  if (as.Date(params$end_date) < as.Date(params$start_date))
    stop("end_date no puede ser anterior a start_date", call. = FALSE)
  
  invisible(params)
}

validate_initial_state <- function(S, E, I, R, population, tol = 1e-6) {
  for (v in c(S,E,I,R)) if (!is.numeric(v) || v < 0) stop("Estados iniciales deben ser >= 0", call. = FALSE)
  tot <- S + E + I + R
  if (abs(tot - population) > max(population * 1e-6, tol))
    stop("S+E+I+R debe igualar 'population' (tolerancia numérica)", call. = FALSE)
  TRUE
}