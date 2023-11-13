# app/view/builder_details/description

ui <- function(id) {
  
  box::use(
    shiny
    [ tagList, NS, textInput, ],
  )
  
  ns <- NS(id)
  tagList(
    textInput(
      inputId     = ns("description")     ,
      label       = "Description"         ,
      placeholder = "Decrivez cette table")
  )
}

server <- function(id, description) {
  
  
  box::use(
    shiny
    [ moduleServer, observe, reactive, updateTextInput, ],
  )
  
  moduleServer(
    id,
    function(input, output, session) {
      
      ns <- session$ns
      
      updateTextInput(session, "description", description)
     
      reactive(input$description)
    }
  )
}