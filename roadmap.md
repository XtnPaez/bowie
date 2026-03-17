# SEIR Epidemiological Dashboard – Roadmap and Strategic Plan

## Introduction

The SEIR dashboard has evolved from a modular prototype into a **deployed, interactive
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
- UI and chart colours fully aligned with PPT brand guidelines (Wellcome / CEMIC).
- Implementation Guide (`docs/implementation_guide.md`) — complete technical documentation
  covering module architecture, SEIR equations, parameters with bibliographic sources,
  dataset specification, visual design system, and deployment instructions.

---

## Current Limitations

The following ToR requirements for Product 2 are pending:

- **Simplified View** — decision-maker interface with KPI indicators and alarm system
  (button visible but disabled; design fully specified — ready to implement).
- **User CSV upload** — ability to load a custom dataset from a local `.csv` file
  (design session pending; scoped for post-review phase).
- **External data connectivity** — API integration with WHO, OWID, and national surveillance repositories.
- **Sociodemographic data layer** — population demographics, mobility patterns, and socioeconomic factors.
- **Interactive presentation with practical exercises** — visualisation principles infographic and guided exercises.

---

## Roadmap

### Block 1 – Core Refactor
**Goal:** Reproducible, modular, and scalable architecture.  
**Status:** Complete.

### Block 2 – Code Internationalisation
**Goal:** English-only codebase and clean UI.  
**Status:** Complete.

### Block 3 – Data Hub Interface
**Goal:** Centralised dataset loading, validation, and persistence via `data_interface.R`.  
**Status:** Complete. Functions: `get_data()`, `validate_schema()`, `save_dataset()`,
`list_datasets()`, `load_iecs_data()`.

### Block 4 – User Experience Redesign
**Goal:** Entry screen, navigation menu, and Advanced View layout.  
**Status:** Complete. Includes sticky sidebar, dataset selector, top menu, and view routing.

### Block 4b – UI Polish and Bug Fixes (March 2026)
**Goal:** Production-quality UI ahead of first partial delivery (26 March 2026).  
**Status:** Complete.  
**Completed items:**
- UI colour system fully migrated to PPT brand palette (Wellcome / CEMIC style template).
- Entry screen rebuilt: PPT dark green navbar, card-centred layout, footer attribution.
- Advanced View rebuilt: earthy tint sidebar, chart cards, PPT-aligned tabs and table headers.
- All `geom_line(size=)` calls replaced with `linewidth=` (ggplot2 >= 3.4.0 compliance).
- X-axis guide lines added to all three plots via shared `ppt_theme()` function in `mod_viz.R`.
- Chart colour palettes updated to PPT categorical and accent colours.
- Namespace collision fixed: `viz_plot_server()` moved to top-level server in `app.R` to
  prevent double-prefixed output ids (`viz_advanced-viz_advanced-seir_plot`).
- CSS false positive fixed in `utils_dependencies.R`: CSS pseudo-selector `col::` was
  parsed as an R package name; resolved with format-based filter.
- Selectize dropdown colours overridden to PPT palette.
- Bootstrap `text-info` class replaced with PPT earthy green in policy description.
- Fantasy project name removed from all UI-visible strings.
- Implementation Guide written from scratch in English, aligned with ToR Product 3
  requirements (`docs/implementation_guide.md`).

### Block 5 – Simplified Visualisation Mode (ToR)
**Goal:** A decision-maker interface that communicates epidemic status through KPI indicators
and a geometric alarm system, without requiring interpretation of compartmental curves.  
**Status:** In progress — UI placeholder in place. Design fully specified (March 2026).
Target completion: 23 March 2026 (ahead of first partial delivery).

#### Design specification

**Layout:** Single-page view. No tabs, no sidebar, no curves.

**Top section — three independent KPI cards**, each with its own alarm indicator.
Each alarm indicator uses a geometric shape and PPT palette colour:

| State | Shape | Colour | Meaning |
|-------|-------|--------|---------|
| Controlled | Circle | PPT sea green `#3EA27F` | Situation under control |
| Warning | Triangle | PPT orange `#F59342` | Attention required |
| Critical | Square | PPT dark red `#752111` | Situation out of control |

**Card 1 — Epidemic trajectory**
Metric: weekly growth rate of the infectious compartment (I).  
Logic:
- Circle: I is decreasing or stable (growth rate <= 0%)
- Triangle: I is growing moderately (growth rate 1–20% weekly)
- Square: I is growing rapidly (growth rate > 20% weekly)

**Card 2 — ICU pressure**
Metric: `ICU_Occupancy_Sim` as a percentage of ICU capacity.  
Logic:
- Circle: occupancy < 70% of capacity
- Triangle: occupancy 70–100% of capacity
- Square: occupancy > 100% of capacity (capacity exceeded)

**Card 3 — Cumulative impact**
Metric: `Cumulative_Deaths` as a percentage of total population.  
Logic:
- Circle: below low threshold (default: 0.05% of population)
- Triangle: between low and high threshold (default: 0.05–0.20%)
- Square: above high threshold (default: > 0.20%)

**Bottom section — two parameter sliders only:**
- R₀ (Basic Reproduction Number) — range and default from `global.R`
- Compliance Level (%) — range 0–100, default 50

Sliders are **fully isolated from the Advanced View state** and always initialise
from `global.R` defaults. This ensures the Simple View works correctly whether the
user enters directly from the entry screen or navigates from the Advanced View.

**Settings panel — threshold configuration:**
A collapsible "Settings" panel (not a separate route) exposes six numeric inputs
for overriding the default alarm thresholds:

| Input | Default | Description |
|-------|---------|-------------|
| ICU warning threshold (%) | 70 | % of capacity triggering triangle |
| ICU critical threshold (%) | 100 | % of capacity triggering square |
| Growth warning threshold (%) | 1 | Weekly I growth rate triggering triangle |
| Growth critical threshold (%) | 20 | Weekly I growth rate triggering square |
| Deaths warning threshold (%) | 0.05 | % of population triggering triangle |
| Deaths critical threshold (%) | 0.20 | % of population triggering square |

All thresholds are reactive — changing them updates the alarm indicators immediately
without re-running the ODE solver.

#### Implementation plan

| Task | File(s) | Estimated effort |
|------|---------|-----------------|
| Create Simple View UI with KPI cards and alarm shapes | `mod_ui_simple.R` (new) | 2 h |
| Create Simple View server with isolated state and alarm logic | `mod_server_simple.R` (new) | 2 h |
| Enable Simple button in entry and menu | `mod_entry.R`, `mod_menu.R` | 30 min |
| Wire Simple View routing in `app.R` | `app.R` | 30 min |
| Update `implementation_guide.md` and `proj_evolution.md` | docs | 1 h |
| Testing and deploy | — | 1 h |
| **Total** | | **~7 h** |

### Block 5b – User CSV Upload
**Goal:** Allow users to load one or more custom `.csv` datasets from their local machine
as additional sources alongside mock and IECS/Santoro.  
**Status:** Fully designed. Implementation target: post-review phase (after 26 March 2026).

#### Design specification

**Entry point:** a medium-weight link below the entry screen card —
"Upload your own dataset →" — navigates to `screen("upload")`. Not a modal.

**Upload screen layout:**
- PPT-branded navbar with Home button (same style as all other views).
- Disclaimer section — always visible, never collapsible — containing:
  - A prose description of requirements.
  - An example table showing the expected CSV format with realistic dummy data.
  - A download button for an empty CSV template (headers only, no data rows).
- File input control and Upload button.
- Accumulated dataset list panel (see below).

**File name validation:**
- Allowed characters: letters (`A–Z`, `a–z`), digits (`0–9`), and underscores (`_`).
- Maximum length: 30 characters, excluding the `.csv` extension.
- Regex applied server-side: `^[A-Za-z0-9_]{1,30}$` on the bare filename.

**Schema validation — minimum required columns:**

| Column | Type | Description |
|--------|------|-------------|
| `time` | Integer | Day index starting at 0 |
| `S` | Numeric | Susceptible individuals |
| `E` | Numeric | Exposed individuals |
| `I` | Numeric | Infectious individuals |
| `R` | Numeric | Recovered individuals |

Validation is performed server-side by the existing `validate_schema()` function
in `data_interface.R`. No column-level error detail is shown to the user.

**Upload outcome:**
- Valid file → added to the accumulated list, form refreshes ready for another upload.
- Invalid file → generic alert message, form refreshes, no error detail provided.

**Accumulated dataset list:**
- Always shows mock and IECS/Santoro as fixed entries at the top.
- Validated uploads append below during the session.
- No delete option — list resets on session reload.
- List is shared with the entry screen combo: all validated datasets appear as
  selectable options in the dataset selector on the entry screen.

**Session persistence:** list lives in the current session only. No disk writes beyond
the existing `data/cache/` mechanism.

#### Files affected

| Task | File(s) | Estimated effort |
|------|---------|-----------------|
| Upload screen UI | `mod_upload.R` (new) | 2 h |
| Upload screen server: validation, list management | `mod_upload.R` (new) | 2 h |
| Empty CSV template for download | `www/seir_template.csv` (new) | 15 min |
| Wire upload routing in `app.R` | `app.R` | 30 min |
| Add upload link to entry screen | `mod_entry.R` | 30 min |
| Extend dataset combo to reflect session list | `mod_entry.R`, `mod_menu.R` | 1 h |
| Update `implementation_guide.md` | docs | 30 min |
| Testing | — | 1 h |
| **Total** | | **~8 h** |

### Block 6 – External Data Connectivity (ToR)
**Goal:** Connect to real-time epidemiological and sociodemographic data sources via API.  
**Status:** Pending.  
**Subtasks:**
- Integrate WHO and OWID APIs via `httr` / `jsonlite`.
- Add sociodemographic data layer (population demographics, mobility patterns).
- Extend `data_interface.R` with API source handler.

### Block 7 – Interactive Presentation and Practical Exercises (ToR)
**Goal:** Educational component illustrating effective dashboard use and visualisation principles.  
**Status:** Pending.  
**Subtasks:**
- Design infographic covering visualisation principles (clarity, graph selection, colour, common errors).
- Develop practical exercises using real-life dashboard examples.
- Integrate or link from the platform.

---

## Dependencies and Execution

| Block | Depends On | Status |
|-------|------------|--------|
| **1. Core Refactor** | – | Complete |
| **2. Internationalisation** | 1 | Complete |
| **3. Data Hub Interface** | 1 | Complete |
| **4. UX Redesign** | 3 | Complete |
| **4b. UI Polish and Bug Fixes** | 4 | Complete |
| **5. Simplified Visualisation** | 3, 4, 4b | In progress — target 23 Mar 2026 |
| **5b. User CSV Upload** | 3, 5 | Scoped — post-review |
| **6. External Data + Sociodemographic** | 3 | Pending |
| **7. Interactive Presentation** | 4, 5 | Pending |

---

## Delivery Timeline

| Milestone | Date | Contents |
|-----------|------|----------|
| First partial delivery | 26 March 2026 | Blocks 1–4b complete + Block 5 complete |
| Review feedback incorporated | TBD | Corrections from Wellcome / CEMIC review |
| Post-review phase | TBD | Blocks 5b, 6, 7 |

---

## Summary

The SEIR dashboard has successfully transitioned from a prototype into a **deployed, functional
modelling platform** with a UI fully aligned with PPT brand guidelines. The technical and UX
foundations are stable. The Simplified View (Block 5) is fully designed and ready to implement,
with a target completion of 23 March 2026 ahead of the first partial delivery. Remaining work
after delivery focuses on user CSV upload, external data connectivity, sociodemographic layer,
and the interactive presentation with practical exercises.

**Maintainer:** Cristian Paez  
**Date:** March 2026  
**Project:** Pandemic Preparedness Toolkit (Argentina Unit)  
**Funded by:** Wellcome
