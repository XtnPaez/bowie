# app.R
# Este es el archivo principal de la aplicación Shiny que une todos los módulos.

# Añadir un mensaje de depuración para verificar si el script principal se está ejecutando.
message("Shiny app starting...")

# Cargar el archivo global para las configuraciones y librerías
source("R/global.R")

# Cargar los módulos de UI, Server, Data, Model y Visualization
source("R/mod_ui.R")
source("R/mod_server.R")
source("R/mod_data.R")
source("R/mod_model.R")
source("R/mod_viz.R")

# Definir la aplicación Shiny
# Pasar el ID de visualización al UI principal
shinyApp(ui = ui_main("main_viz"), server = server)
