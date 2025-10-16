# Contributing Guidelines

Thank you for your interest in contributing to **proto_epi**!  
This project follows best practices for reproducible and modular Shiny development.

## General Rules
1. Use **feature branches** with clear prefixes (`feat/`, `fix/`, `refactor/`, `doc/`).  
2. Follow the **tidyverse style guide**: <https://style.tidyverse.org>  
3. Document every function with **roxygen2** headers.  
4. Write **comments in English**; UI labels may use localized strings via the i18n JSON files.  
5. Run tests before pushing:  
   ```r
   devtools::test()
   lintr::lint_package()
   ```
6. Use **pull requests** for all contributions and reference issue numbers in your commits.

## Commit Messages
Follow the conventional commit style:
- **feat:** add new functionality  
- **fix:** correct a bug  
- **refactor:** improve existing code  
- **docs:** update documentation  

**Example:**  
```text
feat(mod_server): refactor reactivity module for better parameter updates
```
