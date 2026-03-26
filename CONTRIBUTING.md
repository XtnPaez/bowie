# Contributing Guidelines

Thank you for your interest in contributing to the project — a modular Shiny dashboard for infectious disease modelling, developed as part of the Pandemic Preparedness Toolkit (Argentina Unit), funded by Wellcome.

The platform serves three ToR deliverables: an interactive COVID-19 Argentina case study powered by the IECS/Santoro real dataset (Product 1), the modular Shiny dashboard itself (Product 2), and technical documentation (Product 3).

This project follows best practices for reproducible and modular Shiny development in R.

---

## Project Structure

```
bowie/
├── app.R                  # Application entry point
├── R/
│   ├── global.R           # Global constants and library loading
│   ├── data_interface.R   # Data Hub: loading, validation, persistence
│   ├── mod_entry.R        # Entry screen module
│   ├── mod_menu.R         # Navigation menu module
│   ├── mod_ui.R           # Main UI layout and parameter panels
│   ├── mod_server.R       # Main server module (parameters, model wiring)
│   ├── mod_model.R        # SEIR ODE model logic
│   ├── mod_viz.R          # Visualisation module (ggplot2 plots)
│   ├── mod_data.R         # Data simulation module
│   └── utils/
│       ├── utils_logging.R      # Logging utilities
│       ├── utils_validation.R   # Parameter validation utilities
│       ├── utils_helpers.R      # Numeric helpers and safe ODE wrapper
│       └── utils_dependencies.R # Automatic dependency detection and installation
├── data/
│   ├── mock_dataset.rds   # Simulated default dataset
│   └── iecs_data.RData    # IECS (Santoro) dataset
└── www/
    └── custom.css         # Visual overrides for bslib/Bootstrap 5
```

---

## General Rules

1. Use **feature branches** with clear prefixes:
   - `feat/` — new functionality
   - `fix/` — bug corrections
   - `refactor/` — code improvements without behaviour change
   - `doc/` — documentation updates

2. Follow the **tidyverse style guide**: <https://style.tidyverse.org>

3. Follow the project's **CODESTYLE.md** for commenting, naming, and file header conventions.

4. All code and comments must be written in **English (British spelling)**: `colour`, `analyse`, `initialise`.

5. Use **pull requests** for all contributions. Reference the relevant issue number in your PR description.

6. Before pushing, check your code with:
   ```r
   lintr::lint("R/your_file.R")
   ```

---

## Current Development Status

The project is under active development. Key areas open for contribution:

- **Simple View module** (`mod_viz_simple.R`) — a simplified interface for decision-makers with KPIs and core curves only. Currently disabled pending implementation.
- **Testing layer** — unit tests with `testthat` and UI tests with `shinytest2` are planned but not yet implemented.
- **Model Hub** — infrastructure to support additional compartmental models beyond SEIR.
- **External data connectivity** — API integration with WHO, OWID, and national surveillance repositories.

---

## Commit Messages

Follow the conventional commit style:

- `feat:` add new functionality
- `fix:` correct a bug
- `refactor:` improve existing code without changing behaviour
- `docs:` update documentation
- `style:` formatting changes only (no logic change)
- `test:` add or update tests

**Example:**
```
feat(mod_server): add CSV download handler for scenario export
fix(mod_viz): resolve resource pressure plot rendering on first load
docs(README): update deployment instructions for shinyapps.io
```

---

## Deployment

The live prototype is available at:
**<https://cpaez.shinyapps.io/bowie-seir/>**

To deploy updates after local testing:
```r
rsconnect::deployApp(
  appDir = ".",
  appName = "bowie-seir",
  forceUpdate = TRUE
)
```

---

## Contact

**Maintainer:** Cristian Paez
**Email:** paez.cristian@gmail.com
**Project:** Bowie / proto\_epi — Pandemic Preparedness Toolkit (Argentina Unit)
**Funded by:** Wellcome
