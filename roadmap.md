# Bowie / SEIR Shiny – Roadmap and Strategic Plan

## Introduction

The SEIR Shiny dashboard has evolved from a modular prototype into a **deployed, interactive
epidemiological simulation platform**.  
This document reflects the current development state as of March 2026 and outlines the remaining
work ahead.  
The project delivers **Product 2** of the Pandemic Preparedness Toolkit (Argentina Unit), Work
Package 5, funded by Wellcome.

**Live deployment:** <https://cpaez.shinyapps.io/bowie-seir/>  
**Repository:** <https://github.com/XtnPaez/bowie>

---

## Strengths and Achievements

- Modular workflow `data → model → viz → ui → server` — fully implemented and stable.
- SEIR ODE model running with `deSolve`, validated against known parameters.
- Open-source codebase — easily modifiable to incorporate SIR, SEIRD, or custom models per ToR specification.
- Data Hub Interface (`data_interface.R`) — loading, validation, schema checks, and caching.
- Entry screen with dataset selection (mock and IECS/Santoro datasets).
- Advanced View with sticky parameter panel, real-time curve updates, and resource pressure plots.
- Top navigation menu with dataset indicator.
- CSV export of simulation results with European locale formatting.
- Public deployment on shinyapps.io.
- Full repository documentation: `CODESTYLE.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`.

---

## Current Limitations

The following ToR requirements for Product 2 are pending:

- **Simplified View** — decision-maker interface with core SEIR plots and KPIs (button visible but disabled).
- **External data connectivity** — API integration with WHO, OWID, and national surveillance repositories.
- **Sociodemographic data layer** — population demographics, mobility patterns, and socioeconomic factors.
- **Interactive presentation with practical exercises** — visualisation principles infographic and guided exercises.

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
**Status:** Complete. Functions: `get_data()`, `validate_schema()`, `save_dataset()`,
`list_datasets()`, `load_iecs_data()`.

### ✅ Block 4 – User Experience Redesign
**Goal:** Entry screen, navigation menu, and Advanced View layout.  
**Status:** Complete. Includes sticky sidebar, dataset selector, top menu, and view routing.

### 🔹 Block 5 – Simplified Visualisation Mode (ToR)
**Goal:** A simplified decision-maker interface with core SEIR plots and KPIs only.  
**Status:** 🟡 In progress — UI placeholder in place, implementation pending.  
**Subtasks:**
- Create `mod_viz_simple.R` with SEIR curves, peak infection KPI, and resource summary.
- Hide complex parameter controls.
- Wire Simple View routing in `app.R`.

### 🔹 Block 6 – External Data Connectivity (ToR)
**Goal:** Connect to real-time epidemiological and sociodemographic data sources via API.  
**Status:** 🔴 Pending.  
**Subtasks:**
- Integrate WHO and OWID APIs via `httr` / `jsonlite`.
- Add sociodemographic data layer (population demographics, mobility patterns).
- Extend `data_interface.R` with API source handler.

### 🔹 Block 7 – Interactive Presentation and Practical Exercises (ToR)
**Goal:** Educational component illustrating effective dashboard use and visualisation principles.  
**Status:** 🔴 Pending.  
**Subtasks:**
- Design infographic covering visualisation principles (clarity, graph selection, colour, common errors).
- Develop practical exercises using real-life dashboard examples.
- Integrate or link from the platform.

---

## Dependencies and Execution

| Block | Depends On | Status |
|-------|------------|--------|
| **1. Core Refactor** | – | ✅ Complete |
| **2. Internationalisation** | 1 | ✅ Complete |
| **3. Data Hub Interface** | 1 | ✅ Complete |
| **4. UX Redesign** | 3 | ✅ Complete |
| **5. Simplified Visualisation** | 3, 4 | 🟡 In progress |
| **6. External Data + Sociodemographic** | 3 | 🔴 Pending |
| **7. Interactive Presentation** | 4, 5 | 🔴 Pending |

---

## Summary

The SEIR Shiny project has successfully transitioned from a prototype into a **deployed, functional
modelling platform**. The technical and UX foundations are stable and fully aligned with the ToR
modular architecture requirements. Remaining work focuses on three ToR deliverables: the Simplified
View, external data connectivity with sociodemographic layer, and the interactive presentation with
practical exercises.

**Maintainer:** Cristian Paez  
**Date:** March 2026  
**Project:** Bowie / proto\_epi — Pandemic Preparedness Toolkit (Argentina Unit)  
**Funded by:** Wellcome
