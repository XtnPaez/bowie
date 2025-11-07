# ============================================================
# File: mod_viz.R
# ------------------------------------------------------------
# Description: Handles generation of SEIR model visualisations,
# including compartment curves, cumulative cases/deaths, and
# critical resource demand vs. capacity plots.
# Author: Cristian Paez
# Created: 2025-11-07
# ============================================================

# ------------------------------------------------------------
# Function: viz_plot_server()
# Description:
#   Manages interactive plots derived from SEIR model output.
#   Generates three visualisation panels:
#     1. SEIR compartment dynamics
#     2. Cumulative cases and deaths
#     3. Critical resource demand and capacity
# Parameters:
#   id – Shiny module identifier.
#   model_data – reactive dataset from SEIR model.
#   icu_capacity_input – reactive numeric input for ICU capacity.
#   ventilator_availability_input – reactive numeric input for ventilator availability.
# Returns:
#   Server-side visualisation outputs.
# ------------------------------------------------------------
viz_plot_server <- function(id, model_data, icu_capacity_input, ventilator_availability_input) {
  moduleServer(id, function(input, output, session) {
    
    # --------------------------------------------------------
    # --- SEIR compartment curves plot ---
    # --------------------------------------------------------
    output$seir_plot <- renderPlot({
      plot_data <- model_data()
      
      if (is.null(plot_data) || nrow(plot_data) == 0) {
        cat("VIZ_MODULE: model_data() is NULL or empty for seir_plot.\n")
        return(
          ggplot() +
            annotate("text", x = 0.5, y = 0.5, label = "No data available", size = 8) +
            theme_void()
        )
      }
      req(plot_data)
      
      ggplot(plot_data, aes(x = date)) +
        geom_line(aes(y = S, colour = "Susceptible"), size = 1) +
        geom_line(aes(y = E, colour = "Exposed"), size = 1) +
        geom_line(aes(y = I, colour = "Infected"), size = 1) +
        geom_line(aes(y = R, colour = "Recovered"), size = 1) +
        labs(
          title = "Population Dynamics (SEIR)",
          x = "Date",
          y = "Number of Individuals",
          colour = "Compartment"
        ) +
        scale_y_continuous(labels = scales::comma) +
        theme_minimal() +
        theme(
          plot.title = element_text(hjust = 0.5, face = "bold", size = 16),
          axis.title = element_text(size = 12),
          axis.text = element_text(size = 10),
          legend.position = "bottom",
          legend.title = element_blank()
        ) +
        scale_colour_manual(
          values = c(
            "Susceptible" = "#4CAF50",
            "Exposed" = "#FFC107",
            "Infected" = "#F44336",
            "Recovered" = "#2196F3"
          )
        )
    })
    
    # --------------------------------------------------------
    # --- Cumulative cases and deaths plot ---
    # --------------------------------------------------------
    output$cases_deaths_plot <- renderPlot({
      plot_data <- model_data()
      
      if (is.null(plot_data) || nrow(plot_data) == 0) {
        return(
          ggplot() +
            annotate("text", x = 0.5, y = 0.5, label = "No data available", size = 8) +
            theme_void()
        )
      }
      req(plot_data)
      
      ggplot(plot_data, aes(x = date)) +
        geom_line(aes(y = Cumulative_Cases, colour = "Cumulative Cases"), size = 1) +
        geom_line(aes(y = Cumulative_Deaths, colour = "Cumulative Deaths"), size = 1) +
        labs(
          title = "Simulated Cumulative Cases and Deaths",
          x = "Date",
          y = "Cumulative Number",
          colour = "Metric"
        ) +
        scale_y_continuous(labels = scales::comma) +
        theme_minimal() +
        theme(
          plot.title = element_text(hjust = 0.5, face = "bold", size = 16),
          axis.title = element_text(size = 12),
          axis.text = element_text(size = 10),
          legend.position = "bottom",
          legend.title = element_blank()
        ) +
        scale_colour_manual(
          values = c(
            "Cumulative Cases" = "#FF9800",
            "Cumulative Deaths" = "#607D8B"
          )
        )
    })
    
    # --------------------------------------------------------
    # --- Critical resource pressure plot ---
    # --------------------------------------------------------
    output$resource_pressure_plot <- renderPlot({
      cat("VIZ_MODULE: resource_pressure_plot rendering.\n")
      plot_data_raw <- model_data()
      
      current_icu_capacity <- icu_capacity_input()
      current_ventilator_availability <- ventilator_availability_input()
      
      if (is.null(plot_data_raw) || nrow(plot_data_raw) == 0) {
        cat("VIZ_MODULE: model_data() is NULL or empty for resource plot.\n")
        return(
          ggplot() +
            annotate("text", x = 0.5, y = 0.5, label = "No data available", size = 8) +
            theme_void()
        )
      }
      req(plot_data_raw)
      
      # Prepare demand dataset
      demand_plot_data <- plot_data_raw %>%
        select(date, ICU_Occupancy_Sim, Vent_Usage_Sim) %>%
        pivot_longer(
          cols = -date,
          names_to = "Metric",
          values_to = "Value"
        ) %>%
        mutate(
          Resource_Category = case_when(
            grepl("ICU", Metric) ~ "ICU",
            grepl("Vent", Metric) ~ "Ventilators",
            TRUE ~ NA_character_
          ),
          Metric_Label = "Demand"
        ) %>%
        filter(!is.na(Resource_Category))
      
      # Capacity data for reference
      capacity_data_icu <- data.frame(
        date = unique(demand_plot_data$date),
        Value = current_icu_capacity,
        Metric = "ICU_Capacity_Current",
        Resource_Category = "ICU",
        Metric_Label = "Capacity"
      )
      
      capacity_data_vent <- data.frame(
        date = unique(demand_plot_data$date),
        Value = current_ventilator_availability,
        Metric = "Ventilator_Availability_Current",
        Resource_Category = "Ventilators",
        Metric_Label = "Capacity"
      )
      
      combined_plot_data <- bind_rows(demand_plot_data, capacity_data_icu, capacity_data_vent)
      
      # Identify periods of excess demand
      ribbon_data <- combined_plot_data %>%
        filter(Metric_Label %in% c("Demand", "Capacity")) %>%
        pivot_wider(
          names_from = Metric_Label,
          values_from = Value,
          id_cols = c(date, Resource_Category),
          values_fill = list(Value = 0)
        ) %>%
        mutate(
          Demand = as.numeric(Demand),
          Capacity = as.numeric(Capacity)
        ) %>%
        filter(Demand > Capacity)
      
      # Build plot
      ggplot(combined_plot_data, aes(x = date, y = Value, colour = Metric_Label, linetype = Metric_Label)) +
        geom_line(size = 1) +
        geom_ribbon(
          data = ribbon_data,
          aes(ymin = Capacity, ymax = Demand, x = date, fill = "Demand Exceeded"),
          alpha = 0.5,
          inherit.aes = FALSE
        ) +
        facet_wrap(~Resource_Category, scales = "free_y", ncol = 1) +
        labs(
          title = "Critical Resource Demand and Capacity",
          x = "Date",
          y = "Number of Units",
          colour = "Metric Type",
          linetype = "Metric Type",
          fill = "Alert"
        ) +
        scale_y_continuous(labels = scales::comma) +
        theme_minimal() +
        theme(
          plot.title = element_text(hjust = 0.5, face = "bold", size = 16),
          axis.title = element_text(size = 12),
          axis.text = element_text(size = 10),
          legend.position = "bottom",
          legend.title = element_blank(),
          strip.text = element_text(size = 12, face = "bold")
        ) +
        scale_colour_manual(values = c("Demand" = "#FF5722", "Capacity" = "#00BCD4")) +
        scale_linetype_manual(values = c("Demand" = "solid", "Capacity" = "dashed")) +
        scale_fill_manual(values = c("Demand Exceeded" = "#FFCDD2"), name = "Alert")
    })
  })
}
