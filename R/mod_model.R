# mod_model.R
# This module implements the epidemiological SEIR simulation logic.

# --- SEIR model equations ---
seir_equations <- function(time, state, parameters) {
  with(as.list(c(state, parameters)), {
    N <- S + E + I + R
    
    beta  <- effective_R0 / infectious_period
    sigma <- 1 / incubation_period
    gamma <- 1 / infectious_period
    
    dS <- -beta * S * I / N
    dE <-  beta * S * I / N - sigma * E
    dI <-  sigma * E - gamma * I
    dR <-  gamma * I
    
    new_infections <- sigma * E
    
    list(c(dS, dE, dI, dR),
         new_infections = new_infections)
  })
}

# --- SEIR model server logic ---
model_seir_server <- function(id, input_params, raw_data_df) {
  moduleServer(id, function(input, output, session) {
    
    model_results <- reactiveVal(NULL)
    
    observeEvent(input_params()$trigger_sim, {
      req(raw_data_df())
      
      # Ensure key parameters exist before validation
      req(
        !is.null(input_params()$r0_value),
        !is.null(input_params()$incubation_period),
        !is.null(input_params()$infectious_period),
        !is.null(input_params()$ifr_value)
      )
      
      # 1) Build and validate parameter list
      params <- list(
        r0_value = input_params()$r0_value,
        incubation_period = input_params()$incubation_period,
        infectious_period = input_params()$infectious_period,
        ifr_value = input_params()$ifr_value,
        icu_admission_rate = input_params()$icu_admission_rate,
        ventilator_usage_rate = input_params()$ventilator_usage_rate,
        start_date = input_params()$start_date,
        end_date = input_params()$end_date,
        population = input_params()$population
      )
      validate_params(params)
      
      # 2) Numeric conversions
      ifr_value             <- percent_to_prop(params$ifr_value)
      icu_admission_rate    <- percent_to_prop(params$icu_admission_rate)
      ventilator_usage_rate <- percent_to_prop(params$ventilator_usage_rate)
      hospital_stay_days    <- INITIAL_HOSPITAL_STAY_DAYS
      
      policy_type     <- input_params()$policy_type
      compliance_level <- percent_to_prop(input_params()$compliance_level)
      req(policy_type, compliance_level)
      
      # 3) Compute effective R0 based on policy
      effective_R0 <- params$r0_value
      if (!is.null(policy_type) && policy_type != "no_intervention") {
        effective_R0 <- params$r0_value * (1 - (compliance_level * 0.5))
        effective_R0 <- clamp(effective_R0, 0.5, Inf)
        log_message("DEBUG", "Policy applied: R0 reduction", .module = "MODEL",
                    policy = policy_type, compliance = input_params()$compliance_level,
                    R0_base = params$r0_value, R0_effective = effective_R0)
      } else {
        log_message("DEBUG", "No intervention: effective R0 equals base R0",
                    .module = "MODEL", R0_base = params$r0_value)
      }
      
      # 4) Initial state from raw data
      initial_state_df <- raw_data_df() %>% dplyr::filter(time == 0)
      initial_state <- c(
        S = initial_state_df$S[1],
        E = initial_state_df$E[1],
        I = initial_state_df$I[1],
        R = initial_state_df$R[1]
      )
      validate_initial_state(initial_state["S"], initial_state["E"],
                             initial_state["I"], initial_state["R"],
                             population = params$population)
      
      # 5) Time steps and ODE parameters
      times <- raw_data_df()$time
      ode_parms <- c(
        effective_R0 = effective_R0,
        incubation_period = params$incubation_period,
        infectious_period = params$infectious_period
      )
      
      # 6) Solve ODE system
      out <- safe_ode(
        y = initial_state,
        times = times,
        func = seir_equations,
        parms = ode_parms,
        method = "lsoda",
        .module = "MODEL"
      )
      
      # 7) Postprocess results
      results_df <- as.data.frame(out)
      names(results_df)[names(results_df) == "new_infections"] <- "Daily_New_Infections"
      
      # Ensure population conservation
      results_df <- results_df %>%
        dplyr::mutate(
          Total_Population = S + E + I + R,
          S = S * params$population / Total_Population,
          E = E * params$population / Total_Population,
          I = I * params$population / Total_Population,
          R = R * params$population / Total_Population
        ) %>%
        dplyr::select(-Total_Population)
      
      # Compute cumulative cases and deaths
      results_df <- results_df %>%
        dplyr::mutate(
          date = params$start_date + time,
          Cumulative_Cases = cumsum(Daily_New_Infections),
          Daily_Deaths = Daily_New_Infections * ifr_value,
          Cumulative_Deaths = cumsum(Daily_Deaths)
        )
      
      # ICU and ventilator demand (simplified windowed approximation)
      results_df <- results_df %>%
        dplyr::mutate(
          ICU_Daily_Demand = I * icu_admission_rate,
          Vent_Daily_Demand = I * ventilator_usage_rate,
          ICU_Occupancy_Sim = RcppRoll::roll_sum(ICU_Daily_Demand, n = hospital_stay_days, align = "right", fill = NA),
          Vent_Usage_Sim = RcppRoll::roll_sum(Vent_Daily_Demand, n = hospital_stay_days, align = "right", fill = NA)
        ) %>%
        dplyr::mutate(
          ICU_Occupancy_Sim = ifelse(is.na(ICU_Occupancy_Sim), cumsum(tidyr::replace_na(ICU_Daily_Demand, 0)), ICU_Occupancy_Sim),
          Vent_Usage_Sim = ifelse(is.na(Vent_Usage_Sim), cumsum(tidyr::replace_na(Vent_Daily_Demand, 0)), Vent_Usage_Sim)
        )
      
      results_df$ICU_Occupancy_Sim[results_df$ICU_Occupancy_Sim < 0] <- 0
      results_df$Vent_Usage_Sim[results_df$Vent_Usage_Sim < 0] <- 0
      
      log_message("INFO", "SEIR simulation completed", .module = "MODEL",
                  n_steps = nrow(results_df),
                  start = as.character(params$start_date),
                  end = as.character(params$end_date))
      
      model_results(results_df)
    })
    
    return(model_results)
  })
}
