# ============================================================
# File: libraries.R
# ------------------------------------------------------------
# Description: Detects all R packages used across the project,
# installs missing dependencies, and loads them automatically.
# Author: Cristian Paez
# Created: 2025-11-07
# ============================================================

# ------------------------------------------------------------
# Step 1. Scan project for relevant R source files
# ------------------------------------------------------------
project_files <- list.files(
  path = ".",
  pattern = "\\.(R|Rmd|r|Rproj|qmd)$",
  recursive = TRUE,
  full.names = TRUE
)

# ------------------------------------------------------------
# Step 2. Read all code lines from detected files
# ------------------------------------------------------------
code <- unlist(lapply(project_files, readLines, warn = FALSE, encoding = "UTF-8"))

# ------------------------------------------------------------
# Step 3. Detect package calls
# ------------------------------------------------------------
# Matches: library(xxx), require(xxx), and pkg::function()
library_calls <- unique(c(
  stringr::str_match(code, "(?<=library\\()\\s*['\"]?([A-Za-z0-9\\.]+)['\"]?\\s*\\)?")[, 2],
  stringr::str_match(code, "(?<=require\\()\\s*['\"]?([A-Za-z0-9\\.]+)['\"]?\\s*\\)?")[, 2],
  stringr::str_match(code, "([A-Za-z0-9\\.]+)::")[, 2]
))

# Clean up and deduplicate results
library_calls <- library_calls[!is.na(library_calls)]
library_calls <- sort(unique(library_calls))

# --- Filter out common false positives ---
library_calls <- setdiff(library_calls, c("pkg", "xxx", "", "base"))

# Clean up and deduplicate results
library_calls <- library_calls[!is.na(library_calls)]
library_calls <- sort(unique(library_calls))

cat("🔍 Detected project libraries:\n")
print(library_calls)

# ------------------------------------------------------------
# Step 4. Identify missing packages
# ------------------------------------------------------------
installed_packages <- rownames(installed.packages())
missing_packages <- setdiff(library_calls, installed_packages)

# ------------------------------------------------------------
# Step 5. Install missing dependencies
# ------------------------------------------------------------
if (length(missing_packages) > 0) {
  cat("\n📦 Installing missing packages:\n")
  print(missing_packages)
  install.packages(
    missing_packages,
    dependencies = TRUE,
    repos = "https://cloud.r-project.org"
  )
} else {
  cat("\n✅ All required packages are already installed.\n")
}

# ------------------------------------------------------------
# Step 6. Load all detected libraries
# ------------------------------------------------------------
cat("\n🚀 Loading libraries...\n")
sapply(library_calls, function(pkg) {
  suppressPackageStartupMessages(library(pkg, character.only = TRUE))
})
