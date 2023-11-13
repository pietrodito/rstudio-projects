box::use(
  
  app/view/dataset,
  app/view/inner,
  
  shiny
  [ bootstrapPage, div, moduleServer, NS, renderTable, renderText,
    tableOutput, textOutput, tags,  ],
  
  utils
  [ head, ], 
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  bootstrapPage(
    
    inner$ui(ns("desc")),
    
    textOutput(ns("out")),
    
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    inner$server("desc")
    
  })
}
