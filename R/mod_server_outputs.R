# ============================================================
# File: mod_server_outputs.R
# ------------------------------------------------------------
# Description: Defines main server outputs, including summary
# tables, downloadable results, and KPI indicators for the
# SEIR simulation results.
# Author: Cristian Paez
# Created: 2025-11-07
# ============================================================

# ------------------------------------------------------------
# Function: mod_server_outputs()
# Description:
#   Manages key outputs of the SEIR model results, including:
#     • Summary result table
#     • CSV download handler
#     • KPI text indicators (cases and deaths)
# Parameters:
#   id – Shiny module identifier.
#   model_data – reactiveVal containing SEIR simulation results.
# Returns:
#   Server-side outputs bound to UI elements.
# ------------------------------------------------------------
mod_server_outputs <- function(id, model_data) {
  moduleServer(id, function(input, output, session) {
    
    # --- Render summary table with last model values ---
    output$summary_table <- renderTable({
      req(model_data())
      df <- model_data()
      tail_df <- tail(df, 1)
      
      data.frame(
        "Cumulative Cases" = round(tail_df$Cumulative_Cases),
        "Cumulative Deaths" = round(tail_df$Cumulative_Deaths),
        "ICU Occupancy (Sim)" = round(tail_df$ICU_Occupancy_Sim),
        "Ventilator Use (Sim)" = round(tail_df$Vent_Usage_Sim)
      )
    })
    
    # --- Define download handler for CSV export ---
    output$download_results <- downloadHandler(
      filename = function() {
        paste0("SEIR_results_", Sys.Date(), ".csv")
      },
      content = function(file) {
        write.csv(model_data(), file, row.names = FALSE)
      }
    )
    
    # --- KPI: total cumulative cases ---
    output$kpi_cases <- renderText({
      req(model_data())
      paste0(
        format(round(max(model_data()$Cumulative_Cases)), big.mark = ","),
        " total cases"
      )
    })
    
    # --- KPI: total cumulative deaths ---
    output$kpi_deaths <- renderText({
      req(model_data())
      paste0(
        format(round(max(model_data()$Cumulative_Deaths)), big.mark = ","),
        " total deaths"
      )
    })
  })
}
