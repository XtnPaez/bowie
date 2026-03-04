# ============================================================
# File: mod_ui.R
# ============================================================

ui_seir_params <- function(ns) {
  div(
    h4("Epidemiological Model Parameters"),
    sliderInput(ns("r0_value"),
                label = HTML("Basic Reproduction Number (R<sub>0</sub>)"),
                min = 0.5, max = 5.0, value = INITIAL_R0, step = 0.1),
    sliderInput(ns("incubation_period"),
                label = "Incubation Period (days)",
                min = 1, max = 14, value = INITIAL_INCUBATION_PERIOD, step = 1),
    sliderInput(ns("infectious_period"),
                label = "Infectious Period (days)",
                min = 1, max = 21, value = INITIAL_INFECTIOUS_PERIOD, step = 1),
    sliderInput(ns("ifr_value"),
                label = "Infection Fatality Rate (IFR, %)",
                min = 0.01, max = 5.0, value = INITIAL_IFR * 100, step = 0.01)
  )
}

ui_policy_params <- function(ns) {
  div(
    h4("Public Policy Parameters"),
    radioButtons(
      inputId  = ns("policy_type"),
      label    = "Type of Intervention",
      choices  = c(
        "No Intervention"           = "no_intervention",
        "Phased Mitigation"         = "phased_mitigation",
        "Intermittent Intervention" = "intermittent",
        "ICU-triggered Measures"    = "icu_triggered"
      ),
      selected = "no_intervention"
    ),
    uiOutput(ns("policy_description")),
    br(),
    sliderInput(ns("compliance_level"),
                label = "Compliance Level (%)",
                min = 0, max = 100, value = 50, step = 5),
    tags$small(class = "text-muted",
               HTML("Policy reduces effective R<sub>0</sub> by up to 50% at full compliance."))
  )
}

ui_resource_params <- function(ns) {
  div(
    h4("Critical Resource Parameters"),
    tags$small(class = "text-muted",
               "Capacity values update Resource Pressure thresholds.
       Rate sliders re-run the simulation automatically."),
    br(), br(),
    numericInput(ns("icu_capacity"),            "ICU Bed Capacity",           INITIAL_ICU_CAPACITY,            min = 0),
    numericInput(ns("ventilator_availability"), "Ventilator Availability",    INITIAL_VENTILATOR_AVAILABILITY, min = 0),
    numericInput(ns("healthcare_staff"),        "Available Healthcare Staff", INITIAL_HEALTHCARE_STAFF,        min = 0),
    sliderInput(ns("icu_admission_rate"),    "ICU Admission Rate (%)",
                min = 0.1, max = 30.0, value = INITIAL_ICU_RATE * 100,        step = 0.1),
    sliderInput(ns("ventilator_usage_rate"), "Ventilator Usage Rate (%)",
                min = 0.1, max = 10.0, value = INITIAL_VENTILATOR_RATE * 100, step = 0.1)
  )
}

ui_main <- function(viz_id) {
  ns     <- NS(viz_id)
  ns_viz <- NS(viz_id)
  
  fluidPage(
    useShinyjs(),
    theme = bs_theme(version = 5, bootswatch = "flatly"),
    
    tags$head(
      tags$style(HTML("
        .fade-transition { transition: opacity 0.5s ease-in-out; }

        #controls-col {
          position: sticky;
          top: 10px;
          height: calc(100vh - 30px);
          overflow-y: auto;
          overflow-x: hidden;
          padding-right: 8px;
        }

        #controls-col::-webkit-scrollbar { width: 4px; }
        #controls-col::-webkit-scrollbar-thumb {
          background: #ced4da;
          border-radius: 4px;
        }

        #controls-col .well {
          background-color: #f8f9fa;
          border: 1px solid #e9ecef;
          border-radius: 6px;
          padding: 14px;
          margin-bottom: 12px;
        }
      "))
    ),
    
    titlePanel("SEIR Epidemiological Dashboard \u2013 Argentina"),
    br(),
    
    fluidRow(
      column(
        width = 4,
        div(
          id = "controls-col",
          wellPanel(ui_seir_params(ns)),
          wellPanel(ui_policy_params(ns)),
          wellPanel(ui_resource_params(ns)),
          # Run Simulation button — temporarily hidden, kept for future use
          # actionButton(
          #   ns("run_simulation"),
          #   label = "Run Simulation",
          #   class = "btn btn-primary w-100"
          # ),
          br()
        )
      ),
      column(
        width = 8,
        tabsetPanel(
          tabPanel(
            "Epidemic Curves",
            br(),
            h5("SEIR Compartment Dynamics (S, E, I, R)"),
            plotOutput(ns_viz("seir_plot"), height = "320px"),
            br(),
            h5("Simulated Cumulative Cases and Deaths"),
            plotOutput(ns_viz("cases_deaths_plot"), height = "280px")
          ),
          tabPanel(
            "Resource Pressure",
            br(),
            h5("Critical Resource Demand vs. Capacity"),
            tags$small(class = "text-muted",
                       "Red shading indicates periods where simulated demand exceeds capacity."),
            br(),
            plotOutput(ns_viz("resource_pressure_plot"), height = "480px")
          ),
          tabPanel(
            "Simulated Data",
            br(),
            h5("Simulation Output \u2014 First 10 Rows"),
            tableOutput(ns("simulated_data_table")),
            br(),
            # Download button: exports full simulation results as CSV
            downloadButton(
              ns("download_csv"),
              label = "Download Results (CSV)",
              class = "btn btn-primary"
            )
          )
        )
      )
    )
  )
}