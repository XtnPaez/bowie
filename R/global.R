# global.R
# Este archivo contiene las configuraciones globales y carga de librerías necesarias.

# Cargar librerías
library(shiny)
library(dplyr)
library(bslib) #Para temas
library(deSolve) # Para resolver ecuaciones diferenciales ordinarias (EDOs)
library(ggplot2) # Para visualizaciones
library(lubridate) # Para manejo de fechas
library(RcppRoll) # Para funciones de rolling sum (ej. para ocupación de UCI)
library(tidyr) # Para funciones como replace_na() y pivot_longer/wider
library(scales) # Para funciones de formato de ejes como scales::comma
library(purrr) # Para trabajar con listas de parámetros por severidad
library(plotly) #Para gráficos interactivos
library(shinyjs) #Para UI
options(scipen = 999)

# Definiciones globales y parámetros por defecto 
# Población total 
POPULATION_ARGENTINA <- 45000000 # Aproximado a 45 millones (45.265.792 proyecciC3n INDEC para marzo 2020)

# Parámetros básicos del modelo SEIR para simulación inicial
# Estos se sobrescribirán con los valores de los widgets de UI
INITIAL_R0 <- 2.5
INITIAL_INCUBATION_PERIOD <- 5 # DC-as (1/sigma)
INITIAL_INFECTIOUS_PERIOD <- 7 # DC-as (1/gamma)
INITIAL_IFR <- 0.01 # Tasa de letalidad por infecciC3n (1%)



# ParC!metros de simulación de recursos
INITIAL_ICU_RATE <- 0.136 # Tasa de individuos infectados que requieren UCI
INITIAL_VENTILATOR_RATE <- 0.02 # Tasa de individuos infectados que requieren ventilador
INITIAL_HOSPITAL_STAY_DAYS <- 10 # DC-as de estancia hospitalaria promedio
INITIAL_ICU_CAPACITY <- 6000 # Capacidad inicial de camas UCI
INITIAL_VENTILATOR_AVAILABILITY <- 2000 # Disponibilidad inicial de ventiladores
INITIAL_HEALTHCARE_STAFF <- 10000 # Personal de salud inicial

# Fechas de inicio y fin para la simulación
# Estas pueden ser dinámicas en el futuro
START_DATE <- as.Date("2020-03-01")
END_DATE <- as.Date("2021-03-01")
