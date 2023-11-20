# ./other

#' @export
ui <- function(id) {
  
  box::use(
    
    shiny
    [ actionButton,  NS, wellPanel, ],
    
  )
  
  ns <- NS(id)
  wellPanel(
      actionButton(ns("mtcars"), "Mtcars", width = '100%')
    )
}

#' @export
server <- function(id, details, edit_mode) {
  
  box::use(
    datasets
    [ mtcars, ],
    
    shiny
    [ is.reactive, is.reactivevalues, modalButton, modalDialog, moduleServer,
      observe, observeEvent, reactive, reactiveVal, removeModal, renderText, req, showModal,
      tagList, textInput, ],
    
  )
  
  stopifnot(is.reactive(edit_mode))
  stopifnot(is.reactivevalues(details))
  
  moduleServer(
    id,
    function(input, output, session) {
      
      
      ns <- session$ns
      
      observeEvent(input$mtcars, {
        details$df <- mtcars
      })
      
      details
    })
}