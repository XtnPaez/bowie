# Bowie – SEIR Epidemiological Dashboard

> **Pandemic Preparedness Toolkit – Argentina Unit**  
> Funded by [Wellcome](https://wellcome.org) · Developed at [CEMIC](https://www.cemic.edu.ar)

[![Live Demo](https://img.shields.io/badge/Live%20Demo-shinyapps.io-18BC9C?style=flat-square)](https://cpaez.shinyapps.io/bowie-seir/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)](LICENSE)
[![R](https://img.shields.io/badge/R-%3E%3D%204.3-276DC3?style=flat-square)](https://www.r-project.org/)

---

## Overview

**Bowie** is a modular, interactive Shiny dashboard for infectious disease modelling, developed as
**Product 2** of the Pandemic Preparedness Toolkit (Argentina Unit), Work Package 5 (WP5).

It implements a **SEIR (Susceptible–Exposed–Infectious–Recovered)** compartmental model with
real-time parameter adjustment, scenario simulation, and healthcare resource pressure analysis.
The platform is designed to support evidence-based decision-making in public health by enabling
interactive scenario exploration, resource planning, and educational use across multiple user groups.

**Live deployment:** https://cpaez.shinyapps.io/bowie-seir/

---

## ToR Products

This repository covers three ToR deliverables:

| Product | Description | Status |
|---------|-------------|--------|
| **Product 1** | COVID-19 Argentina case study — interactive via IECS/Santoro dataset | 🟡 60% |
| **Product 2** | Modular Shiny Dashboard prototype | 🟡 65% |
| **Product 3** | Implementation and User Guides | 🟡 20% |

See [`proj_evolution.md`](proj_evolution.md) for detailed ToR alignment and progress breakdown.

---

## Features

- **Interactive SEIR simulation** — adjust R₀, incubation period, infectious period, and IFR in real time
- **Public policy modelling** — simulate four intervention strategies: no intervention, phased mitigation, intermittent, and ICU-triggered
- **Healthcare resource pressure analysis** — compare simulated ICU and ventilator demand against configurable capacity thresholds
- **COVID-19 Argentina case study** — the IECS/Santoro dataset contains real COVID-19 Argentina data, loadable directly in the dashboard (ToR Product 1)
- **Dual dataset support** — simulated (mock) or real (IECS/Santoro) datasets
- **CSV export** — download full simulation results in European locale format
- **Modular open-source architecture** — clean separation between data, model, visualisation, UI, and server layers; easily modifiable for SIR, SEIRD, or custom models

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
├── proj_evolution.md            # ToR alignment and progress report (March 2026)
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
│   └── iecs_data.RData          # IECS/Santoro — real COVID-19 Argentina data (ToR Product 1)
│
├── docs/
│   └── documentacion.Rmd        # Technical documentation — Product 3 (translation in progress)
│
└── www/
    └── custom.css               # Visual overrides for bslib / Bootstrap 5
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
cd bowie
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

1. **Select a dataset** on the entry screen and click **Load Dataset**:
   - **Simulated (mock)** — synthetic data for parameter exploration
   - **IECS / Santoro** — real COVID-19 Argentina data (interactive case study)
2. Navigate to **Advanced View**
3. Adjust epidemiological, policy, and resource parameters using the sidebar controls
4. Explore results across three tabs:
   - **Epidemic Curves** — SEIR compartment dynamics and cumulative cases/deaths
   - **Resource Pressure** — ICU and ventilator demand vs. capacity thresholds
   - **Simulated Data** — tabular preview and CSV download

> **Simple View** is currently disabled — implementation planned for the next phase (ToR requirement).

---

## Development Status

| Block | ToR Requirement | Status |
|-------|----------------|--------|
| 1–4. Foundation | Modular architecture, Data Hub, UX | ✅ Complete |
| 5. Simplified Visualisation | Decision-maker interface with KPIs | 🟡 In progress |
| 6. External Data Connectivity | WHO / OWID API integration | 🔴 Pending |
| 7. Sociodemographic Data | Demographics and mobility layer | 🔴 Pending |
| 8. Interactive Presentation | Infographic and practical exercises | 🔴 Pending |
| Product 3 | Implementation and User Guides | 🟡 Draft in progress |

Overall ToR coverage: **≈ 77%** — see [`proj_evolution.md`](proj_evolution.md) for full breakdown.

---

## Documentation

Technical documentation (Product 3) is available in [`docs/documentacion.Rmd`](docs/documentacion.Rmd).  
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
Bowie / proto\_epi — Pandemic Preparedness Toolkit (Argentina Unit)  
Funded by Wellcome
