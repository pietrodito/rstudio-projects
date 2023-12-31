box::use(
  app/view/hidden,
  
  shiny
  [ bootstrapPage, moduleServer, NS, ],
  
)

#' @export
ui <- function(id) {
  bootstrapPage(
    hidden$ui("")
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    
  })
}
