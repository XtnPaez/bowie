# ============================================================
# File: mod_ui.R
# ------------------------------------------------------------
# Description: Defines the User Interface (UI) module for the
# SEIR Epidemiological Dashboard. Includes all control panels
# for parameters, policies, and healthcare resources, along
# with main visualisation tabs.
# Author: Cristian Paez
# Created: 2025-11-07
# ============================================================

# ------------------------------------------------------------
# Function: ui_seir_params()
# Description:
#   Creates UI controls for SEIR model parameters.
# Parameters:
#   ns – namespace function for the module.
# Returns:
#   HTML UI elements.
# ------------------------------------------------------------
ui_seir_params <- function(ns) {
  div(
    h4("Epidemiological Model Parameters"),
    sliderInput(
      inputId = ns("r0_value"),
      label = HTML("Basic Reproduction Number (R<sub>0</sub>)"),
      min = 0.5, max = 5.0, value = INITIAL_R0, step = 0.1
    ),
    sliderInput(
      inputId = ns("incubation_period"),
      label = "Incubation Period (days)",
      min = 1, max = 14, value = INITIAL_INCUBATION_PERIOD, step = 1
    ),
    sliderInput(
      inputId = ns("infectious_period"),
      label = "Infectious Period (days)",
      min = 1, max = 21, value = INITIAL_INFECTIOUS_PERIOD, step = 1
    ),
    sliderInput(
      inputId = ns("ifr_value"),
      label = "Infection Fatality Rate (IFR, %)",
      min = 0.01, max = 5.0, value = INITIAL_IFR * 100, step = 0.01
    )
  )
}

# ------------------------------------------------------------
# Function: ui_policy_params()
# Description:
#   Creates UI controls for public health policy configuration.
# Parameters:
#   ns – namespace function for the module.
# Returns:
#   HTML UI elements.
# ------------------------------------------------------------
ui_policy_params <- function(ns) {
  div(
    h4("Public Policy Parameters"),
    selectInput(
      inputId = ns("policy_type"),
      label = "Type of Intervention",
      choices = c(
        "No Intervention" = "no_intervention",
        "Phased Mitigation" = "phased_mitigation",
        "Intermittent Intervention" = "intermittent",
        "ICU-triggered Measures" = "icu_triggered"
      ),
      selected = "no_intervention"
    ),
    sliderInput(
      inputId = ns("compliance_level"),
      label = "Compliance Level (%)",
      min = 0, max = 100, value = 50, step = 5
    )
  )
}

# ------------------------------------------------------------
# Function: ui_resource_params()
# Description:
#   Creates UI controls for healthcare resource configuration.
# Parameters:
#   ns – namespace function for the module.
# Returns:
#   HTML UI elements.
# ------------------------------------------------------------
ui_resource_params <- function(ns) {
  div(
    h4("Critical Resource Parameters"),
    numericInput(
      inputId = ns("icu_capacity"),
      label = "ICU Bed Capacity",
      value = INITIAL_ICU_CAPACITY, min = 0
    ),
    numericInput(
      inputId = ns("ventilator_availability"),
      label = "Ventilator Availability",
      value = INITIAL_VENTILATOR_AVAILABILITY, min = 0
    ),
    numericInput(
      inputId = ns("healthcare_staff"),
      label = "Available Healthcare Staff",
      value = INITIAL_HEALTHCARE_STAFF, min = 0
    ),
    sliderInput(
      inputId = ns("icu_admission_rate"),
      label = "ICU Admission Rate (%)",
      min = 0.1, max = 30.0, value = INITIAL_ICU_RATE * 100, step = 0.1
    ),
    sliderInput(
      inputId = ns("ventilator_usage_rate"),
      label = "Ventilator Usage Rate (%)",
      min = 0.1, max = 10.0, value = INITIAL_VENTILATOR_RATE * 100, step = 0.1
    )
  )
}

# ------------------------------------------------------------
# Function: ui_main()
# Description:
#   Builds the main layout of the dashboard, including parameter
#   panels, visualisation tabs, and theme selector.
# Parameters:
#   viz_id – namespace for visualisation module.
# Returns:
#   Complete Shiny UI layout.
# ------------------------------------------------------------
ui_main <- function(viz_id) {
  ns <- NS(viz_id)
  ns_viz <- NS(viz_id)
  
  fluidPage(
    useShinyjs(),
    theme = bs_theme(version = 5, bootswatch = "flatly"),
    
    tags$head(
      tags$style(HTML("
        .fade-transition { transition: opacity 0.5s ease-in-out; }
      "))
    ),
    
    titlePanel("SEIR Epidemiological Dashboard - Argentina"),
    
    # --- Main layout: sidebar and content area ---
    sidebarLayout(
      sidebarPanel(
        wellPanel(ui_seir_params(ns)),
        hr(),
        wellPanel(ui_policy_params(ns)),
        hr(),
        wellPanel(ui_resource_params(ns)),
        hr(),
        actionButton(ns("run_simulation"), "Run Simulation")
      ),
      
      mainPanel(
        tabsetPanel(
          tabPanel(
            "Epidemic Curves",
            h3("SEIR Model Simulation (S, E, I, R)"),
            plotOutput(ns_viz("seir_plot")),
            h3("Simulated Cases and Deaths"),
            plotOutput(ns_viz("cases_deaths_plot"))
          ),
          tabPanel(
            "Resource Pressure",
            h3("Critical Resource Occupancy"),
            plotOutput(ns_viz("resource_pressure_plot"))
          ),
          tabPanel(
            "Simulated Data",
            h3("Simulated Data Table"),
            tableOutput(ns("simulated_data_table"))
          )
        )
      )
    )
  )
}
