# mod_viz.R
# Este módulo se encarga de generar las visualizaciones interactivas.

# Función para el servidor del módulo de visualización
viz_plot_server <- function(id, model_data, icu_capacity_input, ventilator_availability_input) { # Aceptar inputs individuales
  moduleServer(id, function(input, output, session) {
    
    
    # Gráfico de las curvas SEIR
    output$seir_plot <- renderPlot({
      
      plot_data <- model_data() # Access the reactive data here
      if (is.null(plot_data) || nrow(plot_data) == 0) {
        cat("VIZ_MODULE: model_data() is NULL or empty for seir_plot, returning empty plot.\n")
        return(ggplot() + annotate("text", x = 0.5, y = 0.5, label = "Datos no disponibles", size = 8) + theme_void())
      }
      req(plot_data) # Asegurarse de que los datos del modelo estén disponibles y no sean NULL
      
      ggplot(plot_data, aes(x = date)) +
        geom_line(aes(y = S, color = "Susceptibles"), size = 1) +
        geom_line(aes(y = E, color = "Expuestos"), size = 1) +
        geom_line(aes(y = I, color = "Infectados"), size = 1) +
        geom_line(aes(y = R, color = "Recuperados"), size = 1) +
        labs(
          title = "Dinámica de la Población (SEIR)",
          x = "Fecha",
          y = "Número de Individuos",
          color = "Estado"
        ) +
        scale_y_continuous(labels = scales::comma) + # Formato de números grandes
        theme_minimal() +
        theme(
          plot.title = element_text(hjust = 0.5, face = "bold", size = 16),
          axis.title = element_text(size = 12),
          axis.text = element_text(size = 10),
          legend.position = "bottom",
          legend.title = element_blank()
        ) +
        scale_color_manual(
          values = c(
            "Susceptibles" = "#4CAF50",
            "Expuestos" = "#FFC107",
            "Infectados" = "#F44336",
            "Recuperados" = "#2196F3"
          )
        )
    }#, 
    #bg = "transparent"
    )
    
    # Gráfico de casos y muertes acumuladas
    output$cases_deaths_plot <- renderPlot({
      
      plot_data <- model_data()
      if (is.null(plot_data) || nrow(plot_data) == 0) {
        
        return(ggplot() + annotate("text", x = 0.5, y = 0.5, label = "Datos no disponibles", size = 8) + theme_void())
      }
      req(plot_data)
      
      ggplot(plot_data, aes(x = date)) +
        geom_line(aes(y = Cumulative_Cases, color = "Casos Acumulados"), size = 1) +
        geom_line(aes(y = Cumulative_Deaths, color = "Muertes Acumuladas"), size = 1) +
        labs(
          title = "Casos y Muertes Acumuladas Simuladas",
          x = "Fecha",
          y = "Número Acumulado",
          color = "Métrica"
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
        scale_color_manual(
          values = c(
            "Casos Acumulados" = "#FF9800",
            "Muertes Acumuladas" = "#607D8B"
          )
        )
    })
    
    # Gráfico de presión sobre recursos críticos
    output$resource_pressure_plot <- renderPlot({
      cat("VIZ_MODULE: resource_pressure_plot rendering.\n") # Debug print
      plot_data_raw <- model_data()
      
      # Obtener los valores de capacidad actuales directamente de los inputs reactivos
      # al ser reactive, estos se actualizan cada vez que el input numérico cambia.
      current_icu_capacity <- icu_capacity_input() # Acceso correcto a reactive()
      current_ventilator_availability <- ventilator_availability_input() # Acceso correcto a reactive()
      
      
      if (is.null(plot_data_raw) || nrow(plot_data_raw) == 0) {
        cat("VIZ_MODULE: model_data() is NULL or empty for resource plot, returning empty plot.\n")
        return(ggplot() + annotate("text", x = 0.5, y = 0.5, label = "Datos no disponibles", size = 8) + theme_void())
      }
      req(plot_data_raw) # Solo requerir que los datos del modelo estén disponibles
      
      # Preparar los datos de demanda
      demand_plot_data <- plot_data_raw %>%
        select(
          date,
          ICU_Occupancy_Sim,
          Vent_Usage_Sim
        ) %>%
        pivot_longer(
          cols = -date, # Todas las columnas excepto 'date'
          names_to = "Metric",
          values_to = "Value"
        ) %>%
        mutate(
          Resource_Category = case_when(
            grepl("ICU", Metric) ~ "UCI",
            grepl("Vent", Metric) ~ "Respiradores",
            TRUE ~ NA_character_
          ),
          Metric_Label = "Demanda" # Todas estas son métricas de demanda
        ) %>%
        filter(!is.na(Resource_Category)) # Eliminar cualquier fila que no se haya clasificado
      
      # Preparar los datos de capacidad (se generan reactivamente)
      # Esto es clave para que los cambios en la capacidad de la UI activen la actualización del gráfico
      capacity_data_icu <- data.frame(
        date = unique(demand_plot_data$date), # Usar las mismas fechas que los datos de demanda
        Value = current_icu_capacity,
        Metric = "ICU_Capacity_Current", # Nombre de métrica para UCI
        Resource_Category = "UCI",
        Metric_Label = "Capacidad"
      )
      
      capacity_data_vent <- data.frame(
        date = unique(demand_plot_data$date), # Usar las mismas fechas que los datos de demanda
        Value = current_ventilator_availability,
        Metric = "Ventilator_Availability_Current", # Nombre de métrica para Respiradores
        Resource_Category = "Respiradores",
        Metric_Label = "Capacidad"
      )
      
      # Combinar los datos de demanda y capacidad
      combined_plot_data <- bind_rows(demand_plot_data, capacity_data_icu, capacity_data_vent)
      
      # Preparar los datos específicos para el geom_ribbon de forma más segura
      ribbon_data <- combined_plot_data %>%
        filter(Metric_Label %in% c("Demanda", "Capacidad")) %>% # Filtrar solo demanda y capacidad
        pivot_wider(
          names_from = Metric_Label,
          values_from = Value,
          id_cols = c(date, Resource_Category),
          values_fill = list(Value = 0) # Rellenar NAs si una métrica no existe para una categoría
        ) %>%
        # Asegurarse de que 'Demanda' y 'Capacidad' son numéricas antes de la comparación
        mutate(
          Demanda = as.numeric(Demanda),
          Capacidad = as.numeric(Capacidad)
        ) %>%
        filter(Demanda > Capacidad) # Ahora esta comparación debería funcionar correctamente
      
      
      ggplot(combined_plot_data, aes(x = date, y = Value, color = Metric_Label, linetype = Metric_Label)) +
        geom_line(size = 1) +
        geom_ribbon(
          data = ribbon_data, # Usar los datos preparados específicamente para el ribbon
          aes(ymin = Capacidad, ymax = Demanda, x = date, fill = "Exceso de Demanda"),
          alpha = 0.5,
          inherit.aes = FALSE # Importante para que el geom_ribbon use su propio mapeo de datos
        ) +
        facet_wrap(~Resource_Category, scales = "free_y", ncol = 1) +
        labs(
          title = "Demanda y Capacidad de Recursos Críticos",
          x = "Fecha",
          y = "Número de Unidades",
          color = "Tipo de Métrica",
          linetype = "Tipo de Métrica", # Asegurar que la leyenda muestre ambos tipos
          fill = "Alerta" # Nueva leyenda para el color de relleno
        ) +
        scale_y_continuous(labels = scales::comma) +
        theme_minimal() +
        theme(
          plot.title = element_text(hjust = 0.5, face = "bold", size = 16),
          axis.title = element_text(size = 12),
          axis.text = element_text(size = 10),
          legend.position = "bottom",
          legend.title = element_blank(),
          strip.text = element_text(size = 12, face = "bold") # Títulos de facet_wrap
        ) +
        scale_color_manual(
          values = c(
            "Demanda" = "#FF5722",
            "Capacidad" = "#00BCD4"
          )
        ) +
        scale_linetype_manual(
          values = c(
            "Demanda" = "solid",
            "Capacidad" = "dashed"
          )
        ) +
        scale_fill_manual( # Nueva escala de color para el relleno del ribbon
          values = c("Exceso de Demanda" = "#FFCDD2"),
          name = "Alerta" # Nombre para la leyenda del fill
        )
    })
  })
}
