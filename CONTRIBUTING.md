Contributing Guidelines

Thank you for your interest in contributing to proto_epi!
This project follows best practices for reproducible and modular Shiny development.

General Rules

Use feature branches with clear prefixes (feat/, fix/, refactor/, doc/).

Follow the tidyverse style guide: https://style.tidyverse.org

Document every function with roxygen2 headers.

Write comments in English; UI labels may use localized strings via the i18n JSON files.

Run tests before pushing:
devtools::test()
lintr::lint_package()

Use pull requests for all contributions and reference issue numbers in your commits.

Commit Messages

Follow the conventional commit style:

feat: add new functionality

fix: correct a bug

refactor: improve existing code

docs: update documentation

Example:
feat(mod_server): refactor reactivity module for better parameter updates