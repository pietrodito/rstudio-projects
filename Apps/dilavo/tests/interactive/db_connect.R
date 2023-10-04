box::use(
  shiny[
    actionButton,
    bootstrapPage,
    moduleServer,
    NS,
    observeEvent,
    renderText,
    textOutput,
  ]
)

box::use(
  app/logic/db_utils[
    db_connect,
  ]
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  bootstrapPage(
    actionButton(ns("button"), "Click me!"),
    textOutput(ns("log"))
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    observeEvent(input$button, {
      
      output$log <- renderText({
        "Trying to connect..."
      })
      
      db <- db_connect()
      
      if (is.null(db)) {
        output$log <- renderText({
          "Failed to connect."
        })
      } else {
        output$log <- renderText({
          paste(
            format(db),
            ": Connection established!"
          )
        })
      }
    })
    
    output$log <- renderText({
      "You can click the button to connect to DB!"
    })
  })
}