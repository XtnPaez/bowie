# utils_helpers.R
# Numeric helpers and safe ODE wrapper

clamp <- function(x, minv, maxv) pmax(minv, pmin(x, maxv))
percent_to_prop <- function(x_pct) x_pct / 100
coalesce_num <- function(x, y) ifelse(is.na(x), y, x)
not_null <- function(x) !is.null(x)

safe_ode <- function(y, times, func, parms, method = "lsoda", .module = "MODEL") {
  tryCatch({
    with_timing({
      deSolve::ode(y = y, times = times, func = func, parms = parms, method = method)
    }, .module = .module, .label = "ode_integration")
  }, error = function(e) {
    log_message("ERROR", "Falla en integración ODE", .module, error = conditionMessage(e))
    stop("Error resolviendo el sistema SEIR. Revise parámetros y estados iniciales.", call. = FALSE)
  })
}
