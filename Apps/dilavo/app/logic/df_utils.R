#' @export
name_repair <- function(nm) {
  nm <- tolower(nm)
  make.unique(nm, sep = "_")
}



