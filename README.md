# SEIR Shiny – Prototype Dashboard

This repository contains a modular Shiny prototype implementing an SEIR (Susceptible–Exposed–Infectious–Recovered) epidemiological model.  
It was developed as part of the **Pandemic Preparedness Toolkit – Argentina Unit** (Work Package: Modeling of Infectious Diseases).

<<<<<<< HEAD
## Project Overview
The app simulates disease spread and healthcare resource demand using adjustable epidemiological parameters.  
It is designed to be extensible, allowing new models to be plugged in via modular architecture.

## Folder Structure
- **R/** – Shiny modules (`mod_*`) including data, model, UI, and visualization logic.  
- **inst/i18n/** – Internationalization files (JSON format).  
- **man/** – Auto-generated documentation using `roxygen2`.  
- **docs/** – Technical documentation and rendered pkgdown site.  
=======
# Project Overview

The app simulates disease spread and healthcare resource demand using adjustable epidemiological parameters.
It is designed to be extensible, allowing new models to be plugged in via modular architecture.

## Folder Structure
>>>>>>> 552dba717ec08ac8f418b58f1326cbff03c2bf30

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

<<<<<<< HEAD
## Documentation
Generate package documentation and site:  
```r
=======
inst/i18n/ – Internationalization files (JSON format).

man/ – Auto-generated documentation using roxygen2.

docs/ – Technical documentation and rendered pkgdown site.

## Setup

Clone the repository:
git clone https://github.com/edeleitha/proto_epi.git

Install dependencies:
renv::restore()

Run the app:
shiny::runApp()

## Documentation

Generate package documentation and site:
>>>>>>> 552dba717ec08ac8f418b58f1326cbff03c2bf30
devtools::document()
pkgdown::build_site()
```

## License
<<<<<<< HEAD
MIT License (see LICENSE file)  

## Authors
- Cristian Paez (Lead Developer)  
- Fernando Poletta (Data Science Expert)
=======

MIT License (see LICENSE file)

## Author

Cristian Paez (Lead Developer)
>>>>>>> 552dba717ec08ac8f418b58f1326cbff03c2bf30
