# Proyecto SEIR Shiny – Roadmap y Análisis Estructural

## Introducción
La aplicación actual presenta una arquitectura modular sólida y replicable, con módulos independientes (`mod_data`, `mod_model`, `mod_viz`, `mod_ui`, `mod_server`).  
Requiere sin embargo una segunda capa de ingeniería: reproducibilidad, internacionalización y desacople de datos.  
Este documento define el plan de evolución hacia un **Model Hub** multi-dominio (capaz de integrar distintos modelos, como epidemiología o accidentología).

---

## Estructura del Proyecto y Fortalezas
- Flujo modular `data → model → viz → ui → server`.
- Documentación técnica robusta y coherente (ver `/docs/`).
- Capacidad de replicabilidad y escalabilidad.
- Modularización compatible con despliegue Shiny Server o ShinyApps.io.

---

## Debilidades Detectadas
- `mod_server` concentra demasiadas responsabilidades.
- No existe una capa desacoplada de datos (`data_interface`).
- Falta control de entorno (`renv`, `DESCRIPTION`).
- Sin estructura de testeo (`/tests/`).
- Textos de UI fijos en español (sin i18n).
- Ausencia de `/R/utils/` para funciones comunes.

---

## Roadmap General

### 🔹 Bloque 1 – Reestructuración técnica
**Objetivo:** Consolidar una base modular, reproducible y escalable.  
**Subtareas:**
- Implementar `renv` o `DESCRIPTION` con dependencias.
- Refactor de `mod_server` → `server_loader`, `server_reactivity`, `server_outputs`.
- Crear `/R/utils/` (helpers, logging, validaciones, plot_factory).
- Crear `/R/data_interface.R` (lectura desde API, CSV o DB + validaciones).
- Introducir `/config/app.yml` y `/config/models.yml`.
- Revisar naming conventions y limpieza de imports.
- Esqueleto de `/tests/testthat/` y `/tests/shinytest2/`.

---

### 🔹 Bloque 2 – Internacionalización y Comentado del Código
**Objetivo:** Código íntegramente en inglés, UI multilingüe, documentación coherente.  
**Subtareas:**
- Incorporar `shiny.i18n` y archivos `/i18n/en.json` y `/i18n/es.json`.
- Migrar textos de UI (`mod_ui.R`) a `t("label_key")`.
- Reescribir comentarios inline y encabezados `roxygen2`.
- Implementar plantilla de comentario estándar:
  - Summary / Inputs / Outputs / Side-effects / Errors.
- Configurar `pkgdown` para documentación multilanguage.

---

### 🔹 Bloque 3 – Generación del Model Hub
**Objetivo:** Transformar el proyecto SEIR en un framework multi-modelo.  
**Subtareas:**
- Crear `/models/` con estructura modular (`/seir/`, `/accidentologia/`, ...).
- Desarrollar `/R/model_engine.R` y `/R/model_registry.R`.
- Establecer interfaz estándar de modelos (`init`, `run`, `describe`, `schema_in/out`, `ui_controls`).
- Crear `/R/schema.R` para normalizar estructuras de datos entre modelos.
- Ajustar `mod_server` (o nuevo `server_dispatcher`) para seleccionar modelo activo.
- Agregar soporte para visualizaciones dinámicas según modelo.
- Integrar metadatos YAML (`metadata.yml`) para cada modelo.

---

### 🔹 Bloque 4 – Traducción y Documentación
**Objetivo:** Generar versiones documentales multilanguage y guías.  
**Subtareas:**
- Traducir documentación técnica (`documentacion.pdf`, `documentacion.Rmd`) al inglés.
- Generar guía de implementación (`Implementation Guide`) y guía de usuario (`User Guide`).
- Normalizar nomenclatura técnica entre documentos y código.
- Crear estructura `/docs/en/` y `/docs/es/`.
- Integrar documentación automatizada (`pkgdown`).

---

### 🔹 Bloque 5 – Testing y Despliegue
**Objetivo:** Asegurar calidad, reproducibilidad y despliegue confiable.  
**Subtareas:**
- Testing de ecuaciones SEIR y funciones utilitarias (`testthat`).
- Pruebas de UI críticas (`shinytest2`).
- Linter y análisis estático (`lintr`, `goodpractice`).
- CI/CD con GitHub Actions.
- Snapshot de dependencias (`renv::snapshot()`).
- Validación de reproducibilidad (bootstrap desde repo limpio).

---

## Plan de Ejecución y Dependencias

| Bloque | Dependencia | Ejecución paralela | Justificación |
|--------|--------------|--------------------|----------------|
| **1. Reestructuración técnica** | Base de todos los demás | 🔴 No | Debe completarse primero |
| **2. Internacionalización / comentarios** | Depende del 1 | 🟡 Parcial | Puede iniciar mientras se estabiliza el refactor |
| **3. Model Hub** | Depende del 1 | 🟡 Parcial | Diseño puede avanzar mientras se termina la estructura |
| **4. Traducción / documentación** | Depende del 1 y 2 | 🟢 Sí | Puede ejecutarse en paralelo al desarrollo del Hub |
| **5. Testing / despliegue** | Transversal | 🟢 Sí | Acompaña cada fase del desarrollo |

---

## Conclusiones
La base del proyecto es **sólida y científicamente consistente**.  
Con las mejoras estructurales e introducción del **Model Hub**, se convertirá en una plataforma **modular, reproducible, internacionalizable y mantenible**, alineada con los lineamientos del *Kit de Herramientas para la Preparación ante Pandemias*.  

Este roadmap debe implementarse en la rama `feat/paez` antes de integrar a `main`.  
Cada bloque puede desarrollarse en ramas hijas (`feat/refactor`, `feat/i18n`, `feat/hub`, etc.) con *pull requests* documentados y trazables.

---

**Autor:** Equipo técnico Bowie / Revisión: Cristian Páez  
**Fecha:** Octubre 2025
