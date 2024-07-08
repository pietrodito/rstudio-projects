#' @export
selectorUI <- function(id) {
  ns <- NS(id)
  
  tabulator_style <- "color: #fff; background-color: #080; border-color: #fff"
  
  list(
    actionButton(ns("all") , label = "Tout" ), #, style = tabulator_style),
    actionButton(ns("none"), label = "Aucun"), #, style = tabulator_style),
    actionButton(ns("ok")  , label = "OK"   ), #, style = tabulator_style),
    tabulatorOutput(ns("table"))
  ) 
}
  
#' @export
selectorServer <- function(id, data, ...) {
  moduleServer(
    id,
    function(input, output, session) {
      output$table <- renderTabulator(
        tabulator(
          data,
          selectableRows = TRUE,
          ...
          )
      )
      
      observeEvent(input$all, {
        session$sendCustomMessage(
          type = 'select-all', message = ""
        )
      })
      
      observeEvent(input$none, {
        session$sendCustomMessage(
          type = 'deselect-all', message = ""
        )
      })
    }
  )
}