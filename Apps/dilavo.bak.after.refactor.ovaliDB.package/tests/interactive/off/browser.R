#' @export
ui <- function(id) {
  
  box::use(
    shiny
    [ actionButton, bootstrapPage, NS, ],
  )
  
  ns <- NS(id)
  bootstrapPage(
    actionButton(ns("click"), "CONSOLE")
  )
}

#' @export
server <- function(id) {
  
  box::use(
    
    shiny
    [ moduleServer, observeEvent, ],
    
  )
  
  moduleServer(id, function(input, output, session) {
    
    observeEvent(
      input$click, {
        browser()
      })
  })
}