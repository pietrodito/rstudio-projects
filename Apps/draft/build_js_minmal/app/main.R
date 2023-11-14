box::use(
  shiny[bootstrapPage, div, moduleServer, NS, renderUI, tags, uiOutput],
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  bootstrapPage(
    tags$button("Hello!", onclick = "App.sayHello()")
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {})
}
