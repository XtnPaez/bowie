# Project Evolution – Status Report (March 2026)

This document summarises the overall progress of the **SEIR Epidemiological Dashboard** against the
Terms of Reference (ToR) for **Product 2** of the Pandemic Preparedness Toolkit (Argentina Unit),
Work Package 5.

**Live deployment:** <https://cpaez.shinyapps.io/bowie-seir/>  
**Repository:** <https://github.com/XtnPaez/bowie>

---

## ToR Alignment – Product 2 Delivery Status

| ToR Requirement | Status | Progress |
|---|---|---|
| Modular architecture (UI, Model, Data, Viz) | ✅ Complete | **100%** |
| User-driven parameter adjustments | ✅ Complete | **100%** |
| Flexible model integration (open-source, modifiable) | ✅ By design | **90%** |
| Interactive visualisations | ✅ Three panels functional | **95%** |
| Web deployment | ✅ Live on shinyapps.io | **100%** |
| Simplified View — decision-maker interface | ✅ Complete (Block 5) | **100%** |
| External data connectivity (WHO, OWID) | 🔴 Not implemented | **0%** |
| Sociodemographic data layer | 🔴 Not implemented | **0%** |
| Interactive presentation with practical exercises | 🔴 Not implemented | **0%** |
| **Product 2 Overall** | | **≈ 76%** |

---

## 1. Technical Evaluation

| Component | Status | Progress |
|---|---|---|
| Modular structure `R/mod_*` | ✅ Complete and stable | **100%** |
| Logging and validation system (`utils_*`) | ✅ Consolidated | **100%** |
| SEIR model core (equations and reactivity) | ✅ Stable and deployed | **95%** |
| Open-source design for model extensibility | ✅ By architecture | **100%** |
| Data Hub Interface (`data_interface.R`) | ✅ Implemented | **90%** |
| Advanced visualisation module (`mod_viz`) | ✅ All plots rendering | **95%** |
| CSV export of simulation results | ✅ Implemented | **100%** |
| IECS / Santoro dataset integration | ✅ Loadable and functional | **90%** |
| Internationalisation and code cleanup | ✅ Completed | **100%** |
| Namespace collision fix (`viz_plot_server`) | ✅ Resolved | **100%** |
| ggplot2 deprecation fix (`linewidth`) | ✅ Resolved | **100%** |
| CSS false positive fix (`utils_dependencies`) | ✅ Resolved | **100%** |
| PPT brand palette — UI and charts | ✅ Implemented | **100%** |
| Simplified View — KPI cards and alarm system | ✅ Implemented (Block 5) | **100%** |
| **Subtotal Technical** | | **≈ 98%** |

> **Summary:** The technical core is robust, fully modular, and deployed. Block 5 delivered three
> KPI cards with SVG geometric alarm indicators, isolated SEIR state, reactive thresholds, and a
> collapsible Settings panel — all fully aligned with the PPT brand palette.

---

## 2. Functional Evaluation (mapped to ToR Product 2)

| ToR Requirement | Status | Progress |
|---|---|---|
| Modular architecture (UI, Model, Data, Viz modules) | ✅ Implemented | **100%** |
| User-driven parameter adjustments | ✅ Operational | **100%** |
| Flexible model integration (open-source, modifiable) | ✅ By design | **90%** |
| Interactive visualisations | ✅ Three plot panels functional | **95%** |
| Web deployment | ✅ Live on shinyapps.io | **100%** |
| Simplified View — decision-maker interface | ✅ Complete (Block 5) | **100%** |
| External data connectivity (WHO, OWID APIs) | 🔴 Not implemented | **0%** |
| Sociodemographic data layer | 🔴 Not implemented | **0%** |
| Interactive presentation with practical exercises | 🔴 Not implemented | **0%** |
| **Subtotal Functional** | | **≈ 76%** |

> **Summary:** Core dashboard functionality is operational, deployed, and now includes the
> Simplified View (Block 5). Three ToR requirements remain pending: external API connectivity,
> sociodemographic data layer, and the interactive presentation with practical exercises.

---

## 3. Strategic Evaluation

| Strategic Pillar | Status | Progress |
|---|---|---|
| Development plan and milestones | ✅ Defined and up to date | **100%** |
| Repository documentation | ✅ Updated (March 2026) | **100%** |
| Public deployment with live URL | ✅ Achieved | **100%** |
| Access model aligned with open-source ToR | ✅ Resolved by design | **100%** |
| UI aligned with PPT brand guidelines | ✅ Implemented (March 2026) | **100%** |
| First partial delivery to Wellcome / CEMIC | ✅ On track — 26 March 2026 | **100%** |
| **Subtotal Strategic** | | **≈ 100%** |

> **Summary:** Strategic foundations are solid. Block 5 was completed ahead of the first partial
> delivery deadline (26 March 2026). Documentation, deployment, and brand alignment are all current.

---

## Global Weighted Estimate

| Dimension | Weight | Progress |
|---|---|---|
| Technical | 40% | 98% |
| Functional | 40% | 76% |
| Strategic | 20% | 100% |
| **Total Weighted Progress** | | **≈ 89%** ✅ |

> The project covers approximately **89% of ToR Product 2 deliverables** as of March 2026.  
> Block 5 (Simplified View) is complete, raising functional coverage from 66% to 76%.
> Remaining work is concentrated in three functional ToR requirements (Blocks 6 and 7).

---

## Interpretation

- The project has successfully transitioned from a prototype to a **deployed simulation platform**
  with both an Advanced View (full parameter control) and a Simplified View (decision-maker KPI
  interface).
- The Simplified View (Block 5) delivers three independent KPI cards — Epidemic Trajectory, ICU
  Pressure, and Cumulative Impact — each with a geometric alarm indicator (circle / triangle /
  square) in the PPT palette. Alarm thresholds are configurable via a collapsible Settings panel
  and react without re-running the ODE solver.
- The Simple View state is fully isolated from the Advanced View: sliders always initialise from
  `global.R` defaults regardless of any prior Advanced View interaction.
- Three ToR requirements for Product 2 remain pending: external data connectivity, sociodemographic
  layer, and interactive presentation with practical exercises.
- All pending items have clear implementation paths and are scoped for the post-review phase.

---

## Next Phase

Ordered by ToR priority:

1. **Block 5b — User CSV Upload** — scoped and designed; target post-review phase.
2. **Block 6 — External data connectivity** — API integration with WHO and OWID.
3. **Block 6 — Sociodemographic data layer** — demographics and mobility data integration.
4. **Block 7 — Interactive presentation** — infographic and practical exercises on visualisation
   principles.

---

**Maintainer:** Cristian Paez  
**Date:** March 2026  
**Project:** Pandemic Preparedness Toolkit (Argentina Unit)  
**Funded by:** Wellcome
