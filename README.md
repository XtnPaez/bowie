# 🧮 Proyecto SEIR Shiny – Kit de Herramientas de Modelización

**Repositorio:** `edeleitha/proto_epi`  
**Rama activa:** `feat/paez`  
**Responsable técnico:** Cristian Páez  

---

## 📘 Descripción general

Este proyecto implementa una **aplicación Shiny modular** basada en el modelo epidemiológico **SEIR**
(Susceptibles – Expuestos – Infectados – Recuperados) como parte del *Kit de Herramientas para la Preparación ante Pandemias*.

El objetivo es evolucionar desde un prototipo funcional hacia un **framework multi-modelo (Model Hub)**
capaz de incorporar distintos dominios (epidemiología, accidentología, economía de la salud, etc.),
manteniendo estándares de reproducibilidad, documentación y escalabilidad.

---

## 🧩 Estructura del repositorio

R/                  — Scripts modulares (data, model, ui, server, viz)  
data/               — Datasets de prueba o externos  
docs/               — Documentación técnica y guías  
config/             — Archivos YAML de configuración (por implementar)  
models/             — Estructura para nuevos modelos (por implementar)  
tests/              — Tests unitarios y de UI (por implementar)  
roadmap.md          — Plan general de desarrollo y análisis estructural  

---

## 🚀 Roadmap y Progreso

El plan completo se encuentra documentado en **roadmap.md** (en la raíz del repo).

**Estado actual del avance (Octubre 2025):**

| Bloque | Descripción | Estado | Avance |
|--------|--------------|--------|--------|
| 🟥 1. Reestructuración técnica | Refactor del server, utils, renv, config | 🟡 En curso | ▓▓▓░░ 60% |
| 🟦 2. Internacionalización y Comentado | Código en inglés, i18n, documentación | ⚪ Pendiente | ░░░░░ 0% |
| 🟣 3. Generación del Model Hub | Orquestador multi-modelo y schemas | ⚪ Pendiente | ░░░░░ 0% |
| 🟢 4. Traducción y Documentación | Documentación multilanguage | ⚪ Pendiente | ░░░░░ 0% |
| 🟠 5. Testing y Despliegue | Validación, CI/CD, reproducibilidad | ⚪ Pendiente | ░░░░░ 0% |

*Actualizá esta tabla a medida que avances o cierres issues vinculados.*

---

## 🧭 Cómo contribuir

1. Trabajá siempre sobre una rama nueva derivada de `feat/paez`  
   - Ejemplo: `git checkout -b feat/nombre-tarea`
2. Al completar una tarea, abrí un *pull request* hacia `feat/paez`
3. Etiquetá el PR con el bloque correspondiente (reestructuración, i18n, hub, documentación, testing)
4. Vinculá el PR con el/los issues relacionados

---

## 🔐 Reproducibilidad y seguridad

- Uso recomendado de **renv** para congelar dependencias.  
- Variables sensibles en `.Renviron` (no commitear credenciales).  
- CI con GitHub Actions para tests y chequeos de estilo.  

---

## 👥 Créditos

- Equipo técnico Bowie / Revisión: Cristian Páez  
- Agradecimientos a los colaboradores del proyecto y a la comunidad Shiny.
