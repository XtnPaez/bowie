# ============================================================
# File: mod_ui.R
# ------------------------------------------------------------
# Description: Defines all UI layout functions for the Advanced
#   View of the SEIR dashboard. Exposes four composable
#   helpers:
#     - ui_seir_params()     – epidemiological parameter panel
#     - ui_policy_params()   – public policy parameter panel
#     - ui_resource_params() – healthcare resource panel
#     - ui_main()            – full page layout that wires all
#                              panels and plot outputs together
#
#   All functions accept a Shiny namespace function (ns) or
#   a module id (viz_id) so they can be reused across views
#   without id collisions.
#
# Author: Cristian Paez
# Created: 2025-11-07
# ============================================================


# ------------------------------------------------------------
# Function: ui_seir_params()
# Description:
#   Builds the epidemiological parameter control panel.
#   Provides slider inputs for the four core SEIR parameters:
#   R0, incubation period, infectious period, and IFR.
#   All default values are drawn from global constants defined
#   in global.R so that a single change propagates everywhere.
# Parameters:
#   ns – Shiny namespace function produced by NS(id).
# Returns:
#   A div() containing labelled sliderInput widgets.
# ------------------------------------------------------------
ui_seir_params <- function(ns) {
  div(
    h4("Epidemiological Model Parameters"),

    # R0: basic reproduction number; drives transmission intensity
    sliderInput(ns("r0_value"),
                label = HTML("Basic Reproduction Number (R<sub>0</sub>)"),
                min = 0.5, max = 5.0, value = INITIAL_R0, step = 0.1),

    # Incubation period: average days from exposure to infectiousness
    sliderInput(ns("incubation_period"),
                label = "Incubation Period (days)",
                min = 1, max = 14, value = INITIAL_INCUBATION_PERIOD, step = 1),

    # Infectious period: average days an individual remains infectious
    sliderInput(ns("infectious_period"),
                label = "Infectious Period (days)",
                min = 1, max = 21, value = INITIAL_INFECTIOUS_PERIOD, step = 1),

    # IFR expressed as a percentage [0, 100]; converted to proportion
    # internally by percent_to_prop() before ODE integration
    sliderInput(ns("ifr_value"),
                label = "Infection Fatality Rate (IFR, %)",
                min = 0.01, max = 5.0, value = INITIAL_IFR * 100, step = 0.01)
  )
}


# ------------------------------------------------------------
# Function: ui_policy_params()
# Description:
#   Builds the public policy parameter control panel.
#   Provides a radio button selector for the intervention type
#   and a compliance level slider. A dynamic description of
#   the selected policy is rendered via uiOutput — the
#   corresponding renderUI lives in mod_server.R.
# Parameters:
#   ns – Shiny namespace function produced by NS(id).
# Returns:
#   A div() containing radioButtons, uiOutput, and sliderInput.
# ------------------------------------------------------------
ui_policy_params <- function(ns) {
  div(
    h4("Public Policy Parameters"),

    # Four intervention strategies; selection feeds into the
    # effective R0 calculation in mod_model.R (Step 3)
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

    # Dynamic description rendered server-side (mod_server.R)
    uiOutput(ns("policy_description")),
    br(),

    # Compliance level: scales the R0 reduction applied by the
    # selected policy (0% = no effect, 100% = maximum reduction)
    sliderInput(ns("compliance_level"),
                label = "Compliance Level (%)",
                min = 0, max = 100, value = 50, step = 5),

    # Explanatory note for non-technical users
    tags$small(class = "text-muted",
               HTML("Policy reduces effective R<sub>0</sub> by up to 50% at full compliance."))
  )
}


# ------------------------------------------------------------
# Function: ui_resource_params()
# Description:
#   Builds the healthcare resource parameter control panel.
#   Numeric inputs (capacity, staff) only update the Resource
#   Pressure plot threshold lines and do NOT re-run the ODE
#   solver. Rate sliders (ICU admission, ventilator usage) DO
#   re-trigger the simulation because they change demand
#   calculations inside mod_model.R.
# Parameters:
#   ns – Shiny namespace function produced by NS(id).
# Returns:
#   A div() containing numericInput and sliderInput widgets.
# ------------------------------------------------------------
ui_resource_params <- function(ns) {
  div(
    h4("Critical Resource Parameters"),

    # Clarify the distinction between capacity inputs (threshold
    # only) and rate sliders (trigger re-simulation) for users
    tags$small(class = "text-muted",
               "Capacity values update Resource Pressure thresholds.
       Rate sliders re-run the simulation automatically."),
    br(), br(),

    # Capacity inputs — affect plot threshold lines only
    numericInput(ns("icu_capacity"),
                 "ICU Bed Capacity",
                 INITIAL_ICU_CAPACITY,
                 min = 0),
    numericInput(ns("ventilator_availability"),
                 "Ventilator Availability",
                 INITIAL_VENTILATOR_AVAILABILITY,
                 min = 0),
    numericInput(ns("healthcare_staff"),
                 "Available Healthcare Staff",
                 INITIAL_HEALTHCARE_STAFF,
                 min = 0),

    # Rate sliders — stored as percentages [0, 100];
    # converted to proportions before ODE post-processing
    sliderInput(ns("icu_admission_rate"),
                "ICU Admission Rate (%)",
                min = 0.1, max = 30.0,
                value = INITIAL_ICU_RATE * 100,
                step = 0.1),
    sliderInput(ns("ventilator_usage_rate"),
                "Ventilator Usage Rate (%)",
                min = 0.1, max = 10.0,
                value = INITIAL_VENTILATOR_RATE * 100,
                step = 0.1)
  )
}


# ------------------------------------------------------------
# Function: ui_main()
# Description:
#   Assembles the full Advanced View page layout. Combines a
#   sticky left sidebar (parameter panels) with a right-hand
#   tabset panel containing three output tabs:
#     1. Epidemic Curves  – SEIR dynamics and cumulative metrics
#     2. Resource Pressure – ICU/ventilator demand vs. capacity
#     3. Simulated Data   – tabular preview and CSV download
#
#   Both ns and ns_viz resolve to the same namespace (viz_id)
#   so that server-side input observers (mod_server.R) and
#   plot outputs (mod_viz.R) share a consistent id prefix.
#
#   The Run Simulation button is commented out because
#   simulation fires automatically on parameter change.
#   It is retained here for future manual-trigger use.
# Parameters:
#   viz_id – character; module id used to build the namespace.
#            Must match the id passed to mod_server() in app.R.
# Returns:
#   A fluidPage() containing the complete Advanced View UI.
# ------------------------------------------------------------
ui_main <- function(viz_id) {

  # Both aliases point to the same namespace; kept separate for
  # clarity — ns scopes server inputs, ns_viz scopes plot outputs
  ns     <- NS(viz_id)
  ns_viz <- NS(viz_id)

  fluidPage(
    useShinyjs(),
    theme = bs_theme(version = 5, bootswatch = "flatly"),

    # --- Inline CSS overrides for the sticky sidebar ---
    # These supplement custom.css with layout-specific rules
    # that depend on the #controls-col id being present
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

      # --- Left column: sticky parameter sidebar ---
      column(
        width = 4,
        div(
          id = "controls-col",
          wellPanel(ui_seir_params(ns)),
          wellPanel(ui_policy_params(ns)),
          wellPanel(ui_resource_params(ns)),

          # Run Simulation button — temporarily hidden.
          # Simulation fires automatically on any parameter change.
          # Uncomment to restore manual-trigger behaviour and also
          # re-enable the corresponding observeEvent in mod_server.R.
          # actionButton(
          #   ns("run_simulation"),
          #   label = "Run Simulation",
          #   class = "btn btn-primary w-100"
          # ),
          br()
        )
      ),

      # --- Right column: tabbed output panels ---
      column(
        width = 8,
        tabsetPanel(

          # Tab 1: SEIR compartment dynamics and cumulative metrics
          tabPanel(
            "Epidemic Curves",
            br(),
            h5("SEIR Compartment Dynamics (S, E, I, R)"),
            plotOutput(ns_viz("seir_plot"), height = "320px"),
            br(),
            h5("Simulated Cumulative Cases and Deaths"),
            plotOutput(ns_viz("cases_deaths_plot"), height = "280px")
          ),

          # Tab 2: Healthcare resource demand versus capacity thresholds
          tabPanel(
            "Resource Pressure",
            br(),
            h5("Critical Resource Demand vs. Capacity"),
            tags$small(class = "text-muted",
                       "Red shading indicates periods where simulated demand exceeds capacity."),
            br(),
            plotOutput(ns_viz("resource_pressure_plot"), height = "480px")
          ),

          # Tab 3: Raw simulation output — table preview and CSV export
          tabPanel(
            "Simulated Data",
            br(),
            h5("Simulation Output \u2014 First 10 Rows"),
            tableOutput(ns("simulated_data_table")),
            br(),
            # Full simulation results exported via write.csv2()
            # (semicolon separator, European locale formatting)
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
