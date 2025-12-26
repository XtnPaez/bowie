convert_R_to_txt <- function(path = "R", out_dir = "txt_out") {
  # Verify that the input folder exists
  if (!dir.exists(path)) stop("La carpeta especificada no existe.")
  
  # Ensure output folder exists
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  
  # Collect all .R/.r files recursively (includes R/utils/)
  archivos_R <- list.files(
    path,
    pattern = "\\.[Rr]$",
    full.names = TRUE,
    recursive = TRUE,
    all.files = TRUE
  )
  
  if (length(archivos_R) == 0) {
    message("No se encontraron archivos .R/.r en la carpeta especificada.")
    return(invisible(NULL))
  }
  
  message("📌 getwd(): ", getwd())
  message("📌 Input path: ", normalizePath(path, winslash = "/", mustWork = FALSE))
  message("📌 Output dir: ", normalizePath(out_dir, winslash = "/", mustWork = FALSE))
  message("📌 Total files found: ", length(archivos_R))
  
  ok <- 0
  fail <- 0
  
  for (archivo in archivos_R) {
    tryCatch({
      contenido <- readLines(archivo, warn = FALSE)
      
      rel_path <- sub(
        paste0("^", normalizePath(path, winslash = "/", mustWork = FALSE), "/"),
        "",
        normalizePath(archivo, winslash = "/", mustWork = FALSE)
      )
      
      target_txt <- file.path(
        out_dir,
        sub("\\.[Rr]$", ".txt", rel_path)
      )
      
      dir.create(dirname(target_txt), recursive = TRUE, showWarnings = FALSE)
      writeLines(contenido, target_txt)
      
      ok <- ok + 1
      message("✅ Generado: ", target_txt)
    }, error = function(e) {
      fail <- fail + 1
      message("❌ Falló: ", archivo, " | ", e$message)
    })
  }
  
  message("🚀 Conversión completa. OK=", ok, " FAIL=", fail)
  
  invisible(list(ok = ok, fail = fail, files = archivos_R))
}

