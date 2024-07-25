#' @export
ovalide_data_path <- function(subpath) {
  if(Sys.getenv("RUN_IN_DOCKER") == "YES") {
    parent_dir <- "/"
  } else {
    parent_dir <- ""
  }
  
  paste0(parent_dir, "ovalide_data/", subpath)
}
