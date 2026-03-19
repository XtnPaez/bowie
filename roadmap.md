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
- Open-source codebase — easily modifiable to incorporate SIR, SEIRD, or custom models per ToR
  specification.
- Data Hub Interface (`data_interface.R`) — loading, validation, schema checks, and caching.
- Entry screen with dataset selection (mock and IECS/Santoro datasets).
- Advanced View with sticky parameter panel, real-time curve updates, and resource pressure plots.
- Top navigation menu with dataset indicator and dynamic active-state highlighting.
- CSV export of simulation results with European locale formatting.
- Public deployment on shinyapps.io.
- Full repository documentation: `CODESTYLE.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`.
- UI and chart colours fully aligned with PPT brand guidelines (Wellcome / CEMIC style template).
- Implementation Guide (`docs/implementation_guide.md`) — complete technical documentation
  covering module architecture, SEIR equations, parameters with bibliographic sources,
  dataset specification, visual design system, and deployment instructions.
- **Simplified View (Block 5)** — KPI card interface with geometric alarm indicators, reactive
  thresholds, isolated SEIR state, and collapsible Settings panel. Completed March 2026.

---

## Current Limitations

The following ToR requirements for Product 2 are pending:

- **User CSV upload** — ability to load a custom dataset from a local `.csv` file
  (design complete — scoped for post-review phase, Block 5b).
- **External data connectivity** — API integration with WHO, OWID, and national surveillance
  repositories (Block 6).
- **Sociodemographic data layer** — population demographics, mobility patterns, and socioeconomic
  factors (Block 6).
- **Interactive presentation with practical exercises** — visualisation principles infographic and
  guided exercises (Block 7).

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
**Status:** Complete. Delivered March 2026.

#### What was delivered

**New files added to `R/`:**

| File | Description |
|---|---|
| `mod_helpers_simple.R` | Shared helper functions: `alarm_shape_svg()`, `state_label_ui()`, `metric_value_ui()`, `resolve_alarm_state()`, `coalesce_num()`. Placed in a dedicated file to guarantee correct load order under `loadSupport()` (alphabetical: `h` < `s` < `u`). |
| `mod_server_simple.R` | Simple View server: isolated `reactiveValues` from `global.R` defaults; calls `mod_data_server("simple_data")` and `model_seir_server("simple_seir")` under distinct namespace ids; KPI computations and alarm state rendering. |
| `mod_ui_simple.R` | Simple View UI: three KPI cards, two parameter sliders, collapsible Settings panel with six threshold inputs. |

**Modified files:**

| File | Change |
|---|---|
| `R/mod_entry.R` | Disabled `<button>` replaced with `actionButton(ns("go_simple"))`; `observeEvent(input$go_simple)` added. |
| `R/mod_menu.R` | Simple button enabled; both Simple and Advanced buttons rendered via `uiOutput` for dynamic active-state border highlighting. |
| `app.R` | Simple View routing wired to `mod_ui_simple("viz_simple")` and `mod_server_simple("viz_simple")`; `viz_plot_server()` not called for Simple View (KPI cards rendered via `renderUI` internally). |

#### Design specification (as implemented)

**Layout:** Single-page view. No tabs, no sidebar, no curves.

**Top section — three independent KPI cards**, each with its own alarm indicator.

| State | Shape | Colour | Meaning |
|---|---|---|---|
| Controlled | Circle | `#3EA27F` PPT sea green | Situation under control |
| Warning | Triangle | `#F59342` PPT orange | Attention required |
| Critical | Square | `#752111` PPT dark red | Situation out of control |

**Card 1 — Epidemic trajectory**  
Metric: weekly growth rate of I (mean of last 7 days vs. preceding 7 days).  
- Circle: growth rate ≤ warning threshold (default 1%)  
- Triangle: growth rate between warning and critical threshold (default 1–20%)  
- Square: growth rate > critical threshold (default > 20%)

**Card 2 — ICU pressure**  
Metric: `ICU_Occupancy_Sim` on the final simulation day as a percentage of ICU capacity.  
Uses the final-day value (not the historical peak) to represent current epidemic status.  
- Circle: < warning threshold (default 70%)  
- Triangle: between warning and critical (default 70–100%)  
- Square: > critical threshold (default > 100%)

**Card 3 — Cumulative impact**  
Metric: `Cumulative_Deaths` on the final simulation day as a percentage of total population.  
- Circle: below warning threshold (default 0.05%)  
- Triangle: between warning and critical (default 0.05–0.20%)  
- Square: above critical threshold (default > 0.20%)

**Parameter sliders (two only):**
- R₀ — range 0.5–6.0, default from `global.R` (`INITIAL_R0`)
- Compliance Level (%) — range 0–100, default 50

State is **fully isolated** from the Advanced View and always initialised from `global.R` defaults.

**Settings panel — threshold configuration (collapsible):**

| Input | Default |
|---|---|
| ICU warning threshold (% of capacity) | 70 |
| ICU critical threshold (% of capacity) | 100 |
| Growth warning threshold (% weekly) | 1 |
| Growth critical threshold (% weekly) | 20 |
| Deaths warning threshold (% of population) | 0.05 |
| Deaths critical threshold (% of population) | 0.20 |

All thresholds are reactive — changing them updates alarm indicators immediately without
re-running the ODE solver.

---

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
|---|---|---|
| `time` | Integer | Day index starting at 0 |
| `S` | Numeric | Susceptible individuals |
| `E` | Numeric | Exposed individuals |
| `I` | Numeric | Infectious individuals |
| `R` | Numeric | Recovered individuals |

Validation is performed server-side by the existing `validate_schema()` function
in `data_interface.R`.

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
|---|---|---|
| Upload screen UI and server | `mod_upload.R` (new) | 4 h |
| Empty CSV template for download | `www/seir_template.csv` (new) | 15 min |
| Wire upload routing in `app.R` | `app.R` | 30 min |
| Add upload link to entry screen | `mod_entry.R` | 30 min |
| Extend dataset combo to reflect session list | `mod_entry.R`, `mod_menu.R` | 1 h |
| Update `implementation_guide.md` | `docs/` | 30 min |
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
- Design infographic covering visualisation principles (clarity, graph selection, colour, common
  errors).
- Develop practical exercises using real-life dashboard examples.
- Integrate or link from the platform.

---

## Dependencies and Execution

| Block | Depends On | Status |
|---|---|---|
| **1. Core Refactor** | – | Complete |
| **2. Internationalisation** | 1 | Complete |
| **3. Data Hub Interface** | 1 | Complete |
| **4. UX Redesign** | 3 | Complete |
| **4b. UI Polish and Bug Fixes** | 4 | Complete |
| **5. Simplified Visualisation** | 3, 4, 4b | Complete — March 2026 |
| **5b. User CSV Upload** | 3, 5 | Scoped — post-review |
| **6. External Data + Sociodemographic** | 3 | Pending |
| **7. Interactive Presentation** | 4, 5 | Pending |

---

## Delivery Timeline

| Milestone | Date | Contents |
|---|---|---|
| First partial delivery | 26 March 2026 | Blocks 1–5 complete |
| Review feedback incorporated | TBD | Corrections from Wellcome / CEMIC review |
| Post-review phase | TBD | Blocks 5b, 6, 7 |

---

## Summary

The SEIR dashboard has successfully transitioned from a prototype into a **deployed, functional
modelling platform** with a UI fully aligned with PPT brand guidelines. Both the Advanced View
(full parameter control, three plot panels, CSV export) and the Simplified View (KPI cards with
geometric alarm indicators, isolated state, configurable thresholds) are operational and deployed.
The first partial delivery to Wellcome / CEMIC is on track for 26 March 2026, covering Blocks 1–5.
Remaining work after delivery focuses on user CSV upload, external data connectivity,
sociodemographic layer, and the interactive presentation with practical exercises.

**Maintainer:** Cristian Paez  
**Date:** March 2026  
**Project:** Pandemic Preparedness Toolkit (Argentina Unit)  
**Funded by:** Wellcome
