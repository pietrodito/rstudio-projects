box::use(
  
  app/view/disable,
  
  shiny[bootstrapPage, div, moduleServer, NS, renderUI, tags, uiOutput],
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  bootstrapPage(
    disable$ui(ns("dis"))
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    disable$server("dis")
  })
}
