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
  ],
  
  app/logic/log_utils[
    log,
  ],
  
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
       
       if(Sys.getenv("RUN_IN_DOCKER") == "YES") {
         parent_dir <- "/"
       } else {
         parent_dir <- ""
       }
       
       filename <- paste0(parent_dir,
                          "ovalide_data/upload/", input$upload$name)
       
       
       file.copy(input$upload$datapath, filename)
       
     })
  })
}