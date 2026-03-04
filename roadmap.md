# Bowie / SEIR Shiny – Roadmap and Strategic Plan

## Introduction

The SEIR Shiny dashboard has evolved from a modular prototype into a **deployed, interactive epidemiological simulation platform**.  
This document reflects the current development state as of March 2026 and outlines the remaining work ahead.  
The project is part of the **Pandemic Preparedness Toolkit (Argentina Unit)**, funded by Wellcome.

**Live deployment:** <https://cpaez.shinyapps.io/bowie-seir/>  
**Repository:** <https://github.com/XtnPaez/bowie>

---

## Strengths and Achievements

- Modular workflow `data → model → viz → ui → server` — fully implemented and stable.
- SEIR ODE model running with `deSolve`, validated against known parameters.
- Data Hub Interface (`data_interface.R`) — loading, validation, schema checks, and caching.
- Entry screen with dataset selection (mock and IECS datasets).
- Advanced View with sticky parameter panel, real-time curve updates, and resource pressure plots.
- Top navigation menu with dataset indicator.
- CSV export of simulation results with European locale formatting.
- Public deployment on shinyapps.io.
- Full documentation: `CODESTYLE.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`.
- English-only codebase for international consistency.

---

## Current Limitations

- Simple View not yet implemented (button visible but disabled — "Coming soon").
- No integrated test suite (`testthat` / `shinytest2` planned).
- No CI/CD pipeline yet (GitHub Actions planned).
- External data connectivity (WHO, OWID APIs) not yet implemented.
- Model Hub (plug-in architecture for additional models) pending.

---

## Roadmap

### ✅ Block 1 – Core Refactor
**Goal:** Reproducible, modular, and scalable architecture.  
**Status:** Complete.

### ✅ Block 2 – Code Internationalisation
**Goal:** English-only codebase and clean UI.  
**Status:** Complete.

### ✅ Block 3 – Data Hub Interface
**Goal:** Centralised dataset loading, validation, and persistence via `data_interface.R`.  
**Status:** Complete. Functions implemented: `get_data()`, `validate_schema()`, `save_dataset()`, `list_datasets()`, `load_iecs_data()`.

### ✅ Block 4 – User Experience Redesign
**Goal:** Entry screen, navigation menu, and Advanced View layout.  
**Status:** Complete. Includes sticky sidebar, dataset selector, top menu, and view routing.

### 🔹 Block 5 – Simplified Visualisation Mode
**Goal:** A simplified "decision-maker" interface with core SEIR plots and KPIs only.  
**Status:** 🟡 In progress — UI placeholder in place, implementation pending.  
**Subtasks:**
- Create `mod_viz_simple.R` with SEIR curves, peak infection KPI, and resource summary.
- Hide complex parameter controls.
- Wire Simple View routing in `app.R`.

### 🔹 Block 6 – Model Hub Expansion
**Goal:** Plug-in architecture to support additional compartmental models (SIR, SEIRD, etc.).  
**Status:** 🔴 Planned.  
**Subtasks:**
- Create `/models/` folder and `model_registry.R`.
- Define model API: `init()`, `run()`, `describe()`, `schema_in/out`.
- Integrate model-specific UI controls dynamically.

### 🔹 Block 7 – External Data Connectivity
**Goal:** Connect to real-time epidemiological data sources via API.  
**Status:** 🔴 Planned.  
**Subtasks:**
- Integrate WHO and OWID APIs via `httr` / `jsonlite`.
- Add sociodemographic data layer (population, mobility).
- Extend `data_interface.R` with API source handler.

### 🔹 Block 8 – Testing and CI/CD
**Goal:** Robustness, reproducibility, and automated validation.  
**Status:** 🔴 Planned.  
**Subtasks:**
- Unit tests with `testthat`.
- UI tests with `shinytest2`.
- CI/CD pipeline with GitHub Actions.
- Reproducibility snapshot with `renv::snapshot()`.

---

## Dependencies and Execution

| Block | Depends On | Status |
|-------|------------|--------|
| **1. Core Refactor** | – | ✅ Complete |
| **2. Internationalisation** | 1 | ✅ Complete |
| **3. Data Hub Interface** | 1 | ✅ Complete |
| **4. UX Redesign** | 3 | ✅ Complete |
| **5. Simplified Visualisation** | 3, 4 | 🟡 In progress |
| **6. Model Hub** | 3, 4 | 🔴 Planned |
| **7. External Data Connectivity** | 3 | 🔴 Planned |
| **8. Testing and CI/CD** | All | 🔴 Planned |

---

## Summary

The SEIR Shiny project has successfully transitioned from a prototype into a **deployed, functional modelling platform**.  
The technical and UX foundations are stable. Remaining work focuses on the Simplified View, Model Hub expansion, external data connectivity, and test coverage.

**Maintainer:** Cristian Paez  
**Date:** March 2026  
**Project:** Bowie / proto\_epi — Pandemic Preparedness Toolkit (Argentina Unit)
