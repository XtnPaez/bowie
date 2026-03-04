# Bowie / SEIR Shiny – Roadmap and Strategic Plan

## Introduction

The SEIR Shiny dashboard has evolved from a modular prototype into a **deployed, interactive epidemiological simulation platform**.  
This document reflects the current development state as of March 2026 and outlines the remaining work ahead.  
The project is part of the **Pandemic Preparedness Toolkit (Argentina Unit)**, funded by Wellcome.

**Live deployment:** <https://cpaez.shinyapps.io/bowie-seir/>  
**Repository:** <https://github.com/XtnPaez/bowie>

---

## Strengths and Achievements

- IECS/Santoro dataset integrated — real COVID-19 Argentina data serving as the interactive case study (ToR Product 1).
- Modular workflow `data → model → viz → ui → server` — fully implemented and stable.
- SEIR ODE model running with `deSolve`, validated against known parameters.
- Open-source codebase — easily modifiable to incorporate SIR, SEIRD, or custom models per ToR specification.
- Data Hub Interface (`data_interface.R`) — loading, validation, schema checks, and caching.
- Entry screen with dataset selection (mock and IECS/Santoro datasets).
- Advanced View with sticky parameter panel, real-time curve updates, and resource pressure plots.
- Top navigation menu with dataset indicator.
- CSV export of simulation results with European locale formatting.
- Public deployment on shinyapps.io.
- Technical documentation draft (`docs/documentacion.Rmd`) — translation in progress.
- Full repository documentation: `CODESTYLE.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`.

---

## Current Limitations

The following ToR requirements are pending implementation:

- **Simplified View** — decision-maker interface with core SEIR plots and KPIs (button visible but disabled).
- **External data connectivity** — API integration with WHO, OWID, and national surveillance repositories.
- **Sociodemographic data layer** — population demographics, mobility patterns, and socioeconomic factors.
- **Interactive presentation with practical exercises** — infographic and guided exercises for educational use.
- **Product 3** — Implementation and User Guides (draft exists in Spanish, translation pending).

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
**Status:** Complete. Functions: `get_data()`, `validate_schema()`, `save_dataset()`, `list_datasets()`, `load_iecs_data()`.  
**Note:** The IECS/Santoro dataset (real COVID-19 Argentina data) is integrated via this interface and serves as the interactive case study for ToR Product 1.

### ✅ Block 4 – User Experience Redesign
**Goal:** Entry screen, navigation menu, and Advanced View layout.  
**Status:** Complete. Includes sticky sidebar, dataset selector, top menu, and view routing.

### 🔹 Block 5 – Simplified Visualisation Mode (ToR Product 2)
**Goal:** A simplified decision-maker interface with core SEIR plots and KPIs only.  
**Status:** 🟡 In progress — UI placeholder in place, implementation pending.  
**Subtasks:**
- Create `mod_viz_simple.R` with SEIR curves, peak infection KPI, and resource summary.
- Hide complex parameter controls.
- Wire Simple View routing in `app.R`.

### 🔹 Block 6 – External Data Connectivity (ToR Product 2)
**Goal:** Connect to real-time epidemiological data sources via API.  
**Status:** 🔴 Pending.  
**Subtasks:**
- Integrate WHO and OWID APIs via `httr` / `jsonlite`.
- Add sociodemographic data layer (population demographics, mobility patterns).
- Extend `data_interface.R` with API source handler.

### 🔹 Block 7 – Interactive Presentation and Practical Exercises (ToR Product 2)
**Goal:** Educational component with real-life dashboard examples and guided exercises.  
**Status:** 🔴 Pending.  
**Subtasks:**
- Design infographic covering visualisation principles (clarity, graph selection, colour, common errors).
- Develop practical exercises anchored to the Santoro case study.
- Integrate or link from the dashboard.

### 🔹 Block 8 – Product 3: Implementation and User Guides
**Goal:** Comprehensive documentation for system administrators, developers, and end users.  
**Status:** 🟡 Draft exists in Spanish (`docs/documentacion.Rmd`) — translation and update pending.  
**Subtasks:**
- Translate and update `documentacion.Rmd` to English.
- Write Implementation Guide (installation, configuration, deployment).
- Write User Guide (features, usage, scenario planning).
- Add Santoro case study narrative: origin, calibration decisions, lessons learned.

---

## Dependencies and Execution

| Block | Depends On | Status |
|-------|------------|--------|
| **1. Core Refactor** | – | ✅ Complete |
| **2. Internationalisation** | 1 | ✅ Complete |
| **3. Data Hub Interface** | 1 | ✅ Complete |
| **4. UX Redesign** | 3 | ✅ Complete |
| **5. Simplified Visualisation** | 3, 4 | 🟡 In progress |
| **6. External Data Connectivity** | 3 | 🔴 Pending |
| **7. Interactive Presentation** | 4, 5 | 🔴 Pending |
| **8. Product 3: Guides** | All | 🔴 Pending |

---

## Summary

The SEIR Shiny project has successfully transitioned from a prototype into a **deployed, functional modelling platform**.  
The technical and UX foundations are stable and fully aligned with the ToR modular architecture requirements.  
Remaining work focuses on three ToR deliverables: the Simplified View, external data connectivity with sociodemographic layer, and the interactive presentation and user guides.

**Maintainer:** Cristian Paez  
**Date:** March 2026  
**Project:** Bowie / proto\_epi — Pandemic Preparedness Toolkit (Argentina Unit)  
**Funded by:** Wellcome
