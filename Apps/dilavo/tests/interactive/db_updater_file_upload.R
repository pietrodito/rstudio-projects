box::use(
  
  shiny[
    bootstrapPage,
    fileInput,
    moduleServer,
    NS,
    observe,
    req,
    showNotification,
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
  
  app/logic/ovalide_data_utils[
    ovalide_data_path
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
  
  box::use(
    app/view/ui_utils[ notify_please_wait, ],
  )
  
  moduleServer(id, function(input, output, session) {
     observe({
       req(input$upload)
       
       filename <-ovalide_data_path(
         paste0("upload/", input$upload$name))
       
       notify_please_wait()
       
       file.copy(input$upload$datapath, filename)
       
     })
  })
}