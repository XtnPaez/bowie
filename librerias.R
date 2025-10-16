# ============================================================
# Script: detect_and_install_packages.R
# Descripción: Detecta librerías usadas en el proyecto y las instala si faltan
# ============================================================

# ---- 1. Buscar todos los archivos R relevantes ----
project_files <- list.files(
  path = ".", 
  pattern = "\\.(R|Rmd|r|Rproj|qmd)$", 
  recursive = TRUE, 
  full.names = TRUE
)

# ---- 2. Leer todo el código ----
code <- unlist(lapply(project_files, readLines, warn = FALSE, encoding = "UTF-8"))

# ---- 3. Detectar llamadas a librerías ----
# Detecta library(xxx), require(xxx) o :: y extrae los nombres
library_calls <- unique(c(
  stringr::str_match(code, "(?<=library\\()\\s*['\"]?([A-Za-z0-9\\.]+)['\"]?\\s*\\)?")[,2],
  stringr::str_match(code, "(?<=require\\()\\s*['\"]?([A-Za-z0-9\\.]+)['\"]?\\s*\\)?")[,2],
  stringr::str_match(code, "([A-Za-z0-9\\.]+)::")[,2]
))

# Limpieza
library_calls <- library_calls[!is.na(library_calls)]
library_calls <- sort(unique(library_calls))

cat("🔍 Librerías detectadas en el proyecto:\n")
print(library_calls)

# ---- 4. Verificar cuáles faltan ----
installed_packages <- rownames(installed.packages())
missing_packages <- setdiff(library_calls, installed_packages)

# ---- 5. Instalar las que falten ----
if (length(missing_packages) > 0) {
  cat("\n📦 Instalando paquetes faltantes:\n")
  print(missing_packages)
  install.packages(missing_packages, dependencies = TRUE, repos = "https://cloud.r-project.org")
} else {
  cat("\n✅ Todos los paquetes detectados ya están instalados.\n")
}

# ---- 6. Cargar las librerías detectadas ----
cat("\n🚀 Cargando librerías...\n")
sapply(library_calls, function(pkg) {
  suppressPackageStartupMessages(library(pkg, character.only = TRUE))
})
