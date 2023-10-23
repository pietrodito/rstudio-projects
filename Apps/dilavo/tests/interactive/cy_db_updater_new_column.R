box::use(
  
  DBI[
    dbListTables,
    dbRemoveTable,
  ],
  
  shiny[
    actionButton,
    textOutput,
    bootstrapPage,
    moduleServer,
    NS,
    observeEvent,
    renderText,
  ],
)

box::use(
  
  app/logic/db_utils[
    db_connect,
    dispatch_uploaded_file,
  ],
  
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  bootstrapPage(
    actionButton(ns("reset"), "Reset PSY_OQN db"),
    actionButton(ns("cols"), "Display cols table ???"),
    actionButton(ns("up1"), "Upload troncated Jan 2023"),
    actionButton(ns("up2"), "Upload troncated Jul 2023"),
    textOutput(ns("out"))
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    # db <- db_connect("PSY_OQN")
      
    output$out <- renderText("Click buttons")
    
    observeEvent(input$reset, {
      tables <- dbListTables(db)
      str(tables)
    })
  })
}