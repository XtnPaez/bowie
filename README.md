# SEIR Shiny – Prototype Dashboard

This repository contains a modular Shiny prototype implementing an SEIR (Susceptible–Exposed–Infectious–Recovered) epidemiological model.  
It was developed as part of the **Pandemic Preparedness Toolkit – Argentina Unit** (Work Package: Modeling of Infectious Diseases).

## Project Overview
The app simulates disease spread and healthcare resource demand using adjustable epidemiological parameters.  
It is designed to be extensible, allowing new models to be plugged in via modular architecture.

## Folder Structure
- **R/** – Shiny modules (`mod_*`) including data, model, UI, and visualization logic.  
- **inst/i18n/** – Internationalization files (JSON format).  
- **man/** – Auto-generated documentation using `roxygen2`.  
- **docs/** – Technical documentation and rendered pkgdown site.  

## Setup
1. Clone the repository:  
   ```bash
   git clone https://github.com/edeleitha/proto_epi.git
   ```
2. Install dependencies:  
   ```r
   renv::restore()
   ```
3. Run the app:  
   ```r
   shiny::runApp()
   ```

## Documentation
Generate package documentation and site:  
```r
devtools::document()
pkgdown::build_site()
```

## License
MIT License (see LICENSE file)  

## Authors
- Cristian Paez (Lead Developer)  
- Fernando Poletta (Data Science Expert)
