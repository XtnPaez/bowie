# SEIR Epidemiological Dashboard – Roadmap and Strategic Plan

## Introduction

The SEIR dashboard has evolved from a modular prototype into a **deployed, interactive
epidemiological simulation platform**.  
This document reflects the current development state as of May 2026 and documents the
complete delivery history.  
The project delivers **Product 2** of the Analysis for Action (Argentina Unit).

**Live deployment:** <https://cpaez.shinyapps.io/afa-dashboard-arg/>  
**Repository:** <https://github.com/XtnPaez/afa-dashboard-arg>

---

## Strengths and Achievements

- Modular workflow `data → model → viz → ui → server` — fully implemented and stable.
- SEIR ODE model running with `deSolve`, validated against known parameters.
- Open-source codebase — easily modifiable to incorporate SIR, SEIRD, or custom models per ToR specification.
- Data Hub Interface (`data_interface.R`) — loading, validation, schema checks, caching, and user CSV upload.
- Entry screen with two dataset sources: mock and user-uploaded CSV (see Block 7 — IECS dataset removed from dashboard, retained as methodological reference).
- Simplified View — decision-maker interface with three KPI alarm cards and configurable thresholds.
- Advanced View with sticky parameter panel, real-time curve updates, and resource pressure plots.
- Simulation scope controls (population, start date, end date) exposed in the Advanced View UI.
- Both views initialise from the same loaded dataset snapshot, then evolve independently.
- Top navigation menu with human-readable dataset indicator.
- CSV export of simulation results with European locale formatting.
- Public deployment on shinyapps.io.
- Full repository documentation: `CODESTYLE.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`.
- UI and chart colours fully aligned with AfA brand guidelines.
- Implementation Guide (`docs/implementation_guide.md`) — complete technical documentation.
- Reproducible dataset preparation script (`data-raw/prepare_iecs.R`).
- All five UK three-month review recommendations (Westwood / John, April 2026) implemented.

---

## Current Limitations

The following items are out of scope for the current delivery and documented for future development:

- **External data connectivity** — API integration with WHO, OWID, and national surveillance
  repositories. The module architecture supports this extension; the connection mechanism is
  documented in the Implementation Guide. Implementation deferred pending resource availability.
- **Sociodemographic data layer** — population demographics, mobility patterns, and
  socioeconomic factors. Not part of the dashboard scope; relevant fields should be included
  in user-uploaded datasets as appropriate.

---

## Roadmap

### Block 1 – Core Refactor
**Goal:** Reproducible, modular, and scalable architecture.  
**Status:** ✅ Complete.

### Block 2 – Code Internationalisation
**Goal:** English-only codebase and clean UI.  
**Status:** ✅ Complete.

### Block 3 – Data Hub Interface
**Goal:** Centralised dataset loading, validation, and persistence via `data_interface.R`.  
**Status:** ✅ Complete. Functions: `get_data()`, `validate_schema()`, `save_dataset()`,
`list_datasets()`, `build_dataset()`, `validate_user_csv()`. (`load_iecs_data()` retained as a
console/inspection utility — see Block 7.)

### Block 4 – User Experience Redesign
**Goal:** Entry screen, navigation menu, and Advanced View layout.  
**Status:** ✅ Complete. Includes sticky sidebar, dataset selector, top menu, and view routing.

### Block 4b – UI Polish and Bug Fixes (March 2026)
**Goal:** Production-quality UI ahead of first partial delivery (26 March 2026).  
**Status:** ✅ Complete.  
**Completed items:**
- UI colour system fully migrated to AfA brand palette.
- Entry screen rebuilt: AfA dark green navbar, card-centred layout, footer attribution.
- Advanced View rebuilt: earthy tint sidebar, chart cards, AfA-aligned tabs and table headers.
- All `geom_line(size=)` calls replaced with `linewidth=` (ggplot2 >= 3.4.0 compliance).
- X-axis guide lines added to all three plots via shared `afa_theme()` function in `mod_viz.R`.
- Chart colour palettes updated to AfA categorical and accent colours.
- Namespace collision fixed: `viz_plot_server()` moved to top-level server in `app.R`.
- CSS false positive fixed in `utils_dependencies.R`.
- Selectize dropdown colours overridden to AfA palette.
- Implementation Guide written from scratch in English, aligned with ToR Product 3 requirements.

### Block 5 – Simplified View (March 2026)
**Goal:** A decision-maker interface communicating epidemic status through KPI indicators
and a geometric alarm system, without requiring interpretation of compartmental curves.  
**Status:** ✅ Complete (implemented March 2026).

**Delivered:**
- Three KPI cards: Epidemic Trajectory, ICU Pressure, Cumulative Impact.
- Geometric alarm system using AfA palette colours:

| State | Shape | Colour |
|-------|-------|--------|
| Controlled | Circle | AfA sea green `#3EA27F` |
| Warning | Triangle | AfA orange `#F59342` |
| Critical | Square | AfA dark red `#752111` |

- Two scenario sliders: R₀ and Compliance Level.
- Configurable alarm thresholds via collapsible Settings panel.
- Fully isolated from Advanced View — parameter changes in one view do not affect the other.
- Shared helpers in `mod_helpers_simple.R`: `alarm_shape_svg()`, `state_label_ui()`,
  `metric_value_ui()`, `resolve_alarm_state()`, `coalesce_num()`.

### Block 6 – Final Delivery Sprint (May 2026)
**Goal:** Close all remaining UK review recommendations, implement user CSV upload,
migrate dataset format to `.rds`, and deliver a fully clean, documented codebase for
final submission.  
**Status:** ✅ Complete (implemented May 2026).

**Completed items:**

*UK three-month review recommendations (Westwood / John, April 2026) — all five closed:*
- Rec. 1 — Case study: explicit transferable lessons (Bloque B, documentation).
- Rec. 2 — Case study: model selection rationale clarified (Bloque B, documentation).
- Rec. 3 — Programme name updated: "PPT / Pandemic Preparedness Toolkit" → "Analysis for Action" throughout UI, code, and all documentation.
- Rec. 4 — Epidemic Trajectory subtitle updated: now reads "computed over the most recent 7 simulated days".
- Rec. 5 — Population and simulation dates exposed as UI controls in the Advanced View Simulation Scope panel.

*RDS migration:*
- `iecs_data.RData` migrated to `iecs_data.rds`.
- Reproducible preparation script `data-raw/prepare_iecs.R` added — institutional memory of dataset construction with all parameters cited to primary sources.
- `load_iecs_data()` updated to use `readRDS()` — no environment injection, no name ambiguity.
- `build_dataset()` introduced as single construction point for all SEIR initialisation frames.
- `validate_user_csv()` introduced for user-uploaded CSV validation.
- Self-test block in `data_interface.R` guarded against load-order errors.

*CSV upload:*
- Third dataset source added to entry screen: "Upload your own dataset (CSV)".
- `modalDialog()` with field specification table, default values, and `fileInput()`.
- Validation via `validate_user_csv()` with descriptive error messages.
- Parameters propagate to both views via `dataset_params` reactive.

*Dual-view initialisation:*
- `dataset_params` reactiveVal added to `app.R` shared state.
- Both Advanced View (`mod_server.R`) and Simplified View (`mod_server_simple.R`) initialise
  from the same dataset snapshot on load; views remain independent thereafter.
- Advanced View sliders update via `updateSliderInput()` / `updateNumericInput()` on dataset load.

*Dynamic simulation dates:*
- `START_DATE` and `END_DATE` in `global.R` now initialise to `Sys.Date()` and `Sys.Date() + 365L`.
- Default simulation window is always relative to the current date.

*Codebase cleanup:*
- All internal `Block 4b` / `Block 5` development notes replaced with functional descriptions.
- `.ppt-footer` CSS class renamed to `.afa-footer`.
- `ppt_theme()` renamed to `afa_theme()` in `mod_viz.R`.
- Dataset indicator in `mod_menu.R` replaced `toupper()` with human-readable labels
  ("Simulated (mock)", "IECS – Santoro", "Custom dataset").
- Population race condition fixed in `mod_model.R`: validation now uses actual initial state
  sum rather than `params$population` to avoid reactive timing conflicts.

---

### Block 7 – IECS Dataset Removed from Dashboard (June 2026)
**Goal:** Remove the IECS/Santoro dataset as a selectable, loadable source on the
dashboard, while retaining it as a documented methodological reference for the
model's default parameters.  
**Status:** ✅ Complete.

**Rationale:** the IECS/Santoro dataset (Santoro et al., 2022) informed the design
and default calibration of this SEIR model from the outset, but offering it as a
live, loadable dataset on the entry screen blurred the distinction between "a
worked methodological example" and "a maintained, production-ready data source".
The dashboard now offers only the mock dataset and user-uploaded CSV; IECS/Santoro
remains documented as the inspiration behind the model and its reference defaults.

**Completed items:**
- Entry screen dropdown (`mod_entry.R`): "IECS – Santoro model" option removed.
  Two sources remain: "Simulated (mock)" and "Upload your own dataset (CSV)".
- CSV upload modal (`mod_entry.R`): reference text renamed from "Use the IECS /
  Santoro dataset as a reference template" to "Argentina reference defaults".
  Example value table in the modal is unchanged.
- Dataset indicator (`mod_menu.R`): `"iecs" = "IECS – Santoro"` switch entry removed.
- `mod_server.R`: IECS-loading branch removed from the dataset selection observer.
  `apply_iecs_to_params()` renamed to `apply_calibrated_params()` and
  `normalise_ifr_to_pct()` error messages generalised — both functions are shared
  with the CSV calibration path and were never IECS-exclusive.
- `data_interface.R`: `"iecs"` branch removed from `get_data()`. `load_iecs_data()`
  retained and re-documented as a console/inspection utility — not called from any
  dashboard flow. Comments referring to an "IECS-compatible structure" renamed to
  "canonical calibrated-dataset structure", reflecting that the `$parametros` /
  `$recursos` / `$poblacion` contract is shared with the CSV path.
- `data-raw/prepare_iecs.R` and `data/iecs_data.rds` retained unchanged as
  institutional memory of the model's methodological grounding.
- Documentation (`README.md`, `implementation_guide.md`, `CONTRIBUTING.md`) updated
  to describe two dataset sources; IECS/Santoro re-framed throughout as a
  methodological reference rather than a dashboard input.
- `Product 1` case study (separate deliverable, not part of the dashboard) is
  unaffected by this change.

---

**Maintainer:** Cristian Paez  
**Date:** May 2026  
**Project:** Analysis for Action (Argentina Unit)
