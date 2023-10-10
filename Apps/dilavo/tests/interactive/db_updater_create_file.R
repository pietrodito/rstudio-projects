box::use(
  
  shiny[
    actionButton,
    bootstrapPage,
    moduleServer,
    NS,
    observeEvent,
    radioButtons,
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
    radioButtons(ns("field"), "Field", c("mco", "smr", "had", "psy")),
    radioButtons(ns("status"), "Status", c("dgf", "oqn")),
    actionButton(ns("button"),
                 "Write file in ovalide_data ")
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
     
      db <- db_connect()
      
      observeEvent(input$button, {
        dir <-  paste0("/ovalide_data/", input$field, "_", input$status, "/")
        filepath <- paste0(dir, input$file_name)
        lockpath <- paste0(dir, "dilavo.lock")
        system(paste0("touch ", lockpath))
        system(paste0("touch ", filepath))
        Sys.sleep(1)
        write(letters, filepath)
        file.remove(lockpath)
      })
      
  })
}