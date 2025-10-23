convert_R_to_txt <- function(path = "R") {
  # Verificar si la carpeta existe
  if (!dir.exists(path)) stop("La carpeta especificada no existe.")
  
  # Listar los archivos .R dentro de la carpeta
  archivos_R <- list.files(path, pattern = "\\.R$", full.names = TRUE)
  
  if (length(archivos_R) == 0) {
    message("No se encontraron archivos .R en la carpeta especificada.")
    return(invisible(NULL))
  }
  
  # Recorrer los archivos y crear su versión .txt
  for (archivo in archivos_R) {
    contenido <- readLines(archivo, warn = FALSE)
    nuevo_nombre <- sub("\\.R$", ".txt", archivo)
    writeLines(contenido, nuevo_nombre)
    message(paste("✅ Generado:", basename(nuevo_nombre)))
  }
  
  message("🚀 Conversión completa.")
}

# Ejemplo de uso:
# convert_R_to_txt("R")
