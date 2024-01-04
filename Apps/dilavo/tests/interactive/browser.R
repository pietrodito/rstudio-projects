#' @export
ui <- function(id) {
  
  box::use(
    
    shiny
    [ actionButton, bootstrapPage, NS, tableOutput, ],
  )
  
  ns <- NS(id)
  bootstrapPage(
    actionButton(ns("click"), "CONSOLE")
  )
}

#' @export
server <- function(id) {
  
  box::use(
    app/logic/db_utils
    [ hospitals, ],
    
    app/logic/nature_utils 
    [ nature, ],
    
    shiny
    [ moduleServer, observeEvent, renderTable, ],
  )
  
  moduleServer(id, function(input, output, session) {
    
    observeEvent(
      input$click, {
        browser()
        })
  })
}