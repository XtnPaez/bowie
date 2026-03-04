# Bowie – SEIR Epidemiological Dashboard

> **Pandemic Preparedness Toolkit – Argentina Unit**  
> Funded by [Wellcome](https://wellcome.org) · Developed at [CEMIC](https://www.cemic.edu.ar)

[![Live Demo](https://img.shields.io/badge/Live%20Demo-shinyapps.io-18BC9C?style=flat-square)](https://cpaez.shinyapps.io/bowie-seir/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)](LICENSE)
[![R](https://img.shields.io/badge/R-%3E%3D%204.3-276DC3?style=flat-square)](https://www.r-project.org/)

---

## Overview

**Bowie** is a modular, interactive Shiny dashboard for infectious disease modelling. It implements a **SEIR (Susceptible–Exposed–Infectious–Recovered)** compartmental model with real-time parameter adjustment, scenario simulation, and healthcare resource pressure analysis.

The platform is developed as **Product 2** of the Pandemic Preparedness Toolkit (Argentina Unit), part of Work Package 5 (WP5). Its goal is to support evidence-based decision-making in public health by enabling interactive scenario exploration, resource planning, and educational use.

**Live deployment:** https://cpaez.shinyapps.io/bowie-seir/

---

## Features

- **Interactive SEIR simulation** — adjust R₀, incubation period, infectious period, and IFR in real time
- **Public policy modelling** — simulate four intervention strategies: no intervention, phased mitigation, intermittent, and ICU-triggered
- **Healthcare resource pressure analysis** — compare simulated ICU and ventilator demand against configurable capacity thresholds
- **Dual dataset support** — load simulated (mock) or IECS (Santoro) datasets
- **CSV export** — download full simulation results in European locale format
- **Modular architecture** — clean separation between data, model, visualisation, UI, and server layers
- **Structured logging and validation** — all parameters validated before model execution

---

## Project Structure

```
bowie/
├── app.R                        # Application entry point
├── DESCRIPTION                  # Package metadata and dependencies
├── LICENSE                      # MIT licence
├── NAMESPACE                    # Package namespace
├── README.md                    # This file
├── CODESTYLE.md                 # Coding and commenting standards
├── CONTRIBUTING.md              # Contribution guidelines
├── CODE_OF_CONDUCT.md           # Community standards
├── roadmap.md                   # Strategic roadmap and block status
├── proj_evolution.md            # Progress status report (March 2026)
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
│   └── iecs_data.RData          # IECS (Santoro) dataset
│
├── docs/
│   └── documentacion.Rmd        # Technical documentation (translation in progress)
│
└── www/
    └── custom.css               # Visual overrides for bslib / Bootstrap 5
```

---

## Setup

### Prerequisites

- R >= 4.3
- The following packages (see `DESCRIPTION` for full list):

```r
install.packages(c(
  "shiny", "shinyjs", "bslib", "ggplot2", "plotly",
  "dplyr", "tidyr", "purrr", "scales", "lubridate",
  "deSolve", "RcppRoll", "rsconnect"
))
```

### Run locally

1. Clone the repository:

```bash
git clone https://github.com/XtnPaez/bowie.git
cd bowie
```

2. Open the project in RStudio and run:

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

1. **Select a dataset** on the entry screen (Simulated or IECS) and click **Load Dataset**
2. Navigate to **Advanced View**
3. Adjust epidemiological, policy, and resource parameters using the sidebar controls
4. Explore results across three tabs:
   - **Epidemic Curves** — SEIR compartment dynamics and cumulative cases/deaths
   - **Resource Pressure** — ICU and ventilator demand vs. capacity thresholds
   - **Simulated Data** — tabular preview and CSV download

> **Simple View** is currently disabled — implementation planned for the next phase.

---

## Development Status

| Block | Description | Status |
|-------|-------------|--------|
| 1. Core Refactor | Modular architecture, logging, validation | ✅ Complete |
| 2. Internationalisation | English-only codebase | ✅ Complete |
| 3. Data Hub Interface | `data_interface.R` — loading, validation, persistence | ✅ Complete |
| 4. UX Redesign | Entry screen, navigation, Advanced View | ✅ Complete |
| 5. Simplified Visualisation | Simple View with KPIs for decision-makers | 🟡 In progress |
| 6. Model Hub | Plug-in architecture for additional models | 🔴 Planned |
| 7. External Data Connectivity | WHO / OWID API integration | 🔴 Planned |
| 8. Testing and CI/CD | `testthat`, `shinytest2`, GitHub Actions | 🔴 Planned |

Overall progress: **≈ 80%** — see [`proj_evolution.md`](proj_evolution.md) for full breakdown.

---

## Documentation

Technical documentation is available in [`docs/documentacion.Rmd`](docs/documentacion.Rmd).  
⚠️ Translation from Spanish to English is currently in progress.

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
Bowie / proto\_epi — Pandemic Preparedness Toolkit (Argentina Unit)  
Funded by Wellcome
