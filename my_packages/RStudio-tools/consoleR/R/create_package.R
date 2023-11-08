#' @export
create_package <- function(path) {
  usethis::create_package(path, open = FALSE)
  setwd(path)
}
