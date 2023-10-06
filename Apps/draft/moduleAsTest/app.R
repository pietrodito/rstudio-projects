library(shiny)

testUI <- function(id) {
  ns <- NS(id)
  tagList(
    h1('test')
  )
}

testServer <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {
      print('some')
    }
  )
}

ui <- fluidPage(
  testUI("test")
)

server <- function(input, output, session) {
  testServer("test")
}

shinyApp(ui, server, options = list(
  launch.browser = TRUE
))