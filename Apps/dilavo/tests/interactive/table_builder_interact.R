#' @export
ui <- function(id) {
  
  box::use(
    app/view/table_builder,
    
    shiny
    [ bootstrapPage, fileInput, NS, ],
  )
  
  ns <- NS(id)
  bootstrapPage(
    table_builder$ui(ns("builder"))
  )
}

#' @export
server <- function(id) {
  
  box::use(
    app/view/table_builder,
    
    shiny
    [ moduleServer ],
  )
  
  moduleServer(id, function(input, output, session) {
    table_builder$server("builder")
  })
}