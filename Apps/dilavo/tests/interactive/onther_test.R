box::use(
  shiny[h3, moduleServer, NS],
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  h3("Other test")
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    print("Another test works!")
  })
}