# Estado de Avance – Octubre 2025

Este documento registra el estado operativo del proyecto **SEIR Shiny – Prototype Dashboard**.  
Actualizado tras la reorganización estratégica centrada en el nuevo **Data Hub** y la experiencia de usuario.

---

## 🔍 Resumen General

El proyecto completó su primera fase técnica (Issues 1–4), consolidando la base modular y la internacionalización del código.  
La aplicación se ejecuta correctamente con todas las dependencias instaladas.  
Actualmente se avanza hacia la segunda fase, centrada en la gestión dinámica de datos y la experiencia de usuario (Data Hub + vistas simples/avanzadas).

---

## 🧭 Tabla de Estado Actual

| Bloque | Descripción | Estado | Avance |
|--------|--------------|--------|--------|
| 🟩 **1. Refactor Técnico** | Modularización, utils, logging, validaciones. | ✅ Completo | █████ 100% |
| 🟩 **2. Internacionalización** | Código y UI en inglés, limpieza de dependencias. | ✅ Completo | █████ 100% |
| 🟨 **3. Data Hub Interface** | Interfaz `/R/data_interface.R` para carga, validación y persistencia de datasets. | 🟡 En curso | ███▓░ 50% |
| 🟦 **4. Rediseño de Experiencia de Usuario** | Nueva pantalla de entrada, menú de vistas simple/avanzada. | ⚪ Planificado | ░░░░░ 0% |
| 🟪 **5. Visualización Simplificada** | Módulo `mod_viz_simple.R` con KPIs y curvas clave. | ⚪ Planificado | ░░░░░ 0% |
| 🟧 **6. Model Hub** | Incorporación de nuevos modelos de infección y estructura plug-in. | ⚪ Planificado | ░░░░░ 0% |
| 🟫 **7. Testing y Despliegue** | Test unitarios (`testthat`) y CI/CD (GitHub Actions). | ⚪ Planificado | ░░░░░ 0% |

---

## 🧩 Prioridades Inmediatas

1. **Finalizar Bloque 3 – Data Hub Interface.**
   - Implementar funciones `get_data()`, `validate_schema()`, `save_dataset()` y `list_datasets()`.
   - Probar validaciones con datasets reales (mock + IECS).

2. **Diseñar Bloque 4 – UX Redesign.**
   - Rediseñar pantalla de entrada y navegación de vistas (simple/avanzada).
   - Definir flujos de persistencia de dataset seleccionado.

3. **Iniciar prototipo de Bloque 5 – Simplified View.**
   - Módulo `mod_viz_simple.R` con visualización compacta y KPIs.

---

## 🧱 Estructura de Avance

- **Primera fase (Issues 1–4):** arquitectura técnica consolidada ✅  
- **Segunda fase (Issues 5–7):** centrada en Data Hub, experiencia de usuario y visualización.  
- **Tercera fase (futura):** expansión del Model Hub y nuevos modelos de infección.

---

## 📅 Próxima Actualización

> **Próxima revisión del estado:** Noviembre 2025  
> Responsable: Cristian Paez  
> Proyecto: *Bowie / proto_epi*
