# Implementation Guide — SEIR Epidemiological Dashboard

**Pandemic Preparedness Toolkit · Argentina Unit · Product 3**  
**Work Package 5 · WP5**

| | |
|---|---|
| **Author** | Cristian Paez |
| **Organisation** | CEMIC |
| **Funded by** | Wellcome |
| **Version** | 1.1 |
| **Date** | March 2026 |
| **Related documents** | ToR WP5, `README.md`, `roadmap.md`, `proj_evolution.md` |

---

## Table of Contents

1. [Overview](#1-overview)
2. [System Requirements](#2-system-requirements)
3. [Repository Structure](#3-repository-structure)
4. [Installation and Local Setup](#4-installation-and-local-setup)
5. [Configuration](#5-configuration)
6. [Module Architecture](#6-module-architecture)
7. [SEIR Model — Equations and Parameters](#7-seir-model--equations-and-parameters)
8. [Dataset Sources](#8-dataset-sources)
9. [Visual Design System](#9-visual-design-system)
10. [Deployment](#10-deployment)
11. [Known Limitations](#11-known-limitations)
12. [References](#12-references)

---

## 1. Overview

The SEIR Epidemiological Dashboard is a modular, interactive web application built with the R
Shiny framework. It implements a Susceptible–Exposed–Infectious–Recovered (SEIR) compartmental
model for infectious disease scenario simulation, with real-time parameter adjustment and
healthcare resource pressure analysis.

The platform is delivered as **Product 2** of the Pandemic Preparedness Toolkit (PPT) Argentina
Unit, Work Package 5. This document constitutes part of **Product 3** (Implementation and User
Guides) and is directed at system administrators, developers, and researchers responsible for
deploying and maintaining the platform.

The application provides two independent views:

- **Advanced View** — full parameter control with three interactive plot panels, a sticky
  sidebar, and CSV export of simulation results.
- **Simplified View** — a decision-maker interface with three KPI cards, each displaying a
  metric and a geometric alarm indicator (circle / triangle / square) in the PPT palette.
  Alarm thresholds are configurable. State is fully isolated from the Advanced View.

The application is deployed as a public web application at:
<https://cpaez.shinyapps.io/bowie-seir/>

Source code is available at:
<https://github.com/XtnPaez/bowie>

---

## 2. System Requirements

### Development environment

- R >= 4.3.0
- RStudio (recommended) or any R-compatible IDE
- Git

### Required R packages

```r
install.packages(c(
  "shiny",      # Web application framework
  "shinyjs",    # Dynamic UI manipulation
  "bslib",      # Bootstrap 5 themes
  "ggplot2",    # Static visualisations (>= 3.4.0 required for linewidth)
  "dplyr",      # Data manipulation
  "tidyr",      # Data reshaping
  "purrr",      # Functional programming utilities
  "scales",     # Axis formatting
  "lubridate",  # Date manipulation
  "deSolve",    # ODE integration (SEIR equations)
  "RcppRoll",   # Rolling window operations (ICU occupancy)
  "plotly",     # Interactive chart layer (reserved for future use)
  "rsconnect",  # Deployment to shinyapps.io
  "stringr"     # String utilities (used by utils_dependencies.R)
))
```

Note: `ggplot2 >= 3.4.0` is required. Earlier versions use the deprecated `size` aesthetic
for line width; the codebase uses `linewidth` throughout.

### Software infrastructure

- Web server: shinyapps.io (current) or self-hosted Shiny Server.
- No database management system is required. Datasets are stored as `.rds` and `.RData`
  files in the `data/` directory.
- API integration capabilities are reserved for a future release (Block 6).

---

## 3. Repository Structure

```
bowie/
├── app.R                          # Application entry point and routing
├── DESCRIPTION                    # R package metadata and dependencies
├── LICENSE                        # MIT licence
├── NAMESPACE                      # R package namespace
├── README.md                      # Project overview
├── CODESTYLE.md                   # Coding and commenting standards
├── roadmap.md                     # Strategic roadmap and block status
├── proj_evolution.md              # ToR alignment and progress report
├── structure.txt                  # Auto-generated project file tree
├── write_structure.R              # Script to regenerate structure.txt
│
├── R/
│   ├── global.R                   # Global constants and library loading
│   ├── data_interface.R           # Data Hub: loading, validation, caching
│   ├── mod_entry.R                # Entry screen module
│   ├── mod_menu.R                 # Top navigation menu module
│   ├── mod_ui.R                   # Advanced View UI layout and panels
│   ├── mod_server.R               # Advanced View server: parameter wiring, model orchestration
│   ├── mod_model.R                # SEIR ODE model logic
│   ├── mod_viz.R                  # Visualisation module (ggplot2)
│   ├── mod_data.R                 # Data simulation module
│   ├── mod_helpers_simple.R       # Shared helpers for the Simplified View
│   ├── mod_ui_simple.R            # Simplified View UI: KPI cards and sliders
│   ├── mod_server_simple.R        # Simplified View server: isolated state and alarm logic
│   ├── mod_server_reactivity.R    # Cross-module reactivity scaffold (reserved)
│   └── utils/
│       ├── utils_logging.R        # Structured logging utilities
│       ├── utils_validation.R     # Parameter and schema validation
│       ├── utils_helpers.R        # Numeric helpers and safe ODE wrapper
│       └── utils_dependencies.R   # Automatic dependency detection and loading
│
├── data/
│   ├── mock_dataset.rds           # Simulated default dataset
│   ├── iecs_data.RData            # IECS / Santoro — real COVID-19 Argentina data
│   └── cache/                     # Auto-generated: cached datasets (save_dataset())
│
├── docs/
│   └── implementation_guide.md    # This document
│
└── www/
    └── custom.css                 # Visual overrides — PPT brand palette
```

---

## 4. Installation and Local Setup

### Clone the repository

```bash
git clone https://github.com/XtnPaez/bowie.git
cd bowie
```

### Install dependencies

```r
install.packages(c(
  "shiny", "shinyjs", "bslib", "ggplot2", "dplyr", "tidyr",
  "purrr", "scales", "lubridate", "deSolve", "RcppRoll",
  "plotly", "rsconnect", "stringr"
))
```

Alternatively, if `pak` is available, it can resolve all dependencies from `DESCRIPTION`:

```r
pak::pak()
```

### Run locally

```r
shiny::runApp()
```

The application will open in the default browser at `http://127.0.0.1:PORT`.

### Automatic dependency loading

`utils_dependencies.R` scans all project source files for `library()`, `require()`,
and `pkg::function()` calls, then installs and loads any missing packages automatically
at startup. It applies two filters to avoid false positives:

- A curated blocklist of known non-package tokens (e.g., `col`, `pkg`, `base`).
- A CRAN name format check: only tokens matching `^[A-Za-z][A-Za-z0-9\\.]*$` are
  treated as package names. This prevents CSS pseudo-selectors embedded in inline
  style strings from being parsed as package names.

---

## 5. Configuration

All global constants are defined in `R/global.R`. Modifying this file is the single
point of change for default simulation parameters. The Simplified View initialises its
own isolated `reactiveValues` directly from these constants.

### Epidemiological parameters

| Constant | Default value | Description |
|---|---|---|
| `INITIAL_R0` | `2.5` | Basic reproduction number |
| `INITIAL_INCUBATION_PERIOD` | `5` | Incubation period (days) |
| `INITIAL_INFECTIOUS_PERIOD` | `7` | Infectious period (days) |
| `INITIAL_IFR` | `0.01` | Infection Fatality Rate (proportion) |

### Healthcare resource parameters

| Constant | Default value | Source | Description |
|---|---|---|---|
| `INITIAL_ICU_RATE` | `0.136` | IECS [^1] | Proportion of infected requiring ICU |
| `INITIAL_VENTILATOR_RATE` | `0.02` | International studies [^2] | Proportion of infected requiring ventilation |
| `INITIAL_HOSPITAL_STAY_DAYS` | `10` | IECS / CDC [^1] | Average hospital stay (days) |
| `INITIAL_ICU_CAPACITY` | `6000` | SATI [^3] | Available ICU beds |
| `INITIAL_VENTILATOR_AVAILABILITY` | `2000` | SATI [^3] | Available ventilators |
| `INITIAL_HEALTHCARE_STAFF` | `10000` | CONICET [^4] | Staff directly engaged in critical care |

### Population and simulation dates

| Constant | Default value | Source | Description |
|---|---|---|---|
| `POPULATION_ARGENTINA` | `45,000,000` | INDEC [^5] | Total population baseline |
| `START_DATE` | `2020-03-01` | — | Simulation start date |
| `END_DATE` | `2021-03-01` | — | Simulation end date |

### Log level

The logging verbosity is controlled by the `LOG_LEVEL` environment variable. Accepted
values are `DEBUG`, `INFO`, `WARN`, and `ERROR`. The default is `INFO`.

```r
Sys.setenv(LOG_LEVEL = "DEBUG")  # verbose output during development
Sys.setenv(LOG_LEVEL = "WARN")   # minimal output in production
```

---

## 6. Module Architecture

The application follows a strict modular pipeline. There are two independent simulation
paths — Advanced View and Simplified View — that share the ODE solver infrastructure but
maintain entirely separate reactive state.

```
                              app.R
                             /     \
              ┌─────────────┐       ┌──────────────────┐
              │ ADVANCED     │       │ SIMPLIFIED        │
              │ VIEW         │       │ VIEW              │
              │              │       │                   │
         mod_server       mod_server_simple
              │                   │
         mod_model            mod_model
         (seir_model)         (simple_seir)
              │                   │
         mod_data             mod_data
         (data_sim)           (simple_data)
              │
         mod_viz
         (viz_plot_server)
              │
         mod_ui              mod_ui_simple
              │                   │
         mod_menu ─────────────────┘
              │
         mod_entry
```

All modules are loaded automatically by Shiny's `loadSupport()` mechanism because
the project contains a `DESCRIPTION` file. Files in `R/` are loaded in alphabetical
order. The load order is significant for the Simplified View: `mod_helpers_simple.R`
(h) is guaranteed to load before `mod_server_simple.R` (s) and `mod_ui_simple.R` (u),
ensuring that shared helper functions are available when both modules are sourced.

### app.R — Application entry point

Defines the root UI and server. Manages top-level reactive state (`screen`,
`dataset_selector`, `dataset_loaded`, `trigger_sim`) and wires all modules together.

**Namespace contract — Advanced View (critical):** `viz_plot_server()` must be called from
the top-level server function in `app.R`, not from inside `mod_server()`. If called from
within `mod_server()` (which itself runs under the `"viz_advanced"` namespace), output ids
accumulate as `"viz_advanced-viz_advanced-seir_plot"`, which does not match the `plotOutput`
ids generated by `ui_main()`. The correct call site is `app.R`.

**Namespace contract — Simplified View:** `mod_server_simple()` does not use
`viz_plot_server()`. KPI cards are rendered via `renderUI` calls inside the module itself.
Internal sub-modules use `"simple_data"` and `"simple_seir"` as namespace ids, distinct from
the Advanced View ids `"data_sim"` and `"seir_model"`.

### global.R — Global constants and library loading

Loads all required libraries, defines all model constants, and dynamically sources
utility functions from `R/utils/`. Any constant used across more than one module is
defined here. The Simplified View reads constants directly from this file to initialise
its isolated `reactiveValues`.

### data_interface.R — Data Hub

Central interface for dataset loading, validation, schema checks, and caching.
Exposes five public functions:

| Function | Description |
|---|---|
| `load_iecs_data()` | Loads the IECS / Santoro dataset from `data/iecs_data.RData` |
| `get_data(source)` | Returns a dataset by source key: `"mock"`, `"iecs"`, or `"file"` |
| `validate_schema(data)` | Validates that a data frame contains required SEIR columns |
| `save_dataset(data, name)` | Saves a validated dataset to `data/cache/` |
| `list_datasets()` | Lists all cached datasets with name, path, and size |

### mod_entry.R — Entry screen

Renders the entry screen with a PPT-branded navbar, a centred card containing the
dataset selector, load button, and status badge, and a footer attribution strip.
Server logic handles dataset loading, success and error feedback, and navigation to
both the Advanced View and the Simplified View via `actionButton` inputs `go_advanced`
and `go_simple`.

### mod_menu.R — Top navigation menu

Renders a persistent dark green navbar injected above all non-entry views. Provides
the dataset indicator and three navigation buttons: Home, Simple, and Advanced. The
Simple and Advanced buttons are rendered via `uiOutput` so the server can apply a
dynamic active-state border highlight (PPT orange `#F59342`) to the currently active
view button.

### mod_ui.R — Advanced View layout

Defines all UI layout functions for the Advanced View. Exposes four composable helpers:

| Function | Description |
|---|---|
| `ui_seir_params(ns)` | Epidemiological parameter panel (R₀, incubation, infectious period, IFR) |
| `ui_policy_params(ns)` | Public policy panel (intervention type, compliance level) |
| `ui_resource_params(ns)` | Healthcare resource panel (capacity inputs and rate sliders) |
| `ui_main(viz_id)` | Full page layout: sticky sidebar + tabbed output area + footer |

### mod_server.R — Advanced View server

Orchestrates the full Advanced View simulation pipeline. Responsibilities:

- Initialises `reactiveValues` (`app_params`) with defaults from `global.R`.
- Loads dataset parameters when an IECS source is selected.
- Registers one `observeEvent` per UI input to update `app_params` and, where
  appropriate, increment `trigger_sim` to re-run the ODE solver.
- Calls `mod_data_server()` and `model_seir_server()` as sub-modules.
- Renders the policy description, data preview table, and CSV download handler.
- Returns `model_data`, `icu_capacity`, and `ventilator_availability` reactives
  for use by `viz_plot_server()` in `app.R`.

**Capacity vs. rate inputs:** ICU capacity and ventilator availability inputs do not
increment `trigger_sim` — they only update the Resource Pressure plot threshold lines.
Rate sliders (ICU admission rate, ventilator usage rate) do increment `trigger_sim`
because they affect demand calculations in `mod_model.R`.

**IFR scale contract:** `ifr_value` is always stored as a percentage in [0, 100]
inside `app_params` and all UI inputs. Conversion to proportion (÷ 100) is performed
inside `mod_model.R` via `percent_to_prop()` immediately before ODE integration.

### mod_helpers_simple.R — Simplified View shared helpers

Contains all pure functions shared between `mod_ui_simple.R` and `mod_server_simple.R`.
Defined in a separate file to guarantee correct load order under `loadSupport()`.

| Function | Description |
|---|---|
| `alarm_shape_svg(state, size)` | Returns an inline SVG element (circle / triangle / square) coloured with the matching PPT alarm palette colour |
| `state_label_ui(state)` | Returns a styled `tags$p()` with the alarm state label |
| `metric_value_ui(formatted_value, unit_label)` | Returns a styled `tags$div()` with the KPI value and unit |
| `resolve_alarm_state(value, warn, crit, direction)` | Classifies a numeric value as `"controlled"`, `"warning"`, or `"critical"` using two monotone thresholds |
| `coalesce_num(value, default)` | Returns `value` if it is a non-NA numeric scalar, otherwise returns `default`; guards against `NULL`/`NA` while a threshold field is being edited |

### mod_ui_simple.R — Simplified View UI

Defines the full Simplified View layout. Contains one local helper (`kpi_card_ui()`)
and the main function `mod_ui_simple(id)`. Layout (top to bottom):

1. Page heading.
2. Three KPI cards in a responsive flex row. Each card contains a `uiOutput` for the
   alarm shape, a `uiOutput` for the state label, a static title and subtitle, and a
   `uiOutput` for the metric value. All reactive elements are server-rendered.
3. A parameter card with two sliders: R₀ (range 0.5–6.0, default `INITIAL_R0`) and
   Compliance Level (range 0–100, default 50). Both initialise from `global.R`.
4. A collapsible Settings panel (toggled via inline JavaScript) containing six
   `numericInput` controls for alarm threshold overrides.
5. Footer attribution strip.

### mod_server_simple.R — Simplified View server

Server logic for the Simplified View. Key design properties:

- Maintains its own `reactiveValues` (`simple_params`) always initialised from `global.R`
  constants. These are never read or written by the Advanced View.
- Calls `mod_data_server("simple_data", ...)` and `model_seir_server("simple_seir", ...)`
  under distinct namespace ids to avoid collision with the Advanced View.
- Slider observers (`input$simple_r0`, `input$simple_compliance`) update `simple_params`
  and increment `trigger_sim` to re-run the ODE solver. `ignoreInit = FALSE` ensures the
  first simulation fires immediately on load.
- Three KPI reactive expressions compute metrics from the model output:

| Reactive | Metric | Method |
|---|---|---|
| `kpi_growth_rate` | Weekly growth rate of I | Mean of last 7 days vs. preceding 7 days |
| `kpi_icu_pct` | Peak daily ICU admissions as % of capacity | Maximum `ICU_Daily_Demand` across the simulation divided by `INITIAL_ICU_CAPACITY`. Display is capped at `"> 100%"` — values above capacity are shown as collapsed rather than as an exact percentage. |
| `kpi_deaths_pct` | Deaths as % of population | `Cumulative_Deaths` on the final simulation day |

- Three alarm state reactives call `resolve_alarm_state()` using the KPI value and the
  current threshold inputs. These do not depend on `trigger_sim` — they react only to
  KPI changes and threshold input changes, so modifying a threshold does not re-run
  the ODE solver.

### mod_server_reactivity.R — Cross-module reactivity scaffold

Reserved for future cross-module reactive bindings. Currently a scaffold with no
active wiring. Not called from `app.R` or any other module.

### mod_model.R — SEIR ODE model

Implements the SEIR differential equations and post-processing pipeline. Used by both
the Advanced View and the Simplified View via `model_seir_server()`. See Section 7 for
the full mathematical specification.

### mod_viz.R — Visualisation module

Renders three plots from SEIR model output via `viz_plot_server()`. Used exclusively
by the Advanced View. All plots share a common `ppt_theme()` function. See Section 9
for colour specifications.

| Output | Description |
|---|---|
| `seir_plot` | SEIR compartment dynamics over time |
| `cases_deaths_plot` | Cumulative cases and deaths |
| `resource_pressure_plot` | ICU and ventilator demand vs. capacity, with ribbon shading |

### mod_data.R — Data simulation module

Generates the initial time-series structure passed to `model_seir_server()` as
`raw_data_df`. The ODE solver overwrites all compartment values during integration.

### utils/utils_logging.R — Logging utilities

| Function | Description |
|---|---|
| `log_message(level, msg, .module, ...)` | Prints structured log lines with timestamp, level, module, and optional key-value pairs |
| `set_log_level(level)` | Sets global log verbosity via `LOG_LEVEL` environment variable |
| `with_timing(expr, .module, .label)` | Wraps an expression and logs elapsed execution time |

### utils/utils_validation.R — Validation utilities

Provides `validate_params()` and `validate_initial_state()`. Called by `mod_model.R`
before ODE integration to enforce parameter ranges and compartment consistency.

### utils/utils_helpers.R — Numeric helpers and ODE wrapper

| Function | Description |
|---|---|
| `clamp(x, minv, maxv)` | Restricts a value to a given interval |
| `percent_to_prop(x_pct)` | Converts percentage to proportion (÷ 100) |
| `not_null(x)` | Returns `TRUE` if object is not `NULL` |
| `safe_ode(...)` | Error-safe wrapper around `deSolve::ode()`; logs failures and re-throws with a clean message |

### utils/utils_dependencies.R — Automatic dependency loading

Scans all project source files for package references, filters false positives, and
installs and loads any missing packages at startup. See Section 4 for filter details.

---

## 7. SEIR Model — Equations and Parameters

### Compartmental structure

| Compartment | Symbol | Description |
|---|---|---|
| Susceptible | S | Individuals with no immunity who may become infected |
| Exposed | E | Individuals who have been infected but are not yet infectious |
| Infectious | I | Individuals who are actively infectious |
| Recovered | R | Individuals who have recovered and are assumed immune |

### Differential equations

$$
\frac{dS}{dt} = -\beta \cdot \frac{S \cdot I}{N}
$$

$$
\frac{dE}{dt} = \beta \cdot \frac{S \cdot I}{N} - \sigma \cdot E
$$

$$
\frac{dI}{dt} = \sigma \cdot E - \gamma \cdot I
$$

$$
\frac{dR}{dt} = \gamma \cdot I
$$

Where:

| Symbol | Definition |
|---|---|
| $N$ | Total population ($S + E + I + R$) |
| $\beta = R_0 \cdot \gamma$ | Transmission rate |
| $\sigma = 1 / \lambda_E$ | Progression rate from exposed to infectious |
| $\gamma = 1 / \lambda_I$ | Recovery rate |
| $\lambda_E$ | Incubation period (days) |
| $\lambda_I$ | Infectious period (days) |

### Effective R₀ under policy

When a public health intervention is active (i.e., `policy_type != "no_intervention"`),
the effective reproduction number is reduced proportionally to the compliance level:

$$
R_0^{\text{eff}} = R_0 \cdot \left(1 - 0.5 \cdot c\right)
$$

Where $c$ is the compliance level as a proportion in [0, 1]. At full compliance ($c = 1$),
R₀ is reduced by 50%. The effective value is clamped to a minimum of 0.5 to prevent
biologically implausible results. The Simplified View uses `policy_type = "phased_mitigation"`
so that the Compliance Level slider has a meaningful effect on the simulation.

### Post-processing: healthcare resource demand

Daily ICU and ventilator demand are derived from the infectious compartment:

$$
\text{ICU\_Daily\_Demand} = I \cdot r_{\text{ICU}}
$$

$$
\text{Vent\_Daily\_Demand} = I \cdot r_{\text{vent}}
$$

Cumulative occupancy is estimated using a rolling sum over the average hospital
stay window:

$$
\text{ICU\_Occupancy\_Sim}_t = \sum_{k=t-h+1}^{t} \text{ICU\_Daily\_Demand}_k
$$

Where $h$ = `INITIAL_HOSPITAL_STAY_DAYS` (default: 10 days).

### Output data frame columns

| Column | Description |
|---|---|
| `date` | Simulation date |
| `S`, `E`, `I`, `R` | Compartment sizes (normalised to total population) |
| `Daily_New_Infections` | New infections per day ($\sigma \cdot E$) |
| `Cumulative_Cases` | Running total of new infections |
| `Daily_Deaths` | Daily deaths ($\text{Daily\_New\_Infections} \cdot \text{IFR}$) |
| `Cumulative_Deaths` | Running total of deaths |
| `ICU_Occupancy_Sim` | Estimated ICU bed occupancy (rolling sum) |
| `Vent_Usage_Sim` | Estimated ventilator usage (rolling sum) |

---

## 8. Dataset Sources

### Simulated dataset (mock)

Loaded from `data/mock_dataset.rds`. Provides a SEIR-compatible time-series
structure for parameter exploration without requiring real data.

### IECS / Santoro dataset

Loaded from `data/iecs_data.RData` via `load_iecs_data()`. Contains real COVID-19
epidemiological and resource parameters for Argentina derived from the IECS
(Institute for Clinical Effectiveness and Health Policy) Santoro model [^1].

The file exposes a named list with three elements:

| Element | Type | Contents |
|---|---|---|
| `parametros` | List | R₀, incubation period, infectious period, IFR |
| `recursos` | List | ICU rate, ventilator rate, hospital stay days, ICU capacity, ventilator availability, healthcare staff |
| `poblacion` | Numeric | Total population |

Note: field names (`parametros`, `recursos`, `poblacion`) originate from the source
dataset and must not be renamed in the codebase.

### Adding a new dataset source

To integrate a new data source, extend `get_data()` in `data_interface.R` with a
new source key, ensure the returned data frame passes `validate_schema()`, and add
the corresponding option to the `selectInput` in `mod_entry.R`.

---

## 9. Visual Design System

The interface follows the PPT brand guidelines defined in the Wellcome / CEMIC style template.

### Colour palette

| Role | Name | Hex |
|---|---|---|
| Primary / navbar | Dark green | `#324027` |
| Secondary surface | Earthy green | `#48553F` |
| Accent (sparingly) | Orange | `#F59342` |
| Body text | Near black | `#1E2A16` |
| Page background | Green grey tint | `#F4F6F5` |
| Panel / input background | Earthy tint | `#F8F5F1` |
| Border | Grey | `#D0D4CE` |

### Simplified View alarm palette

| State | Shape | Hex |
|---|---|---|
| Controlled | Circle | `#3EA27F` PPT sea green |
| Warning | Triangle | `#F59342` PPT orange |
| Critical | Square | `#752111` PPT dark red |

### Chart colours — categorical data

| Series | Colour name | Hex |
|---|---|---|
| Susceptible | Near black | `#1E2A16` |
| Exposed | Burnt orange | `#D17E38` |
| Infectious | Dark stone | `#444443` |
| Recovered | Sea green | `#3EA27F` |

### Chart colours — accent

| Series | Hex |
|---|---|
| Cumulative cases / capacity line | `#324027` |
| Cumulative deaths / demand line | `#F59342` |
| Excess demand ribbon | `#F0D9C8` |

All chart styling is centralised in the `ppt_theme()` function inside `mod_viz.R`.

---

## 10. Deployment

### shinyapps.io

```r
library(rsconnect)

rsconnect::deployApp(
  appDir      = ".",
  appName     = "bowie-seir",
  forceUpdate = TRUE
)
```

### Self-hosted Shiny Server

Copy the repository to the Shiny Server apps directory (typically `/srv/shiny-server/`)
and ensure all R package dependencies are installed in the server's R library path.

### Environment variables for production

```bash
LOG_LEVEL=WARN   # suppress DEBUG and INFO output in production
```

---

## 11. Known Limitations

| Limitation | Status |
|---|---|
| User CSV upload | Pending — Block 5b (post-review) |
| External data connectivity (WHO, OWID APIs) | Pending — Block 6 |
| Sociodemographic data layer | Pending — Block 6 |
| Interactive presentation with practical exercises | Pending — Block 7 |
| ICU / ventilator occupancy uses a rolling sum approximation | By design — a queueing model would require individual-level data not available at this stage |
| IFR is applied as a global value | By design — age-stratified IFR is outside the current ToR scope |
| Simplified View ICU KPI uses peak daily admissions, capped at > 100% | By design — peak `ICU_Daily_Demand` as % of capacity can reach thousands of percent under high-transmission scenarios (e.g. R0=2.5 → ~7772%). Values above 100% are displayed as "> 100%" because the difference between 500% and 7000% does not change any decision; system collapse is the signal. |

---

## 12. References

[^1]: Instituto de Efectividad Clínica y Sanitaria (IECS). *Modelo epidemiológico y evaluación económica de intervenciones frente a COVID-19 en Argentina.* Available at: https://www.iecs.org.ar/wp-content/uploads/Modelo-epi-y-eval-econ_para-web.pdf

[^2]: Grasselli G, Zangrillo A, Zanella A, et al. Baseline characteristics and outcomes of 1591 patients infected with SARS-CoV-2 admitted to ICUs of the Lombardy Region, Italy. *JAMA.* 2020;323(16):1574–1581. Available at: https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0246318

[^3]: Sociedad Argentina de Terapia Intensiva (SATI). *Camas de cuidados intensivos en Argentina.* Available at: https://www.scielo.org.ar/scielo.php?script=sci_arttext&pid=S0025-76802022000100035

[^4]: Comes Y, Solitario R, Garbus P, et al. *El trabajo en salud en Argentina.* CONICET Digital. Available at: https://ri.conicet.gov.ar/bitstream/handle/11336/161336/CONICET_Digital_Nro.9508fef7-fcb8-4e0e-9bcd-8c593177d630_A.pdf

[^5]: Instituto Nacional de Estadística y Censos (INDEC). *Proyecciones de población.* Available at: https://www.indec.gob.ar/indec/web/Nivel4-Tema-2-24-84

---

**Maintainer:** Cristian Paez  
**Version:** 1.1 — March 2026  
**Project:** Pandemic Preparedness Toolkit (Argentina Unit)  
**Funded by:** Wellcome
