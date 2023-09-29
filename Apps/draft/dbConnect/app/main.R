box::use(
  shiny[bootstrapPage, div, moduleServer, NS,
        observeEvent,
        renderText, tags, textOutput, actionButton],
)

box::use(
  app/logic/db_utils[connect_db],
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
    
    write("echo $USER:", "~/log.txt")
    write(system("echo $USER", intern = TRUE), "~/log.txt", append = T)
    
    observeEvent(input$button, {
      
      output$log <- renderText({
        "Trying to connect..."
      })
      
      if (is.null(connect_db())) {
        output$log <- renderText({
          "Failed to connect."
        })
      } else {
        output$log <- renderText({
          "Success!"
        })
      }
    })
    
    output$log <- renderText({
      "You can click the button to connect to DB!"
    })
  })
}
