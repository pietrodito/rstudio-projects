#' @export
notify_please_wait <- function() {
  
  box::use(
    shiny[ showNotification, ],
  )
  
  showNotification("Veuillez patienter...",
                   duration = NULL,
                   id = "only-one",
                   type = "warning")
}