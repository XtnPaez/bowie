# SEIR Epidemiological Dashboard

> **Pandemic Preparedness Toolkit – Argentina Unit · Product 2**  
> Funded by [Wellcome](https://wellcome.org) · Developed at [CEMIC](https://www.cemic.edu.ar)

[![Live Demo](https://img.shields.io/badge/Live%20Demo-shinyapps.io-324027?style=flat-square)](https://cpaez.shinyapps.io/bowie-seir/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)](LICENSE)
[![R](https://img.shields.io/badge/R-%3E%3D%204.3-276DC3?style=flat-square)](https://www.r-project.org/)

---

## Overview

A modular, interactive Shiny dashboard for infectious disease modelling. Implements a
**SEIR (Susceptible–Exposed–Infectious–Recovered)** compartmental model with real-time parameter
adjustment, scenario simulation, and healthcare resource pressure analysis.

The platform is developed as **Product 2** of the Pandemic Preparedness Toolkit (Argentina Unit),
Work Package 5 (WP5). Its goal is to support evidence-based decision-making in public health by
enabling interactive scenario exploration, resource planning, and educational use.

**Live deployment:** https://cpaez.shinyapps.io/bowie-seir/

---

## Features

- **Interactive SEIR simulation** — adjust R₀, incubation period, infectious period, and IFR in real time
- **Public policy modelling** — simulate four intervention strategies: no intervention, phased mitigation, intermittent, and ICU-triggered
- **Healthcare resource pressure analysis** — compare simulated ICU and ventilator demand against configurable capacity thresholds
- **Dual dataset support** — simulated (mock) or real (IECS/Santoro) datasets
- **CSV export** — download full simulation results in European locale format
- **Modular open-source architecture** — clean separation between data, model, visualisation, UI, and server layers; easily modifiable for SIR, SEIRD, or custom models as per ToR specification
- **PPT-aligned visual design** — UI and chart colours follow the Pandemic Preparedness Toolkit brand palette (Wellcome / CEMIC)

---

## Visual Design

The interface follows the **PPT brand guidelines** defined in the Pandemic Preparedness Toolkit
style template. Colour usage:

| Role | Colour | Hex |
|------|--------|-----|
| Primary / navbar | Dark green | `#324027` |
| Secondary surface | Earthy green | `#48553F` |
| Accent (sparingly) | Orange | `#F59342` |
| Body text | Near black | `#1E2A16` |
| Page background | Green grey tint | `#F4F6F5` |
| Panel background | Earthy tint | `#F8F5F1` |

Chart colours for categorical data visualisations follow the PPT order:
near black `#1E2A16` → burnt orange `#D17E38` → dark stone `#444443` → sea green `#3EA27F`.

---

## Project Structure

```
seir-dashboard/
├── app.R                        # Application entry point
├── DESCRIPTION                  # Package metadata and dependencies
├── LICENSE                      # MIT licence
├── NAMESPACE                    # Package namespace
├── README.md                    # This file
├── CODESTYLE.md                 # Coding and commenting standards
├── CONTRIBUTING.md              # Contribution guidelines
├── CODE_OF_CONDUCT.md           # Community standards
├── roadmap.md                   # Strategic roadmap and block status
├── proj_evolution.md            # ToR alignment and progress report
│
├── R/
│   ├── global.R                 # Global constants and library loading
│   ├── data_interface.R         # Data Hub: loading, validation, persistence
│   ├── mod_entry.R              # Entry screen module
│   ├── mod_menu.R               # Top navigation menu module
│   ├── mod_ui.R                 # Main UI layout and parameter panels
│   ├── mod_server.R             # Main server: parameters, model wiring
│   ├── mod_model.R              # SEIR ODE model logic
│   ├── mod_viz.R                # Visualisation module (ggplot2)
│   ├── mod_data.R               # Data simulation module
│   ├── mod_server_reactivity.R  # Cross-module reactivity scaffold (planned)
│   └── utils/
│       ├── utils_logging.R      # Structured logging utilities
│       ├── utils_validation.R   # Parameter validation utilities
│       ├── utils_helpers.R      # Numeric helpers and safe ODE wrapper
│       └── utils_dependencies.R # Automatic dependency detection
│
├── data/
│   ├── mock_dataset.rds         # Simulated default dataset
│   └── iecs_data.RData          # IECS/Santoro — real COVID-19 Argentina data
│
├── docs/
│   └── documentacion.Rmd        # Technical documentation (translation in progress)
│
└── www/
    └── custom.css               # Visual overrides — PPT brand palette
```

---

## Setup

### Prerequisites

- R >= 4.3
- Required packages (see `DESCRIPTION` for full list):

```r
install.packages(c(
  "shiny", "shinyjs", "bslib", "ggplot2", "plotly",
  "dplyr", "tidyr", "purrr", "scales", "lubridate",
  "deSolve", "RcppRoll", "rsconnect"
))
```

### Run locally

```bash
git clone https://github.com/XtnPaez/bowie.git
cd bowie  # repository folder name
```

```r
shiny::runApp()
```

### Deploy to shinyapps.io

```r
rsconnect::deployApp(
  appDir = ".",
  appName = "bowie-seir",
  forceUpdate = TRUE
)
```

---

## Usage

1. **Select a dataset** on the entry screen and click **Load dataset**:
   - **Simulated (mock)** — synthetic data for parameter exploration
   - **IECS / Santoro** — real COVID-19 Argentina data
2. Navigate to **Advanced View**
3. Adjust epidemiological, policy, and resource parameters using the sidebar controls
4. Explore results across three tabs:
   - **Epidemic Curves** — SEIR compartment dynamics and cumulative cases/deaths
   - **Resource Pressure** — ICU and ventilator demand vs. capacity thresholds
   - **Simulated Data** — tabular preview and CSV download

> **Simple View** is currently disabled — implementation planned for the next phase.

---

## Development Status

| Block | ToR Requirement | Status |
|-------|----------------|--------|
| 1–4. Foundation | Modular architecture, Data Hub, UX | ✅ Complete |
| 4b. UI Polish | PPT brand palette, namespace fixes, deprecation fixes | ✅ Complete |
| 5. Simplified Visualisation | Decision-maker interface with KPIs | 🟡 In progress |
| 6. External Data + Sociodemographic | WHO / OWID APIs + demographics layer | 🔴 Pending |
| 7. Interactive Presentation | Infographic and practical exercises | 🔴 Pending |

Overall ToR coverage: **≈ 85%** — see [`proj_evolution.md`](proj_evolution.md) for full breakdown.

---

## Documentation

Technical documentation is available in [`docs/documentacion.Rmd`](docs/documentacion.Rmd).  
⚠️ Currently in Spanish — translation and update in progress.

For coding standards, see [`CODESTYLE.md`](CODESTYLE.md).  
For contribution guidelines, see [`CONTRIBUTING.md`](CONTRIBUTING.md).

---

## Roadmap

See [`roadmap.md`](roadmap.md) for the full strategic plan and block dependencies.

---

## Licence

MIT License — see [`LICENSE`](LICENSE) for details.

---

## Authors

**Cristian Paez** — Lead Developer  
paez.cristian@gmail.com  
Pandemic Preparedness Toolkit (Argentina Unit)  
Funded by Wellcome
