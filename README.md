# SEIR Shiny – Prototype Dashboard

This repository contains a modular Shiny prototype implementing an SEIR (Susceptible–Exposed–Infectious–Recovered) epidemiological model.  
It is part of the **Pandemic Preparedness Toolkit – Argentina Unit** (Work Package: Modelling of Infectious Diseases).

## Project Overview
The application simulates disease spread and healthcare resource demand using adjustable epidemiological parameters.  
It is evolving into a **Data Hub and Simulation Framework**, allowing users to load, validate, and persist datasets for different epidemiological models.  
A simplified and an advanced visualisation mode will be available to support both analytical and decision-oriented use.

## Folder Structure
- **R/** – Modular Shiny components (`mod_*`) handling data, model, UI, and visualisation logic.  
- **R/utils/** – Helper functions for logging, validation, and shared computations.  
- **R/data_interface.R** – Data Hub interface for loading, validating, and storing datasets.  
- **docs/** – Technical documentation and user guides.  
- **tests/** – Automated test scripts (`testthat`, `shinytest2`).  

## Setup
1. Clone the repository:  
   ```bash
   git clone https://github.com/edeleitha/proto_epi.git
   ```
2. Restore dependencies:  
   ```r
   renv::restore()
   ```
3. Run the application:  
   ```r
   shiny::runApp()
   ```

## Future Features
- Dynamic Data Hub with dataset upload and validation.
- Persistent dataset management across sessions.
- Simplified and advanced simulation views.
- Extensible Model Hub supporting multiple infection types.
- Improved visualisation and interactive controls.

## Documentation
Generate package documentation and site:  
```r
devtools::document()
pkgdown::build_site()
```

## License
MIT License (see LICENSE file).

## Authors
- Cristian Paez (Lead Developer)
- Bowie Project Technical Team
