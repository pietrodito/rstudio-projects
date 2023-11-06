#' @export
ui <- function(id) {
  
  box::use(
    
    shiny
    [ actionButton, bootstrapPage, NS, ],
  )
  
  ns <- NS(id)
  bootstrapPage(
    actionButton(ns("click"), "Year")
  )
}

#' @export
server <- function(id) {
  
  box::use(
    app/logic/db_utils
    [ list_of_hospitals, ],
    
    app/logic/nature_utils 
    [ nature, ],
    
    shiny
    [ moduleServer, observeEvent, ],
  )
  
  moduleServer(id, function(input, output, session) {
    
    observeEvent(
      input$click, {
        list_of_hospitals(nature())
      })
  })
}