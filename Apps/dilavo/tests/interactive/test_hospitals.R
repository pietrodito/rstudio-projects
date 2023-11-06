#' @export
ui <- function(id) {
  
  box::use(
    
    shiny
    [ actionButton, bootstrapPage, NS, textOutput, ],
  )
  
  ns <- NS(id)
  bootstrapPage(
    actionButton(ns("click"), "Year"),
    textOutput(ns("out"))
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
        output$out <- renderTable({
          hospitals(nature())
          })
      })
  })
}