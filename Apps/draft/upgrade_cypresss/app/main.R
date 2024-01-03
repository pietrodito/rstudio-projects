# app/main.R

box::use(
  shiny[h3, textOutput, renderText, fluidPage, fluidRow, moduleServer, NS],
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  fluidPage(fluidRow(h3(class = "title", textOutput(ns("header")))))
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    output$header <- renderText("Hello!")
  })
}