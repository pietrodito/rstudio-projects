if (file.exists("renv")) {
  source("renv/activate.R")
} else {
  # The `renv` directory is automatically skipped when deploying with rsconnect.
  message("No 'renv' directory found; renv won't be activated.")
}

# Allow absolute module imports (relative to the app root).
options(box.path = getwd())

# local packages
Sys.setenv(RENV_PATHS_CELLAR = "./packages")

# added by consoleR
if (interactive()) { source("~/.Rprofile") }

# added by consoleR
if (interactive()) { source("~/.Rprofile") }

