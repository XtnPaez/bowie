# Project Evolution – Status Report (March 2026)

This document summarises the overall progress of the **Bowie / SEIR Shiny** project.  
It reflects the current maturity level based on technical, functional, and strategic dimensions,
and maps deliverables strictly against the Terms of Reference (ToR) for the Pandemic Preparedness
Toolkit (Argentina Unit), Work Package 5.

**Live deployment:** <https://cpaez.shinyapps.io/bowie-seir/>  
**Repository:** <https://github.com/XtnPaez/bowie>

---

## 📋 ToR Alignment – Product Delivery Status

The ToR defines three products for this Unit:

| Product | Description | Status | Progress |
|---------|-------------|--------|----------|
| **Product 1** | Case Study: COVID-19 modelling in Argentina | 🟡 Embedded in dashboard | **60%** |
| **Product 2** | Modular Shiny Dashboard prototype | 🟡 Deployed, partial ToR coverage | **65%** |
| **Product 3** | Implementation and User Guides | 🟡 Draft in progress | **20%** |

### Product 1 — Case Study
The case study is implemented as an **interactive demonstration** embedded in the dashboard.  
The IECS/Santoro dataset contains real COVID-19 data from Argentina, loadable directly in the
platform. Users can explore actual epidemic dynamics, compare them against SEIR model projections,
and adjust parameters to understand modelling decisions made during the pandemic.

Remaining work: narrative documentation contextualising the Santoro dataset — its origin,
calibration decisions, and lessons learned — to be added to `docs/` as part of Product 3.

### Product 2 — Modular Shiny Dashboard
Core modular architecture fully deployed. The following ToR requirements remain pending:
- Simplified View (decision-maker interface with KPIs)
- External data connectivity (WHO, OWID APIs)
- Sociodemographic data layer (demographics, mobility, socioeconomic factors)
- Interactive presentation with practical exercises

### Product 3 — Implementation and User Guides
Technical documentation exists as `docs/documentacion.Rmd` (currently in Spanish).  
Translation to English, update to current architecture, and Santoro narrative are in progress.

### Access Model
Access is managed by open-source design: the public deployment provides the interactive frontend
for all users; researchers and NSOs requiring private datasets run the platform locally in their
own R environment. This is consistent with the ToR's open-source mandate.

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
> is achieved by open-source design as specified in the ToR, not by a separate plug-in system.

---

## 🧩 2. Functional Evaluation (ToR Product 2 requirements)

| ToR Requirement | Status | Progress |
|-----------------|--------|----------|
| Modular architecture (UI, Model, Data, Viz modules) | ✅ Implemented | **100%** |
| User-driven parameter adjustments | ✅ Operational | **100%** |
| Flexible model integration (open-source, modifiable) | ✅ By design | **90%** |
| Interactive visualisations | ✅ Three plot panels functional | **90%** |
| Web deployment | ✅ Live on shinyapps.io | **100%** |
| COVID-19 Argentina case study (Santoro dataset) | 🟡 Dataset integrated, narrative pending | **60%** |
| Simplified View — decision-maker interface | 🟡 Placeholder only | **10%** |
| External data connectivity (WHO, OWID APIs) | 🔴 Not implemented | **0%** |
| Sociodemographic data layer | 🔴 Not implemented | **0%** |
| Interactive presentation with practical exercises | 🔴 Not implemented | **0%** |
| **Subtotal Functional** | | **≈ 65%** |

> **Summary:** Core dashboard functionality is operational and deployed. Four ToR requirements
> remain pending: Simplified View, external API connectivity, sociodemographic data, and
> the interactive presentation.

---

## 🧬 3. Strategic Evaluation

| Strategic Pillar | Status | Progress |
|------------------|--------|----------|
| Development plan and milestones | ✅ Defined and up to date | **100%** |
| Repository documentation | ✅ Updated (March 2026) | **95%** |
| Public deployment with live URL | ✅ Achieved | **100%** |
| Access model aligned with open-source ToR | ✅ Resolved by design | **100%** |
| Product 3 — technical documentation | 🟡 Draft in Spanish, translation pending | **20%** |
| **Subtotal Strategic** | | **≈ 83%** |

> **Summary:** Strategic foundations are strong. Deployment is live, documentation is current,
> and the access model is coherent with the open-source mandate. Product 3 translation
> is the main remaining strategic task.

---

## 🧮 Global Weighted Estimate

| Dimension | Weight | Progress |
|-----------|--------|----------|
| Technical | 40% | 96% |
| Functional | 40% | 65% |
| Strategic | 20% | 83% |
| **Total Weighted Progress** | | **≈ 77%** ✅ |

> The project covers approximately **77% of ToR deliverables** as of March 2026.  
> The technical backbone is mature. Remaining work is concentrated in four functional
> ToR requirements and the Product 3 translation.

---

## 📈 Interpretation

- The project has successfully transitioned from a prototype to a **deployed simulation platform**.
- The core SEIR pipeline — data ingestion, ODE solving, visualisation, and export — is fully operational.
- The IECS/Santoro dataset provides the **interactive COVID-19 Argentina case study** (Product 1).
- Four ToR requirements for Product 2 remain pending: Simplified View, external data, sociodemographic layer, and interactive presentation.
- Product 3 exists as a draft and requires translation and expansion.

---

## 🧭 Next Phase (Q2 2026)

Ordered by ToR priority:

1. **Simplified View** — implement `mod_viz_simple.R` with core curves and KPIs for decision-makers (Product 2).
2. **External data connectivity** — API integration with WHO and OWID (Product 2).
3. **Sociodemographic data layer** — demographics and mobility data integration (Product 2).
4. **Interactive presentation** — infographic and practical exercises anchored to the Santoro case study (Product 2).
5. **Product 3** — translate, update, and expand `docs/documentacion.Rmd`; add Santoro narrative.

---

**Maintainer:** Cristian Paez  
**Date:** March 2026  
**Project:** Bowie / proto\_epi — Pandemic Preparedness Toolkit (Argentina Unit)  
**Funded by:** Wellcome
