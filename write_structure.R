# ============================================================
# File: write_structure.R
# ------------------------------------------------------------
# Description: Writes the project directory structure to
#   structure.txt. Lists all folders and the files they
#   contain, relative to the project root. Hidden files and
#   directories (prefixed with ".") are excluded.
#   Run this script from the project root directory.
# Usage:
#   source("write_structure.R")
#   — or —
#   Rscript write_structure.R
# Output:
#   structure.txt in the project root.
# Author: Cristian Paez
# Created: 2026-03-19
# ============================================================

# Root is wherever the script is run from
root <- getwd()

# Collect all files recursively, excluding hidden paths
all_files <- list.files(
  path       = root,
  recursive  = TRUE,
  full.names = FALSE,
  all.files  = FALSE   # excludes dot-files and dot-folders
)

# Remove any path that contains a hidden segment (e.g. .git/)
all_files <- all_files[!grepl("(^|/)\\.", all_files)]

# Build a named list: folder -> character vector of filenames
structure_list <- list()

for (f in all_files) {
  parts  <- strsplit(f, "/")[[1]]
  folder <- if (length(parts) == 1) "[root]" else paste(parts[-length(parts)], collapse = "/")
  fname  <- parts[length(parts)]
  structure_list[[folder]] <- c(structure_list[[folder]], fname)
}

# Sort folders: [root] first, then alphabetically
folder_names <- names(structure_list)
root_idx     <- which(folder_names == "[root]")
other_idx    <- sort(setdiff(seq_along(folder_names), root_idx))
ordered_keys <- folder_names[c(root_idx, other_idx)]

# Build output lines
lines <- c(
  "Project Structure",
  paste0("Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
  paste0("Root: ", root),
  ""
)

for (folder in ordered_keys) {
  lines <- c(lines, paste0("[ ", folder, " ]"))
  for (fname in sort(structure_list[[folder]])) {
    lines <- c(lines, paste0("  ", fname))
  }
  lines <- c(lines, "")
}

# Write to file
out_path <- file.path(root, "structure.txt")
writeLines(lines, con = out_path)

message("structure.txt written to: ", out_path)
