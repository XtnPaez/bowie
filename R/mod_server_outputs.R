# mod_server_outputs.R
# Define outputs principales del servidor: tablas, métricas y descargas.

mod_server_outputs <- function(id, model_data) {
  moduleServer(id, function(input, output, session) {
    
    # Tabla resumida de resultados
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
    
    # Descarga de resultados
    output$download_results <- downloadHandler(
      filename = function() {
        paste0("SEIR_results_", Sys.Date(), ".csv")
      },
      content = function(file) {
        write.csv(model_data(), file, row.names = FALSE)
      }
    )
    
    # Indicadores principales (para UI futura)
    output$kpi_cases <- renderText({
      req(model_data())
      paste0(format(round(max(model_data()$Cumulative_Cases)), big.mark = ","), " total cases")
    })
    
    output$kpi_deaths <- renderText({
      req(model_data())
      paste0(format(round(max(model_data()$Cumulative_Deaths)), big.mark = ","), " total deaths")
    })
  })
}
