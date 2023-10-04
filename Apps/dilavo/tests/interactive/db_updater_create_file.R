box::use(
  
  shiny[
    actionButton,
    bootstrapPage,
    moduleServer,
    NS,
    observeEvent,
    textInput,
  ],
  
)

box::use(
  app/logic/db_utils[
    db_connect,
  ]
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  bootstrapPage(
    textInput(ns("file_name"), "File name"),
    actionButton(ns("button"),
                 "Write file in ovalide_data ")
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
     
      db <- db_connect()
      
      observeEvent(input$button, {
        file <- paste0("/ovalide_data/", input$file_name)
        system(paste0("touch /ovalide_data/dilavo.lock"))
        system(paste0("touch ", file))
        Sys.sleep(3)
        write(letters, file)
        file.remove("/ovalide_data/dilavo.lock")
      })
      
  })
}