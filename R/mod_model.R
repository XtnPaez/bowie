# mod_model.R
# Este módulo implementa la lógica simulada del modelo epidemiológico (SEIR).

# Definición de las ecuaciones diferenciales para el modelo SEIR
seir_equations <- function(time, state, parameters) {
  with(as.list(c(state, parameters)), {
    N <- S + E + I + R # Población total
    
    # Parámetros derivados
    beta <- effective_R0 / infectious_period # Tasa de infección
    sigma <- 1 / incubation_period # Tasa de incubación (latencia a infeccioso)
    gamma <- 1 / infectious_period # Tasa de recuperación
    
    # Ecuaciones diferenciales
    dS <- -beta * S * I / N
    dE <- beta * S * I / N - sigma * E
    dI <- sigma * E - gamma * I
    dR <- gamma * I
    
    # Acumuladores (no afectan el sistema ODE directamente, pero útiles para seguimiento)
    # Nuevos casos (de E a I)
    new_infections <- sigma * E
    
    # Salida del sistema (debe estar en el mismo orden que 'state')
    return(list(c(dS, dE, dI, dR),
                new_infections = new_infections)) # Devolvemos new_infections para seguir los casos
  })
}

# Función para el servidor del módulo del modelo
model_seir_server <- function(id, input_params, raw_data_df) {
  moduleServer(id, function(input, output, session) {
    # Reactive para almacenar los resultados del modelo
    model_results <- reactiveVal(NULL)
    
    observeEvent(input_params()$trigger_sim, {
      req(raw_data_df()) # Asegurarse de que los datos brutos estén disponibles
      
      
      # Obtener parámetros de entrada
      R0 <- input_params()$r0_value
      incubation_period <- input_params()$incubation_period
      infectious_period <- input_params()$infectious_period
      ifr_value <- input_params()$ifr_value / 100 # Convertir porcentaje a decimal
      
      icu_admission_rate <- input_params()$icu_admission_rate / 100
      ventilator_usage_rate <- input_params()$ventilator_usage_rate / 100
      hospital_stay_days <- INITIAL_HOSPITAL_STAY_DAYS # Usar un valor fijo por ahora
      
      # Las capacidades (icu_capacity, ventilator_availability, healthcare_staff)
      # ya no se añaden al dataframe de resultados del modelo aquí,
      # porque el módulo de visualización las leerá directamente de los inputs de la UI.
      
      start_date <- input_params()$start_date
      end_date <- input_params()$end_date
      population <- input_params()$population
      
      policy_type <- input_params()$policy_type
      compliance_level <- input_params()$compliance_level / 100 # Convertir a decimal
      
      # Lógica para calcular el R0 efectivo basado en la política y el cumplimiento
      effective_R0 <- R0 # Por defecto, es el R0 del slider
      if (policy_type != "no_intervention") {
        # Para MVP, una reducción simple del R0 basada en el nivel de cumplimiento
        # Ejemplo: 100% cumplimiento reduce R0 a la mitad
        effective_R0 <- R0 * (1 - (compliance_level * 0.5)) # Reducción del 50% max
        # Asegurarse de que R0 no sea menor que 0.5 o algún valor mínimo biológicamente relevante
        effective_R0 <- max(0.5, effective_R0)
        cat("MODEL_MODULE: Policy selected:", policy_type, "Compliance:", compliance_level * 100, "%. Effective R0:", effective_R0, "\n")
      } else {
        cat("MODEL_MODULE: No intervention selected. Effective R0:", effective_R0, "\n")
      }
      
      
      # Estado inicial (usar los valores de raw_data_df para S, E, I, R inicial)
      # Se asume que raw_data_df ya tiene la fila inicial
      initial_state_df <- raw_data_df() %>% filter(time == 0)
     
      initial_state <- c(
        S = initial_state_df$S[1],
        E = initial_state_df$E[1],
        I = initial_state_df$I[1],
        R = initial_state_df$R[1]
      )
      
      # Parámetros del modelo SEIR
      # Ahora pasamos el effective_R0
      parameters <- c(
        effective_R0 = effective_R0, # Pasamos el R0 efectivo
        incubation_period = incubation_period,
        infectious_period = infectious_period
      )
      
      # Puntos de tiempo para la simulación
      times <- raw_data_df()$time
      
      # Resolver las ecuaciones diferenciales usando lsoda
      out <- ode(
        y = initial_state,
        times = times,
        func = seir_equations,
        parms = parameters,
        method = "lsoda"
      )
     
      
      # Convertir el resultado a un data frame y añadir el tiempo como días
      results_df <- as.data.frame(out)
      names(results_df)[names(results_df) == "new_infections"] <- "Daily_New_Infections"
      
      
      # Asegurar que los totales S, E, I, R sumen la población total
      results_df <- results_df %>%
        mutate(
          Total_Population = S + E + I + R,
          # Ajustar si hay desviaciones significativas debido a la precisión numérica
          S = S * population / Total_Population,
          E = E * population / Total_Population,
          I = I * population / Total_Population,
          R = R * population / Total_Population
        ) %>%
        select(-Total_Population) # Eliminar la columna auxiliar
      
      # Simular Casos y Muertes acumuladas
      results_df <- results_df %>%
        mutate(
          date = start_date + time,
          # Casos acumulados son la suma de las nuevas infecciones diarias
          Cumulative_Cases = cumsum(Daily_New_Infections),
          # Muertes simuladas basadas en IFR y nuevas infecciones
          Daily_Deaths = Daily_New_Infections * ifr_value,
          Cumulative_Deaths = cumsum(Daily_Deaths)
        )
      
      # Simular presión sobre recursos críticos
      # Nota: Esto es una simplificación. Un modelo real consideraría lag y duración.
      results_df <- results_df %>%
        mutate(
          ICU_Daily_Demand = I * icu_admission_rate, # Demanda diaria de UCI basada en I
          Vent_Daily_Demand = I * ventilator_usage_rate, # Demanda diaria de ventiladores
          # Para simular ocupación, consideramos la demanda sobre el tiempo de hospitalización
          # Esto es una aproximación, idealmente se usaría un modelo de colas o retraso.
          # Acumular la demanda de los últimos 'hospital_stay_days'
          ICU_Occupancy_Sim = RcppRoll::roll_sum(ICU_Daily_Demand, n = hospital_stay_days, align = "right", fill = NA), #Calcula la suma de la demanda de los últimos días 
          Vent_Usage_Sim = RcppRoll::roll_sum(Vent_Daily_Demand, n = hospital_stay_days, align = "right", fill = NA)
        ) %>%
        # Rellenar los NAs iniciales (días antes de alcanzar el hospital_stay_days)
        # con la suma acumulada hasta ese punto
        mutate(
          ICU_Occupancy_Sim = ifelse(is.na(ICU_Occupancy_Sim), cumsum(replace_na(ICU_Daily_Demand, 0)), ICU_Occupancy_Sim),
          Vent_Usage_Sim = ifelse(is.na(Vent_Usage_Sim), cumsum(replace_na(Vent_Daily_Demand, 0)), Vent_Usage_Sim)
        )
      
      # Asegurarse de que ICU_Occupancy_Sim y Vent_Usage_Sim no sean negativos
      results_df$ICU_Occupancy_Sim[results_df$ICU_Occupancy_Sim < 0] <- 0
      results_df$Vent_Usage_Sim[results_df$Vent_Usage_Sim < 0] <- 0
      
      # Las columnas de capacidad se gestionan directamente en el módulo de visualización.
      # No es necesario añadirlas al dataframe de resultados del modelo.
      model_results(results_df)
      
    })
    
    # Devolver los resultados del modelo
    
    return(model_results)
    
    
  })
}
