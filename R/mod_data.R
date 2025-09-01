# mod_data.R
# Este módulo simula la ingesta de datos y proporciona un conjunto de datos estructurado.

# Función para la UI del módulo de datos (no se necesita UI visible para este módulo)
mod_data_ui <- function(id) {
  # No hay UI visible para este módulo, es puramente de lógica en el servidor
  NULL
}

# Función para el servidor del módulo de datos
# Simula la ingesta de datos o devuelve una estructura de datos esperada.
mod_data_server <- function(id, params) {
  moduleServer(id, function(input, output, session) {
    # Usamos reactiveValues para almacenar los datos simulados que serán accesibles
    # por otros módulos reactivamente.
    simulated_data <- reactiveVal(NULL)
    
    observeEvent(params()$trigger_sim, {
      req(params()$start_date, params()$end_date, params()$population)
      
      # Calcular el número de días para la simulación
      days <- as.numeric(params()$end_date - params()$start_date) + 1
      time_points <- 0:days
      
      # Crear un data frame vacío con la estructura esperada para el MVP
      # Aquí se podría simular una "API" o "archivo local"
      dummy_data <- data.frame(
        time = time_points,
        date = params()$start_date + time_points,
        S = numeric(length(time_points)),
        E = numeric(length(time_points)),
        I = numeric(length(time_points)),
        R = numeric(length(time_points)),
        Cases = numeric(length(time_points)),
        Deaths = numeric(length(time_points)),
        ICU_Occupancy = numeric(length(time_points)),
        Vent_Usage = numeric(length(time_points))
      )
      
      # Rellenar con valores de ejemplo o simulados (se sobrescribirá con el modelo SEIR)
      # Para el MVP, simplemente inicializamos con ceros o valores simples
      dummy_data$S[1] <- params()$population - 10000 # Aumentar la población infectada inicial para visibilidad
      dummy_data$I[1] <- 10000 # Un individuo infectado inicial
      
      # En una implementación real, aquí iría la lógica para cargar datos reales
      # Por ahora, simplemente devolvemos la estructura inicial.
      simulated_data(dummy_data)
    })
    
    # Devolver el reactiveVal que contiene los datos simulados
    return(simulated_data)
  })
}
