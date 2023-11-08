box::use(
  shiny[bootstrapPage, div, moduleServer, NS, renderUI, tags, wellPanel, ],
  
  shinyjs [ useShinyjs, ],
  
  app/view/disable
  
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  bootstrapPage(
    wellPanel(
      # useShinyjs(),
    ),
    disable$ui(ns("x"))
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    disable$server("x")
  })
}
