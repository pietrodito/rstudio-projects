# app/view/clicks.R

box::use(
  shiny[actionButton, div, moduleServer, NS, renderText, textOutput],
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  div(
    class = "clicks",
    actionButton(
      ns("click"),
      "Click me!"
    ),
    textOutput(ns("counter"))
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    output$counter <- renderText(input$click)
  })
}