# Project Evolution – Status Report (March 2026)

This document summarises the overall progress of the **Bowie / SEIR Shiny** project against the
Terms of Reference (ToR) for **Product 2** of the Pandemic Preparedness Toolkit (Argentina Unit),
Work Package 5.

**Live deployment:** <https://cpaez.shinyapps.io/bowie-seir/>  
**Repository:** <https://github.com/XtnPaez/bowie>

---

## 📋 ToR Alignment – Product 2 Delivery Status

| ToR Requirement | Status | Progress |
|-----------------|--------|----------|
| Modular architecture (UI, Model, Data, Viz) | ✅ Complete | **100%** |
| User-driven parameter adjustments | ✅ Complete | **100%** |
| Flexible model integration (open-source, modifiable) | ✅ By design | **90%** |
| Interactive visualisations | ✅ Three panels functional | **90%** |
| Web deployment | ✅ Live on shinyapps.io | **100%** |
| Simplified View — decision-maker interface | 🟡 Placeholder only | **10%** |
| External data connectivity (WHO, OWID) | 🔴 Not implemented | **0%** |
| Sociodemographic data layer | 🔴 Not implemented | **0%** |
| Interactive presentation with practical exercises | 🔴 Not implemented | **0%** |
| **Product 2 Overall** | | **≈ 66%** |

---

## 🧠 1. Technical Evaluation

| Component | Status | Progress |
|-----------|--------|----------|
| Modular structure `/R/mod_*` | ✅ Complete and stable | **100%** |
| Logging and validation system (`utils_*`) | ✅ Consolidated | **100%** |
| SEIR model core (equations and reactivity) | ✅ Stable and deployed | **95%** |
| Open-source design for model extensibility | ✅ By architecture | **100%** |
| Data Hub Interface (`data_interface.R`) | ✅ Implemented | **90%** |
| Advanced visualisation module (`mod_viz`) | ✅ All plots rendering | **90%** |
| CSV export of simulation results | ✅ Implemented | **100%** |
| IECS / Santoro dataset integration | ✅ Loadable and functional | **90%** |
| Internationalisation and code cleanup | ✅ Completed | **100%** |
| **Subtotal Technical** | | **≈ 96%** |

> **Summary:** The technical core is robust, fully modular, and deployed. Model extensibility
> is achieved by open-source design as specified in the ToR — no separate plug-in system required.

---

## 🧩 2. Functional Evaluation (mapped to ToR Product 2)

| ToR Requirement | Status | Progress |
|-----------------|--------|----------|
| Modular architecture (UI, Model, Data, Viz modules) | ✅ Implemented | **100%** |
| User-driven parameter adjustments | ✅ Operational | **100%** |
| Flexible model integration (open-source, modifiable) | ✅ By design | **90%** |
| Interactive visualisations | ✅ Three plot panels functional | **90%** |
| Web deployment | ✅ Live on shinyapps.io | **100%** |
| Simplified View — decision-maker interface | 🟡 Placeholder only | **10%** |
| External data connectivity (WHO, OWID APIs) | 🔴 Not implemented | **0%** |
| Sociodemographic data layer | 🔴 Not implemented | **0%** |
| Interactive presentation with practical exercises | 🔴 Not implemented | **0%** |
| **Subtotal Functional** | | **≈ 66%** |

> **Summary:** Core dashboard functionality is operational and deployed. Four ToR requirements
> remain pending: Simplified View, external API connectivity, sociodemographic data layer, and
> the interactive presentation with practical exercises.

---

## 🧬 3. Strategic Evaluation

| Strategic Pillar | Status | Progress |
|------------------|--------|----------|
| Development plan and milestones | ✅ Defined and up to date | **100%** |
| Repository documentation | ✅ Updated (March 2026) | **95%** |
| Public deployment with live URL | ✅ Achieved | **100%** |
| Access model aligned with open-source ToR | ✅ Resolved by design | **100%** |
| **Subtotal Strategic** | | **≈ 99%** |

> **Summary:** Strategic foundations are solid. Deployment is live, documentation is current,
> and the open-source access model is fully coherent with the ToR mandate.

---

## 🧮 Global Weighted Estimate

| Dimension | Weight | Progress |
|-----------|--------|----------|
| Technical | 40% | 96% |
| Functional | 40% | 66% |
| Strategic | 20% | 99% |
| **Total Weighted Progress** | | **≈ 84%** ✅ |

> The project covers approximately **84% of ToR Product 2 deliverables** as of March 2026.  
> The technical backbone is mature and the strategic layer is solid. Remaining work is
> concentrated in four functional ToR requirements.

---

## 📈 Interpretation

- The project has successfully transitioned from a prototype to a **deployed simulation platform**.
- The core SEIR pipeline — data ingestion, ODE solving, visualisation, and export — is fully operational.
- Four ToR requirements for Product 2 remain pending: Simplified View, external data connectivity,
  sociodemographic layer, and interactive presentation with practical exercises.
- All pending items have clear implementation paths and represent lower-risk development tasks.

---

## 🧭 Next Phase (Q2 2026)

Ordered by ToR priority:

1. **Simplified View** — implement `mod_viz_simple.R` with core curves and KPIs for decision-makers.
2. **External data connectivity** — API integration with WHO and OWID.
3. **Sociodemographic data layer** — demographics and mobility data integration.
4. **Interactive presentation** — infographic and practical exercises on visualisation principles.

---

**Maintainer:** Cristian Paez  
**Date:** March 2026  
**Project:** Pandemic Preparedness Toolkit (Argentina Unit)  
**Funded by:** Wellcome
