#' @export
cd <- function(path = "~", verbose = TRUE, explore = TRUE) {

  stopifnot(fs::dir_exists(path) || fs::link_exists(path))

  switch_to_project <- FALSE
  if (is_project_path(path)) {
    switch_to_project <- TRUE
  }

  setwd(path)

  if (verbose) ls_(hidden = FALSE)
  
  if ( ! explore && switch_to_project) {
    usethis::proj_set(".")
    system("touch README.md")
    
    rstudioapi::navigateToFile("README.md")
    cli::cat_boxx("Don't forget to restart session...")
  }
  
  invisible()
}

is_project_path <- function(path) {

  length(fs::dir_ls(path, regexp = "\\.Rproj$")) == 1

}
