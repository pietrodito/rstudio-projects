box::use(
  
  DBI[
    dbWriteTable,
  ],
  
  shiny[
    actionButton,
    bootstrapPage,
    moduleServer,
    NS,
    observeEvent,
    renderTable,
    tableOutput,
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
    textInput(ns("table_name"), "Table name"),
    actionButton(ns("button"), "Create random table"),
    tableOutput(ns("log"))
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
     
      db <- db_connect()
      
      observeEvent(input$button, {
        col_names <- sample(LETTERS, size = 8)
        cols <- matrix(sample(letters,
                              size = 80,
                              replace = T),
                       ncol = 8)
        colnames(cols) <- col_names
        rdm_table <- as.data.frame(cols)
        output$log <- renderTable(rdm_table)
        dbWriteTable(db,
                     input$table_name,
                     rdm_table,
                     overwrite = T)
      })
      
  })
}