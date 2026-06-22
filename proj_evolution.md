# Project Evolution – Status Report (May 2026)

This document summarises the overall progress of the **SEIR Epidemiological Dashboard** against the
Terms of Reference (ToR) for **Product 2** of the Analysis for Action (Argentina Unit).

**Live deployment:** <https://cpaez.shinyapps.io/afa-dashboard-arg/>  
**Repository:** <https://github.com/XtnPaez/afa-dashboard-arg>

---

## 📋 ToR Alignment – Product 2 Delivery Status

| ToR Requirement | Status | Progress |
|-----------------|--------|----------|
| Modular architecture (UI, Model, Data, Viz) | ✅ Complete | **100%** |
| User-driven parameter adjustments | ✅ Complete | **100%** |
| Flexible model integration (open-source, modifiable) | ✅ By design | **95%** |
| Interactive visualisations | ✅ Three panels functional | **95%** |
| Web deployment | ✅ Live on shinyapps.io | **100%** |
| Simplified View — decision-maker interface | ✅ Complete | **100%** |
| User dataset upload (CSV) | ✅ Complete | **100%** |
| Simulation scope controls (population, dates) | ✅ Complete | **100%** |
| External data connectivity (WHO, OWID) | 📋 Documented, deferred | **15%** |
| Sociodemographic data layer | 📋 Out of scope — documented | **0%** |
| Interactive presentation with practical exercises | 🟡 In progress | **30%** |
| **Product 2 Overall** | | **≈ 90%** |

---

## 🧠 1. Technical Evaluation

| Component | Status | Progress |
|-----------|--------|----------|
| Modular structure `/R/mod_*` | ✅ Complete and stable | **100%** |
| Logging and validation system (`utils_*`) | ✅ Consolidated | **100%** |
| SEIR model core (equations and reactivity) | ✅ Stable and deployed | **100%** |
| Open-source design for model extensibility | ✅ By architecture | **100%** |
| Data Hub Interface (`data_interface.R`) | ✅ Complete with CSV support | **100%** |
| Advanced visualisation module (`mod_viz`) | ✅ All plots rendering | **100%** |
| CSV export of simulation results | ✅ Implemented | **100%** |
| IECS / Santoro reference dataset | ✅ Retained as methodological reference (.rds); removed as dashboard source | **100%** |
| Reproducible dataset preparation (`data-raw/`) | ✅ Implemented | **100%** |
| Simplified View module (`mod_*_simple`) | ✅ Complete and deployed | **100%** |
| User CSV upload with validation | ✅ Implemented | **100%** |
| Dual-view initialisation from dataset | ✅ Implemented | **100%** |
| Simulation scope UI (population, dates) | ✅ Implemented | **100%** |
| Dynamic default dates (`Sys.Date()`) | ✅ Implemented | **100%** |
| Internationalisation and code cleanup | ✅ Completed | **100%** |
| AfA brand palette — UI and charts | ✅ Implemented | **100%** |
| Stale reference cleanup (PPT, Block 5, hardcoded dates) | ✅ Complete | **100%** |
| **Subtotal Technical** | | **≈ 100%** |

> **Summary:** The technical core is complete, fully modular, and deployed. The May 2026
> delivery sprint closed all five UK review recommendations, completed the RDS migration,
> implemented user CSV upload, and delivered dual-view parameter initialisation.

---

## 🧩 2. Functional Evaluation (mapped to ToR Product 2)

| ToR Requirement | Status | Progress |
|-----------------|--------|----------|
| Modular architecture (UI, Model, Data, Viz modules) | ✅ Implemented | **100%** |
| User-driven parameter adjustments | ✅ Operational | **100%** |
| Flexible model integration (open-source, modifiable) | ✅ By design | **95%** |
| Interactive visualisations | ✅ Three plot panels functional | **100%** |
| Web deployment | ✅ Live on shinyapps.io | **100%** |
| Simplified View — decision-maker interface | ✅ Implemented | **100%** |
| User dataset upload (CSV with guided modal) | ✅ Implemented | **100%** |
| External data connectivity (WHO, OWID APIs) | 📋 Architecture documented | **15%** |
| Sociodemographic data layer | 📋 Documented as out of scope | **0%** |
| Interactive presentation with practical exercises | 🟡 User Guide in progress | **30%** |
| **Subtotal Functional** | | **≈ 86%** |

> **Summary:** Core dashboard functionality is complete and deployed. External API connectivity
> is documented in the Implementation Guide as a future extension. The sociodemographic data
> layer is defined as a dataset responsibility (fields specified in the user CSV format).
> The interactive presentation is in progress (User Guide enrichment with Melina).

---

## 🧬 3. Strategic Evaluation

| Strategic Pillar | Status | Progress |
|------------------|--------|----------|
| Development plan and milestones | ✅ Defined and up to date | **100%** |
| Repository documentation | ✅ Updated (May 2026) | **100%** |
| Public deployment with live URL | ✅ Achieved | **100%** |
| Access model aligned with open-source ToR | ✅ Resolved by design | **100%** |
| UI aligned with AfA brand guidelines | ✅ Implemented | **100%** |
| UK three-month review recommendations | ✅ All five closed | **100%** |
| **Subtotal Strategic** | | **≈ 100%** |

---

## 🧮 Global Weighted Estimate

| Dimension | Weight | Progress |
|-----------|--------|----------|
| Technical | 40% | 100% |
| Functional | 40% | 84% |
| Strategic | 20% | 100% |
| **Total Weighted Progress** | | **≈ 94%** ✅ |

> The project covers approximately **94% of ToR Product 2 deliverables** as of May 2026.  
> The technical backbone is complete, the strategic layer is solid, and the UI is fully aligned
> with AfA brand guidelines. Remaining work is concentrated in the interactive presentation
> (User Guide with pedagogical enrichment).

---

## 📈 May 2026 Sprint Summary

The May 2026 delivery sprint completed the following:

**UK review recommendations (all five):** Programme name updated throughout, Epidemic Trajectory
subtitle clarified, simulation scope controls added to UI, case study documentation updated.

**RDS migration:** `iecs_data.RData` replaced by `iecs_data.rds` with a fully reproducible
preparation script (`data-raw/prepare_iecs.R`) that cites all parameter sources.

**User CSV upload:** Third dataset source implemented with modal dialog, field specification
table, and validation. Users can upload their own regional parameter snapshot and the platform
uses it as the simulation starting point.

**Dual-view initialisation:** Both Advanced View and Simplified View now initialise from the
same loaded dataset snapshot. Views remain fully independent after initialisation.

**Dynamic simulation dates:** Default simulation window now relative to the current date
(`Sys.Date()` to `Sys.Date() + 365`).

---

## 📈 June 2026 Sprint Summary

**IECS dataset removed from dashboard:** the IECS/Santoro dataset is no longer offered as a
selectable, loadable source on the entry screen. The dashboard now exposes two sources —
simulated (mock) and user-uploaded CSV. IECS/Santoro (Santoro et al., 2022) remains documented
as the methodological reference behind the model's default parameters; `data-raw/prepare_iecs.R`
and `data/iecs_data.rds` are retained unchanged for traceability and console-based inspection.
See `roadmap.md`, Block 7, for the full list of affected files and rationale.

**Codebase cleanup:** All stale internal references removed — no PPT, Block 4b/5 notes,
hardcoded 2020 dates, or `.RData` references remain in the codebase.

---

## 🧭 Remaining Work (June 2026)

Ordered by priority:

1. **Interactive presentation** — User Guide enrichment with pedagogical exercises (working with Melina).
2. **Case study** — final narrative edits (UK recommendations 1 and 2).
3. **Repository final branch** — `review/final-2026-06` with complete state.
4. **Deploy to shinyapps.io** — final production deployment.

---

**Maintainer:** Cristian Paez  
**Date:** May 2026  
**Project:** Analysis for Action (Argentina Unit)
