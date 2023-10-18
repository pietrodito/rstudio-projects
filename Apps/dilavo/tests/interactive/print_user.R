box::use(
  
  shiny[
    bootstrapPage,
    moduleServer,
    NS,
    renderText,
    textOutput,
  ],
)


#' @export
ui <- function(id) {
  ns <- NS(id)
  bootstrapPage(
    textOutput(ns("out"))
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    output$out <- renderText({
      paste(
        system("echo $USER", intern = T),
        system("id -u"     , intern = T),
        sep = "\n"
      )
    })
  })
}