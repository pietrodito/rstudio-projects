#' @export
welcome_message <- function(message = "Welcome!", fortune = TRUE) {

  if (fortune) print(fortunes::fortune())
  dotline()
  pad_message(message)
  dotline()
}

dotline <- function(width = 80) {
  cat(paste0(rep("-", 80), collapse = ""), "\n")
}
pad_message <- function(message = message, width = 80) {

  cat("|")
  cat(stringr::str_pad(message, width = width - 2, side = "both"))
  cat("|\n")
}
