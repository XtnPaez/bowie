# ============================================================
# File: mod_server_reactivity.R
# ------------------------------------------------------------
# Description: Centralises reactive logic between server modules
# ensuring synchronisation among data, model, and visualisation
# layers (data → model → viz).
# Author: Cristian Paez
# Created: 2025-11-07
# ============================================================

# ------------------------------------------------------------
# Function: mod_server_reactivity()
# Description:
#   Handles global reactivity coordination between dataset,
#   model simulation, and visualisation updates. Ensures
#   consistent state propagation across modules.
# Parameters:
#   id – Shiny module identifier.
#   app_params – reactiveValues storing model parameters.
#   dataset – reactive dataset (from Data Hub or mock data).
#   model_output – reactive model results from SEIR module.
# Returns:
#   None (side effects: triggers simulations and UI refresh).
# ------------------------------------------------------------
mod_server_reactivity <- function(id, app_params, dataset, model_output) {
  moduleServer(id, function(input, output, session) {
    
    # --- Reactive block: dataset change triggers new simulation ---
    observeEvent(dataset(), {
      log_message("INFO",
                  "Dataset updated; triggering new simulation",
                  .module = "SERVER_REACTIVITY")
      app_params$trigger_sim <- app_params$trigger_sim + 1
    })
    # --- End of reactive block ---
    
    # --- Reactive block: monitor key parameter updates ---
    observe({
      req(app_params$r0_value,
          app_params$incubation_period,
          app_params$infectious_period)
      
      log_message("DEBUG", paste(
        "Params updated:",
        "R0 =", app_params$r0_value,
        "Incubation =", app_params$incubation_period,
        "Infectious =", app_params$infectious_period
      ), .module = "SERVER_REACTIVITY")
    })
    # --- End of reactive block ---
    
    # --- Reactive block: update visualisations on model change ---
    observeEvent(model_output(), {
      log_message("INFO",
                  "Model output changed; updating visualisations",
                  .module = "SERVER_REACTIVITY")
      session$sendCustomMessage("refresh_plots", TRUE)
    })
    # --- End of reactive block ---
  })
}
