# app/view/dataset

ui <- function(id, filter = NULL) {
  box::use(
    shiny
    [ fluidPage, NS, selectInput, tagList, ],
  )
  
  ns <- NS(id)
    names <- ls("package:datasets")
    if (!is.null(filter)) {
      data <- lapply(names, get, "package:datasets")
      names <- names[vapply(data, filter, logical(1))]
    }
    
  tagList(
    selectInput(NS(id, "dataset"), "Pick a dataset", choices = names)
  )
} 

server <- function(id) {
  
  
  box::use(
    shiny
    [ moduleServer, reactive, ],
  )
  
  moduleServer(
    id,
    function(input, output, session) {
      ns <- session
      
      reactive(get(input$dataset, "package:datasets"))
    }
  )
}