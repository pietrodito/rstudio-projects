box::use(
  
  shiny[
    bootstrapPage,
    fileInput,
    moduleServer,
    NS,
    observe,
    req,
  ],
  
)

box::use(
  app/logic/db_utils[
    db_connect,
    dispatch_uploaded_file,
  ]
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  bootstrapPage(
    fileInput(ns("upload"), "Upload a file")
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
     observe({
       req(input$upload)
       
       filename <- paste0("/ovalide_data/upload/", input$upload$name)
       
       file.copy(input$upload$datapath, filename)
       
     })
  })
}