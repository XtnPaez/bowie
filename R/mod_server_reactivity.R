# ============================================================
# File: mod_server_reactivity.R
# ------------------------------------------------------------
# Description: Centralises reactive logic between server modules,
#   ensuring synchronisation among data, model, and visualisation
#   layers (data → model → viz).
#
# ⚠️ STATUS: Planned — not yet active.
#   This module is NOT currently called from app.R or mod_server.R.
#   It is retained as a scaffold for Block 5 (Simplified View)
#   when cross-module reactivity coordination will be required.
#
#   Known limitation: session$sendCustomMessage("refresh_plots")
#   has no corresponding JavaScript listener registered in the
#   client. This will need to be wired in mod_ui.R or www/custom.js
#   before activation.
#
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
#   id           – Shiny module identifier.
#   app_params   – reactiveValues storing model parameters.
#   dataset      – reactive dataset (from Data Hub or mock data).
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
    # ❌ session$sendCustomMessage("refresh_plots") requires a
    # corresponding JavaScript listener — not yet implemented.
    # Wire in mod_ui.R or www/custom.js before activating.
    observeEvent(model_output(), {
      log_message("INFO",
                  "Model output changed; updating visualisations",
                  .module = "SERVER_REACTIVITY")
      session$sendCustomMessage("refresh_plots", TRUE)
    })
    # --- End of reactive block ---
  })
}
