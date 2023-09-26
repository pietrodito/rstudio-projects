cd_to_sub <- function() {
  rstudioapi::insertText("cd(\"./\")")
  rstudioapi::setCursorPosition(c(1, 7))
}