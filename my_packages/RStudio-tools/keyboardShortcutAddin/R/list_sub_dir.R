list_sub_dir <- function() {
  rstudioapi::insertText("ls_(\"./\")")
  rstudioapi::setCursorPosition(c(1, 8))
}
