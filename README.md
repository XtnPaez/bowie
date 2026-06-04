# SEIR Epidemiological Dashboard

> **Analysis for Action – Argentina Unit · Product 2**

[![Live Demo](https://img.shields.io/badge/Live%20Demo-shinyapps.io-324027?style=flat-square)](https://cpaez.shinyapps.io/bowie-seir/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)](LICENSE)
[![R](https://img.shields.io/badge/R-%3E%3D%204.4-276DC3?style=flat-square)](https://www.r-project.org/)

---

## Overview

A modular, interactive Shiny dashboard for infectious disease modelling. Implements a
**SEIR (Susceptible–Exposed–Infectious–Recovered)** compartmental model with real-time parameter
adjustment, scenario simulation, and healthcare resource pressure analysis.

The platform is developed as **Product 2** of the Analysis for Action (Argentina Unit).
Its goal is to support evidence-based decision-making in public health by
enabling interactive scenario exploration, resource planning, and educational use.

**Live deployment:** https://cpaez.shinyapps.io/bowie-seir/

---

## Features

- **Interactive SEIR simulation** — adjust R₀, incubation period, infectious period, and IFR in real time
- **Public policy modelling** — simulate four intervention strategies: no intervention, phased mitigation, intermittent, and ICU-triggered
- **Healthcare resource pressure analysis** — compare simulated ICU and ventilator demand against configurable capacity thresholds
- **Simplified View** — decision-maker interface with three KPI alarm cards (Epidemic Trajectory, ICU Pressure, Cumulative Impact) using a geometric colour-coded alarm system
- **Advanced View** — full parameter control for technical users, including simulation scope (population, start date, end date)
- **Three dataset sources** — simulated (mock), IECS / Santoro (real Argentine COVID-19 parameters), or user-uploaded CSV
- **CSV upload** — load your own regional parameter snapshot via a guided modal dialog; the platform uses it as the starting point for simulation
- **CSV export** — download full simulation results in European locale format
- **Dual-view initialisation** — both views initialise from the same loaded dataset, then evolve independently
- **Modular open-source architecture** — clean separation between data, model, visualisation, UI, and server layers; easily modifiable for SIR, SEIRD, or custom models per ToR specification
- **AfA-aligned visual design** — UI and chart colours follow the Analysis for Action brand palette

---

## Visual Design

The interface follows the **AfA brand guidelines** defined in the Analysis for Action
style template. Colour usage:

| Role | Colour | Hex |
|------|--------|-----|
| Primary / navbar | Dark green | `#324027` |
| Secondary surface | Earthy green | `#48553F` |
| Accent (sparingly) | Orange | `#F59342` |
| Body text | Near black | `#1E2A16` |
| Page background | Green grey tint | `#F4F6F5` |
| Panel background | Earthy tint | `#F8F5F1` |

Chart colours for categorical data visualisations follow the AfA order:
near black `#1E2A16` → burnt orange `#D17E38` → dark stone `#444443` → sea green `#3EA27F`.

---

## Repository Structure

```
bowie/
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
│   ├── mod_entry.R              # Entry screen and CSV upload module
│   ├── mod_menu.R               # Top navigation menu module
│   ├── mod_ui.R                 # Advanced View UI layout and panels
│   ├── mod_ui_simple.R          # Simplified View UI layout and KPI cards
│   ├── mod_server.R             # Main server: parameter wiring, model orchestration
│   ├── mod_server_simple.R      # Simplified View server: isolated SEIR + alarm logic
│   ├── mod_helpers_simple.R     # Shared helpers: alarm shapes, state labels, metrics
│   ├── mod_model.R              # SEIR ODE model logic
│   ├── mod_viz.R                # Visualisation module (ggplot2)
│   ├── mod_data.R               # Data simulation module
│   └── utils/
│       ├── utils_logging.R      # Structured logging utilities
│       ├── utils_validation.R   # Parameter and schema validation
│       ├── utils_helpers.R      # Numeric helpers and safe ODE wrapper
│       └── utils_dependencies.R # Automatic dependency detection and loading
│
├── data/
│   ├── mock_dataset.rds         # Simulated default dataset
│   ├── iecs_data.rds            # IECS / Santoro — real COVID-19 Argentina parameters
│   └── cache/                   # Auto-generated: cached datasets
│
├── data-raw/
│   └── prepare_iecs.R           # Reproducible script to regenerate iecs_data.rds
│
├── docs/
│   └── implementation_guide.md  # Full technical documentation (Product 3a)
│
└── www/
    └── custom.css               # Visual overrides — AfA brand palette
```

---

## Installation

```bash
git clone https://github.com/XtnPaez/bowie.git
cd bowie
```

```r
# Install dependencies
install.packages(c(
  "shiny", "shinyjs", "bslib", "ggplot2", "dplyr", "tidyr",
  "purrr", "scales", "lubridate", "deSolve", "RcppRoll",
  "plotly", "rsconnect", "stringr"
))

# Run locally
shiny::runApp()
```

---

## Dataset Sources

The platform supports three dataset sources, selectable from the entry screen:

| Source | Description |
|--------|-------------|
| Simulated (mock) | Synthetic dataset generated from default epidemiological parameters. Use for free exploration. |
| IECS / Santoro | Real COVID-19 parameters for Argentina, derived from Santoro et al. (2022). Use for empirically grounded simulation. |
| Upload your own (CSV) | Upload a two-column CSV (`parameter`, `value`) with your regional epidemiological and resource parameters. See the modal dialog for the full field specification. |

To regenerate the IECS dataset from source parameters:

```r
source("data-raw/prepare_iecs.R")
```

---

## Deployment

```r
library(rsconnect)
rsconnect::deployApp(
  appDir      = ".",
  appName     = "bowie-seir",
  forceUpdate = TRUE
)
```

---

## Documentation

- **Implementation Guide** (`docs/implementation_guide.md`) — module architecture, SEIR equations, dataset specification, visual design system, deployment instructions
- **Roadmap** (`roadmap.md`) — development blocks and delivery status
- **Project Evolution** (`proj_evolution.md`) — ToR alignment and progress report

---

## References

Santoro A, López Osornio A, Williams I, et al. Development and application of a dynamic
transmission model of health systems' preparedness and response to COVID-19 in twenty-six
Latin American and Caribbean countries. *PLOS Glob Public Health.* 2022;2(3):e0000186.
https://doi.org/10.1371/journal.pgph.0000186

---

**Maintainer:** Cristian Paez  
**Project:** Analysis for Action (Argentina Unit)  
**Date:** May 2026
