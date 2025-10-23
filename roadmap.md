# SEIR Shiny – Roadmap and Strategic Plan

## Introduction
The SEIR Shiny dashboard has evolved into a modular and reproducible framework.  
The next development phase focuses on creating a **Data Hub** to manage datasets and a **dual visualisation experience** (simple / advanced).  
This plan integrates the original modular roadmap with the new functional vision.

---

## Strengths and Achievements
- Modular workflow `data → model → viz → ui → server`.
- Stable codebase with logging, validation, and reproducibility.  
- English-only code and documentation for international consistency.  
- Completed Issues 1–4: refactor, utils, validation, logging, and UI standardisation.

---

## Current Weaknesses
- No centralised data interface (Data Hub missing).  
- Limited user navigation between visualisation modes.  
- Lack of persistent dataset storage and schema validation.  
- Overloaded `mod_server` responsibilities.  
- No integrated test suite yet.

---

## Updated Roadmap

### 🔹 Block 1 – Core Refactor (completed)
**Goal:** Ensure reproducible, modular, and scalable architecture.  
**Status:** ✅ Completed.

### 🔹 Block 2 – Code Internationalisation (completed)
**Goal:** Migrate to English-only codebase and clean UI.  
**Status:** ✅ Completed.

### 🔹 Block 3 – Data Hub Interface (current focus)
**Goal:** Implement `/R/data_interface.R` to manage dataset loading, validation, and persistence.  
**Subtasks:**
- Create `get_data(source, params)` for CSV / API / local access.  
- Add `validate_schema(data)` for structure checks.  
- Implement dataset saving and retrieval functions.  
- Add metadata management and source registration.  
- Provide basic test coverage for validation functions.

### 🔹 Block 4 – User Experience Redesign
**Goal:** Rebuild the entry screen and navigation system.  
**Subtasks:**
- Redesign `mod_index.R` → `mod_entry.R` (data source selection).  
- Implement navigation between **Simple** and **Advanced** visualisation views.  
- Persist selected dataset between sessions.  
- Introduce a unified top menu for switching views.

### 🔹 Block 5 – Simplified Visualisation Mode
**Goal:** Offer a simplified “decision-maker” interface.  
**Subtasks:**
- Create `mod_viz_simple.R` with core SEIR plots only.  
- Hide complex parameter controls.  
- Provide clear KPIs and resource summaries.  

### 🔹 Block 6 – Model Hub Expansion
**Goal:** Extend framework to support additional infection models.  
**Subtasks:**
- Create `/models/` folder and registry (`model_registry.R`).  
- Define model API (`init`, `run`, `describe`, `schema_in/out`).  
- Integrate model-specific UI controls.  
- Include metadata in YAML format.

### 🔹 Block 7 – Testing and Deployment
**Goal:** Ensure robustness and reproducibility.  
**Subtasks:**
- Implement unit tests (`testthat`) and UI tests (`shinytest2`).  
- CI/CD with GitHub Actions.  
- Reproducibility snapshot with `renv::snapshot()`.  
- Continuous performance logging.

---

## Dependencies and Execution

| Block | Depends On | Parallel Execution | Notes |
|-------|-------------|--------------------|-------|
| **1. Core Refactor** | – | 🔴 No | Foundation for all other blocks. |
| **2. Internationalisation** | 1 | 🟢 Done | Stable and standardised. |
| **3. Data Hub Interface** | 1 | 🟡 Partial | Base for UX redesign. |
| **4. User Experience Redesign** | 3 | 🟡 Partial | UI work depends on Data Hub. |
| **5. Simplified Visualisation Mode** | 3 | 🟢 Yes | Can be developed in parallel. |
| **6. Model Hub Expansion** | 3, 4 | 🟡 Partial | Relies on Data Hub architecture. |
| **7. Testing and Deployment** | All | 🟢 Continuous | Runs across all stages. |

---

## Summary
The SEIR Shiny project is transitioning from a prototype into a **flexible, data-centric modelling platform**.  
This roadmap emphasises user experience, dynamic data integration, and model extensibility while maintaining scientific integrity and modular reproducibility.  

**Next target:** Implement Block 3 – Data Hub Interface.  

**Maintainer:** Cristian Paez  
**Date:** October 2025
