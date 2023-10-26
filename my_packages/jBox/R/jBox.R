# R/jBox.R

#' @export
jBox <- function(
    id,
    message,
    session = shiny::getDefaultReactiveDomain()
) {
  session$sendCustomMessage(
    type = "send-notice",
    message = message)
}