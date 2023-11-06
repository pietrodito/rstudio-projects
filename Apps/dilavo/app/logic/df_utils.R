#' @export
name_repair <- function(nm) {
  
  (empty <- nm == "")
  (fill_empty <- paste0("empty_", seq_len(sum(empty))))
  (nm[empty] <- fill_empty)
  
  nm <- tolower(nm)
  make.unique(nm, sep = "_")
}

