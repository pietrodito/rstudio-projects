#' @export
launch_app <- function(file, dir = ".") {
  file <- fs::path_abs(file)
  current_dir <- getwd()
  withr::defer(setwd(current_dir))
  setwd(dir)
  source(file, echo = T)
}
