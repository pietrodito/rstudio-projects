# app/view/inner

box::use(
  ./description
)

ui <- function(id) {
  box::use(
    shiny
    [ tagList, NS, textOutput, actionButton, ],
  )
  
  ns <- NS(id)
  tagList(
    description$ui(ns("d")),
    textOutput(ns("out")),
    actionButton(ns("save"), "Save")
  )
}

server <- function(id) {
  
  
  box::use(
    shiny
    [ observeEvent, moduleServer, reactiveValues, renderText, ],
  )
  
  moduleServer(
    id,
    function(input, output, session) {
      ns <- session
      
      details <- reactiveValues()
      
      details$desc <- description$server("d", "some")
      output$out <- renderText(details$desc())
      
      
      observeEvent(input$save, {
        print(details$desc())
      })
      
      
    }
  )
}