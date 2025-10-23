# mod_server_reactivity.R
# Centraliza la lógica reactiva entre módulos del servidor (data → model → viz).

mod_server_reactivity <- function(id, app_params, dataset, model_output) {
  moduleServer(id, function(input, output, session) {
    
    # Control de sincronización entre datasets y modelo
    observeEvent(dataset(), {
      log_message("INFO", "Dataset updated; triggering new simulation", .module = "SERVER_REACTIVITY")
      app_params$trigger_sim <- app_params$trigger_sim + 1
    })
    
    # Observador de actualizaciones de parámetros críticos
    observe({
      req(app_params$r0_value, app_params$incubation_period, app_params$infectious_period)
      log_message("DEBUG", paste(
        "Params updated:",
        "R0 =", app_params$r0_value,
        "Incubation =", app_params$incubation_period,
        "Infectious =", app_params$infectious_period
      ), .module = "SERVER_REACTIVITY")
    })
    
    # Actualización automática de visualizaciones
    observeEvent(model_output(), {
      log_message("INFO", "Model output changed; updating visualisations", .module = "SERVER_REACTIVITY")
      session$sendCustomMessage("refresh_plots", TRUE)
    })
  })
}
