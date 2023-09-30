#' @export
use_rhino_dockerfile <- function(path = '.') {
  fs::file_copy(
    fs::path_package("extdata/rhino",
                     c("Dockerfile", ".dockerignore"),
                     package = "consoleR"),
    paste0(path),
    overwrite = TRUE
  ) 
}