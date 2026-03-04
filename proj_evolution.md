# Project Evolution – Status Report (March 2026)

This document summarises the overall progress of the **Bowie / SEIR Shiny** project.  
It reflects the current maturity level based on technical, functional, and strategic dimensions,
and maps deliverables against the Terms of Reference (ToR) for the Pandemic Preparedness Toolkit
(Argentina Unit), Work Package 5.

**Live deployment:** <https://cpaez.shinyapps.io/bowie-seir/>  
**Repository:** <https://github.com/XtnPaez/bowie>

---

## 📋 ToR Alignment – Product Delivery Status

The ToR defines three products for this Unit. Current status:

| Product | Description | Status | Progress |
|---------|-------------|--------|----------|
| **Product 1** | Case Study: COVID-19 modelling in Argentina | 🟡 Embedded in dashboard | **60%** |
| **Product 2** | Modular Shiny Dashboard prototype | ✅ Deployed and functional | **85%** |
| **Product 3** | Implementation and User Guides | 🟡 Draft in progress | **20%** |

### Product 1 — Case Study
The case study is implemented as an **interactive demonstration** rather than a standalone document.  
The IECS dataset (Santoro model) contains real COVID-19 data from Argentina and is directly loadable
in the dashboard. Users can explore actual epidemic dynamics, compare them against SEIR model
projections, and adjust parameters to understand the modelling decisions made during the pandemic.  
This approach aligns with the ToR's emphasis on combining theoretical foundations with practical examples.

Remaining work: narrative documentation contextualising the Santoro dataset — its origin, calibration
decisions, and lessons learned — to be added to `docs/` as part of Product 3.

### Product 2 — Modular Shiny Dashboard
Fully deployed at https://cpaez.shinyapps.io/bowie-seir/. Core features operational.  
Remaining: Simplified View (`mod_viz_simple.R`) and external API connectivity (WHO, OWID).

### Product 3 — Implementation and User Guides
Technical documentation exists as `docs/documentacion.Rmd` (currently in Spanish).  
Translation to English and update to reflect current architecture is in progress.

### Access Model
The ToR notes that different user groups require distinct access levels. For this open-source
prototype, access is managed by design: the public deployment provides the interactive frontend
for all users, while researchers and NSOs who require access to private datasets run the platform
locally in their own R environment. This approach is consistent with the ToR's confirmation that
the platform will be open source.

---

## 🧠 1. Technical Evaluation

| Component | Status | Estimated Progress |
|-----------|--------|--------------------|
| Modular structure `/R/mod_*` | ✅ Complete and stable | **100%** |
| Logging and validation system (`utils_*`) | ✅ Consolidated | **100%** |
| SEIR model core (equations and reactivity) | ✅ Stable and deployed | **95%** |
| Data Hub Interface (`data_interface.R`) | ✅ Implemented | **90%** |
| Advanced visualisation module (`mod_viz`) | ✅ Functional — all plots rendering | **90%** |
| Visualisation module wiring (`viz_plot_server`) | ✅ Fixed and connected | **100%** |
| CSV export of simulation results | ✅ Implemented | **100%** |
| IECS / Santoro dataset integration | ✅ Loadable and functional | **90%** |
| Internationalisation and code cleanup | ✅ Completed | **100%** |
| **Subtotal Technical** | | **≈ 97%** |

> **Summary:** The technical core is robust, fully modular, and deployed. All major reactive
> connections between parameters, model, and visualisation are functional. The Santoro dataset
> is integrated and serves as the interactive COVID-19 Argentina case study.

---

## 🧩 2. Functional Evaluation

| Element | Status | Estimated Progress |
|---------|--------|--------------------|
| Workflow "dataset → model → visualisation" | ✅ Fully functional | **90%** |
| Entry screen and dataset selection | ✅ Implemented (mock + IECS/Santoro) | **90%** |
| Advanced View with real-time parameter updates | ✅ Operational | **90%** |
| Navigation menu with dataset indicator | ✅ Implemented | **100%** |
| Public deployment on shinyapps.io | ✅ Live | **100%** |
| CSV scenario export | ✅ Implemented | **100%** |
| Product 1: interactive COVID-19 case study (Santoro) | 🟡 Dataset integrated, narrative pending | **60%** |
| Simplified visualisation mode (Simple View) | 🟡 Placeholder only | **10%** |
| External data connectivity (WHO, OWID APIs) | 🔴 Not implemented | **0%** |
| **Subtotal Functional** | | **≈ 76%** |

> **Summary:** Core functionality is operational and deployed. The Santoro dataset provides
> the interactive case study component. Remaining gaps are the Simplified View, narrative
> documentation, and external API connectivity.

---

## 🧬 3. Strategic Evaluation

| Strategic Pillar | Status | Estimated Progress |
|------------------|--------|--------------------|
| Development plan and milestones | ✅ Defined and up to date | **100%** |
| Technical and organisational documentation | ✅ Updated (March 2026) | **95%** |
| Public deployment with live URL | ✅ Achieved | **100%** |
| Access model aligned with open-source ToR | ✅ Resolved by design | **100%** |
| Scalability to new infection models | 🟡 Viable but unimplemented | **30%** |
| Testing and CI/CD | 🔴 Pending | **0%** |
| **Subtotal Strategic** | | **≈ 70%** |

> **Summary:** Strategic foundations are strong. Deployment is live, documentation is current,
> and the access model is coherent with the open-source mandate. Testing and Model Hub
> expansion remain as next-phase priorities.

---

## 🧮 Global Weighted Estimate

| Dimension | Weight | Progress |
|-----------|--------|----------|
| Technical | 40% | 97% |
| Functional | 40% | 76% |
| Strategic | 20% | 70% |
| **Total Weighted Progress** | | **≈ 82%** ✅ |

> The project has advanced from ~57% (October 2025) to approximately **82% complete**
> as of March 2026, with the Santoro dataset integration and access model clarification
> contributing to the revised estimate.

---

## 📈 Interpretation

- The project has successfully transitioned from a **prototype** to a **deployed simulation platform**.
- The core SEIR modelling pipeline — data ingestion, ODE solving, visualisation, and export — is fully operational.
- The IECS/Santoro dataset provides the **interactive COVID-19 Argentina case study** (Product 1).
- Remaining work covers three areas: Simplified View, narrative documentation, and test coverage — all lower-risk tasks with clear implementation paths.

---

## 🧭 Next Phase (Q2 2026)

1. **Narrative documentation for Product 1** — contextualise the Santoro dataset in `docs/`: origin, calibration, lessons learned.
2. **Simple View** — implement `mod_viz_simple.R` with core curves and KPIs for decision-makers.
3. **Product 3 translation** — complete English translation and update of `docs/documentacion.Rmd`.
4. **External Data Connectivity** — API integration with WHO and OWID for real-time surveillance data.
5. **Model Hub** — plug-in architecture to support SIR, SEIRD, and custom models.
6. **Testing Layer** — unit tests (`testthat`) and UI tests (`shinytest2`).
7. **CI/CD Pipeline** — GitHub Actions for automated validation on push.

---

**Maintainer:** Cristian Paez  
**Date:** March 2026  
**Project:** Bowie / proto\_epi — Pandemic Preparedness Toolkit (Argentina Unit)  
**Funded by:** Wellcome
