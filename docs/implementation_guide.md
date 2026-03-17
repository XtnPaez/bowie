# Implementation Guide — SEIR Epidemiological Dashboard

**Pandemic Preparedness Toolkit · Argentina Unit · Product 3**  
**Work Package 5 · WP5**

| | |
|---|---|
| **Author** | Cristian Paez |
| **Organisation** | CEMIC |
| **Funded by** | Wellcome |
| **Version** | 1.0 |
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

- Web server: shinyapps.io (current) or self-hosted Shiny Server
- No database management system is required. Datasets are stored as `.rds` and `.RData`
  files in the `data/` directory.
- API integration capabilities are reserved for a future release (Block 6).

---

## 3. Repository Structure

```
seir-dashboard/
├── app.R                        # Application entry point
├── DESCRIPTION                  # R package metadata and dependencies
├── LICENSE                      # MIT licence
├── NAMESPACE                    # R package namespace
├── README.md                    # Project overview
├── CODESTYLE.md                 # Coding and commenting standards
├── roadmap.md                   # Strategic roadmap and block status
├── proj_evolution.md            # ToR alignment and progress report
│
├── R/
│   ├── global.R                 # Global constants and library loading
│   ├── data_interface.R         # Data Hub: loading, validation, caching
│   ├── mod_entry.R              # Entry screen module
│   ├── mod_menu.R               # Top navigation menu module
│   ├── mod_ui.R                 # Advanced View UI layout and panels
│   ├── mod_server.R             # Main server: parameter wiring, model orchestration
│   ├── mod_server_reactivity.R  # Cross-module reactivity scaffold (planned)
│   ├── mod_model.R              # SEIR ODE model logic
│   ├── mod_viz.R                # Visualisation module
│   ├── mod_data.R               # Data simulation module
│   └── utils/
│       ├── utils_logging.R      # Structured logging utilities
│       ├── utils_validation.R   # Parameter and schema validation
│       ├── utils_helpers.R      # Numeric helpers and safe ODE wrapper
│       └── utils_dependencies.R # Automatic dependency detection and loading
│
├── data/
│   ├── mock_dataset.rds         # Simulated default dataset
│   ├── iecs_data.RData          # IECS / Santoro — real COVID-19 Argentina data
│   └── cache/                   # Auto-generated: cached datasets (save_dataset())
│
├── docs/
│   └── implementation_guide.md  # This document
│
└── www/
    └── custom.css               # Visual overrides — PPT brand palette
```

---

## 4. Installation and Local Setup

### Clone the repository

```bash
git clone https://github.com/XtnPaez/bowie.git
cd bowie  # repository folder name
```

### Install dependencies

```r
# From an R or RStudio session
install.packages(c(
  "shiny", "shinyjs", "bslib", "ggplot2", "dplyr", "tidyr",
  "purrr", "scales", "lubridate", "deSolve", "RcppRoll",
  "plotly", "rsconnect", "stringr"
))
```

Alternatively, if a `DESCRIPTION` file is present, `renv` or `pak` can resolve
all dependencies automatically:

```r
pak::pak()  # resolves from DESCRIPTION
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
  style strings (e.g., `#controls-col::-webkit-scrollbar`) from being parsed as
  package names.

---

## 5. Configuration

All global constants are defined in `R/global.R`. Modifying this file is the single
point of change for default simulation parameters.

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

The application follows a strict modular pipeline:

```
data_interface  →  mod_data  →  mod_model  →  mod_viz
                                    ↑
                              mod_server
                             ↗          ↖
                        mod_entry      mod_menu
                             ↖          ↗
                                app.R
                                  ↑
                               mod_ui
```

All modules are loaded automatically by Shiny's `loadSupport()` mechanism because
the project contains a `DESCRIPTION` file. Manual `source()` calls in `app.R` are
not required.

### app.R — Application entry point

Defines the root UI and server. Manages top-level reactive state (`screen`,
`dataset_selector`, `dataset_loaded`, `trigger_sim`) and wires all modules together.

**Namespace contract (critical):** `viz_plot_server()` must be called from the
top-level server function in `app.R`, not from inside `mod_server()`. If called from
within `mod_server()` (which itself runs under the `"viz_advanced"` namespace),
output ids accumulate as `"viz_advanced-viz_advanced-seir_plot"`, which does not
match the `plotOutput` ids generated by `ui_main()`. The correct call site is `app.R`.

### global.R — Global constants and library loading

Loads all required libraries, defines all model constants, and dynamically sources
utility functions from `R/utils/`. Any constant used across more than one module is
defined here.

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

The IECS dataset is a named list with three elements whose names originate from the
source `.RData` file and must not be renamed: `parametros` (model parameters),
`recursos` (resource parameters), and `poblacion` (population size).

### mod_entry.R — Entry screen

Renders the entry screen with a PPT-branded navbar, a centred card containing the
dataset selector, load button, and status badge, and a footer attribution strip.
Server logic handles dataset loading, success and error feedback, and navigation to
the Advanced View.

### mod_menu.R — Top navigation menu

Renders a persistent dark green navbar injected above all non-entry views. Provides
the dataset indicator and three navigation buttons: Home, Simple (disabled pending
Block 5 implementation), and Advanced.

### mod_ui.R — Advanced View layout

Defines all UI layout functions for the Advanced View. Exposes four composable helpers:

| Function | Description |
|---|---|
| `ui_seir_params(ns)` | Epidemiological parameter panel (R₀, incubation, infectious period, IFR) |
| `ui_policy_params(ns)` | Public policy panel (intervention type, compliance level) |
| `ui_resource_params(ns)` | Healthcare resource panel (capacity inputs and rate sliders) |
| `ui_main(viz_id)` | Full page layout: sticky sidebar + tabbed output area + footer |

`ui_main()` uses a `tagList` wrapper (not `fluidPage`) to avoid Bootstrap container
padding that would prevent the navbar from sitting flush at the top.

### mod_server.R — Main server

Orchestrates the full simulation pipeline. Responsibilities:

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

### mod_server_reactivity.R — Cross-module reactivity scaffold

Reserved for future cross-module reactive bindings. Currently a scaffold with no
active wiring. Not called from `app.R` or any other module.

### mod_model.R — SEIR ODE model

Implements the SEIR differential equations and post-processing pipeline. Two functions:

`seir_equations(time, state, parameters)` — defines the ODE system. Returns derivatives
and new daily infections at each time step.

`model_seir_server(id, input_params, raw_data_df)` — Shiny module server. Observes
`trigger_sim`, validates parameters, applies effective R₀ under the selected policy,
solves the ODE system via `safe_ode()`, and post-processes results into a data frame
containing compartment values, cumulative cases and deaths, and ICU and ventilator
occupancy via rolling window sums. See Section 7 for the full mathematical specification.

### mod_viz.R — Visualisation module

Renders three plots from SEIR model output via `viz_plot_server()`. All plots share
a common `ppt_theme()` function that applies the PPT brand palette and X-axis guide
lines consistently. See Section 9 for colour specifications.

| Output | Description |
|---|---|
| `seir_plot` | SEIR compartment dynamics over time |
| `cases_deaths_plot` | Cumulative cases and deaths |
| `resource_pressure_plot` | ICU and ventilator demand vs. capacity, with ribbon shading for excess demand periods |

### mod_data.R — Data simulation module

Generates the initial time-series structure passed to `model_seir_server()` as
`raw_data_df`. Produces a data frame with columns `time`, `date`, `S`, `E`, `I`, `R`,
and auxiliary resource columns, initialised with a population of `N - 10,000`
susceptibles and `10,000` infected at `time = 0`. The ODE solver overwrites all
compartment values during integration.

### utils/utils_logging.R — Logging utilities

| Function | Description |
|---|---|
| `log_message(level, msg, .module, ...)` | Prints structured log lines with timestamp, level, module, and optional context key-value pairs |
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
| `coalesce_num(x, y)` | Replaces NA values with a fallback numeric |
| `not_null(x)` | Returns TRUE if object is not NULL |
| `safe_ode(...)` | Error-safe wrapper around `deSolve::ode()`; logs failures and re-throws with a clean message |

### utils/utils_dependencies.R — Automatic dependency loading

Scans all project source files for package references, filters false positives, and
installs and loads any missing packages at startup. See Section 4 for filter details.

---

## 7. SEIR Model — Equations and Parameters

### Compartmental structure

The model divides the population into four mutually exclusive compartments:

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
$R_0$ is reduced by 50%. The effective value is clamped to a minimum of 0.5 to
prevent biologically implausible results.

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

Where $h$ = `INITIAL_HOSPITAL_STAY_DAYS` (default: 10 days). The same formula
applies to `Vent_Usage_Sim`. For time points where fewer than $h$ days are available
(i.e., the start of the simulation), a cumulative sum is used as a fallback.

### Output data frame columns

| Column | Description |
|---|---|
| `date` | Simulation date |
| `S`, `E`, `I`, `R` | Compartment sizes (normalised to total population) |
| `Daily_New_Infections` | New infections per day ($\sigma \cdot E$) |
| `Cumulative_Cases` | Running total of new infections |
| `Daily_Deaths` | Daily deaths ($\text{Daily\_New\_Infections} \cdot \text{IFR}$) |
| `Cumulative_Deaths` | Running total of deaths |
| `ICU_Occupancy_Sim` | Estimated ICU bed occupancy |
| `Vent_Usage_Sim` | Estimated ventilator usage |

---

## 8. Dataset Sources

### Simulated dataset (mock)

Loaded from `data/mock_dataset.rds`. Provides a SEIR-compatible time-series
structure for parameter exploration without requiring real data. The initial state
is `S = N - 10,000`, `I = 10,000`, `E = 0`, `R = 0`.

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

Note: field names within this list (`parametros`, `recursos`, `poblacion`) originate
from the source dataset and must not be renamed in the codebase.

A legacy field name normalisation is applied automatically by `load_iecs_data()`:
the older prefix `INICIAL_` is converted to `INITIAL_` where present.

### Adding a new dataset source

To integrate a new data source, extend `get_data()` in `data_interface.R` with a
new source key, ensure the returned data frame passes `validate_schema()`, and add
the corresponding option to the `selectInput` in `mod_entry.R`.

---

## 9. Visual Design System

The interface follows the PPT (Pandemic Preparedness Toolkit) brand guidelines
defined in the Wellcome / CEMIC style template.

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

### Chart colours — categorical data

Applied in order for SEIR compartment plots:

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
This function also adds X-axis major and minor grid lines (`panel.grid.major.x`,
`panel.grid.minor.x`) to all three plots for readability.

---

## 10. Deployment

### shinyapps.io

```r
library(rsconnect)

rsconnect::deployApp(
  appDir     = ".",
  appName    = "bowie-seir",
  forceUpdate = TRUE
)
```

Ensure `rsconnect` is configured with a valid shinyapps.io account token before
deploying. See the rsconnect documentation for authentication setup.

### Self-hosted Shiny Server

Copy the repository to the Shiny Server apps directory (typically
`/srv/shiny-server/`) and ensure all R package dependencies are installed in the
server's R library path. No additional configuration is required beyond standard
Shiny Server setup.

### Environment variables for production

```bash
LOG_LEVEL=WARN   # suppress DEBUG and INFO output in production
```

---

## 11. Known Limitations

The following limitations reflect the current implementation scope as defined by
the ToR Product 2 requirements. Items not covered by the ToR are outside the
scope of this implementation.

| Limitation | Status |
|---|---|
| Simplified View (decision-maker interface with KPIs) | Pending — Block 5 |
| External data connectivity (WHO, OWID APIs) | Pending — Block 6 |
| Sociodemographic data layer | Pending — Block 6 |
| Interactive presentation with practical exercises | Pending — Block 7 |
| ICU / ventilator occupancy uses a rolling sum approximation | By design — a queueing model would require individual-level data not available at this stage |
| IFR is applied as a global value | By design — age-stratified IFR is outside the current ToR scope |

---

## 12. References

[^1]: Instituto de Efectividad Clínica y Sanitaria (IECS). *Modelo epidemiológico y evaluación económica de intervenciones frente a COVID-19 en Argentina.* Available at: https://www.iecs.org.ar/wp-content/uploads/Modelo-epi-y-eval-econ_para-web.pdf

[^2]: Grasselli G, Zangrillo A, Zanella A, et al. Baseline characteristics and outcomes of 1591 patients infected with SARS-CoV-2 admitted to ICUs of the Lombardy Region, Italy. *JAMA.* 2020;323(16):1574–1581. Available at: https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0246318

[^3]: Sociedad Argentina de Terapia Intensiva (SATI). *Camas de cuidados intensivos en Argentina.* Available at: https://www.scielo.org.ar/scielo.php?script=sci_arttext&pid=S0025-76802022000100035

[^4]: Comes Y, Solitario R, Garbus P, et al. *El trabajo en salud en Argentina.* CONICET Digital. Available at: https://ri.conicet.gov.ar/bitstream/handle/11336/161336/CONICET_Digital_Nro.9508fef7-fcb8-4e0e-9bcd-8c593177d630_A.pdf

[^5]: Instituto Nacional de Estadística y Censos (INDEC). *Proyecciones de población.* Available at: https://www.indec.gob.ar/indec/web/Nivel4-Tema-2-24-84

---

**Maintainer:** Cristian Paez  
**Project:** Pandemic Preparedness Toolkit (Argentina Unit)  
**Funded by:** Wellcome
