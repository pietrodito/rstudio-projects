#' @export
ui <- function(id) {
  
  box::use(
    shiny
    [ bootstrapPage, fileInput, NS, ],
  )
  
  ns <- NS(id)
  bootstrapPage(
    fileInput(ns("upload"), "Upload a file")
  )
}

#' @export
server <- function(id) {
  
  box::use(
    app/logic/ovalide_data_utils
    [ ovalide_data_path ],
    
    app/view/ui_utils
    [ notify_please_wait, ],
    
    shiny
    [ moduleServer, observe, req, showNotification, ],
  )
  
  moduleServer(id, function(input, output, session) {
     observe({
       req(input$upload)
       
       filename <- ovalide_data_path(
         paste0("upload/", input$upload$name))
       
       notify_please_wait()
       
       file.copy(input$upload$datapath, filename)
       
     })
  })
}