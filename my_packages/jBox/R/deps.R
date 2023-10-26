# R/deps.R

#' @export
use_jBox <- function() {
  
  pkg <- htmltools::htmlDependency(
    name = "jBox-pkg",
    version = "1.0.0",
    src = "",
    script = c(file = "jBox.js"),
    package = "jBox"
  )
  
  ml5 <- htmltools::htmlDependency(
    name = "jBox",
    version = "1.3.3",
    src = c(href = paste0(
      "https://cdn.jsdelivr.net/gh/StephanWagner/",
      "jBox@v1.3.3/dist/")),
    script = "jBox.all.min.js"
  )
  
  htmltools::tagList(ml5, pkg)
}