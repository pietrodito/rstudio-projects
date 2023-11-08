#' @export
install_my_packages_inside_rhino <- function(project_path) {
  write(
    '
# added by consoleR
if (interactive()) { source("~/.Rprofile") }
',
paste0(project_path, "/.Rprofile"),
append = TRUE
  )
  
  setwd(project_path)
  clipboard <- 'purrr::walk(fs::dir_ls("~/my_packages/RStudio-tools"), ~ renv::install(.))'
  clipr::write_clip(clipboard)
  cli::cat_boxx(
    "Restart with CTRL+F10, then paste content of clipboard",
    "Clipboard updated",
    "↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ clipboard content ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓")
  cli::cat_line()
  cli::cat_bullet(clipboard) 
}
