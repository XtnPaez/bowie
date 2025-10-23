# utils_logging.R
# Lightweight logger for the app

log_message <- function(level = "INFO", msg = "", .module = NULL, ...) {
  levels <- c("DEBUG","INFO","WARN","ERROR")
  level <- toupper(level)
  if (!level %in% levels) level <- "INFO"
  
  env_level <- Sys.getenv("LOG_LEVEL", "INFO")
  env_idx   <- match(toupper(env_level), levels)
  lvl_idx   <- match(level, levels)
  if (!is.na(env_idx) && lvl_idx < env_idx) return(invisible(NULL))
  
  ts <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  context <- list(...)
  ctx_str <- if (length(context)) {
    paste(paste0(names(context), "=", unlist(context)), collapse=" | ")
  } else ""
  module_str <- if (!is.null(.module)) paste0("[", .module, "] ") else ""
  cat(sprintf("%s | %-5s | %s%s%s\n", ts, level, module_str, msg,
              if (nzchar(ctx_str)) paste0(" | ", ctx_str) else ""))
  invisible(NULL)
}

set_log_level <- function(level = c("DEBUG","INFO","WARN","ERROR")) {
  level <- match.arg(level)
  Sys.setenv(LOG_LEVEL = level)
}

with_timing <- function(expr, .module = NULL, .label = "timed_block") {
  t0 <- proc.time()[["elapsed"]]
  on.exit({
    t1 <- proc.time()[["elapsed"]]
    log_message("DEBUG", paste0(.label, " completed"), .module, elapsed_sec = round(t1 - t0, 3))
  })
  force(expr)
}
