box::use(
  shiny[h3, moduleServer, NS],
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  h3("This is the latest test")
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    print("Test module server part works!")
  })
}