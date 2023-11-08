# app/main.R

box::use(
  shiny[column, fluidPage, fluidRow, moduleServer, NS],
)

box::use(
  app/view/clicks,
  app/view/message,
)


#' @export
ui <- function(id) {
  ns <- NS(id)
  fluidPage(
    fluidRow(
      column(
        width = 6,
        clicks$ui(ns("clicks"))
      ),
      column(
        width = 6,
        message$ui(ns("message"))
      )
    )
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    clicks$server("clicks")
    message$server("message")
  })
}