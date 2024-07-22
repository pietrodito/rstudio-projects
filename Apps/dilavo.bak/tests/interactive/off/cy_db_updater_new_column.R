box::use(
  
  DBI[
    dbListFields,
    dbListTables,
    dbRemoveTable,
  ],
  
  purrr[
    walk,
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
  
  utils[
    str,
  ],
  
)

box::use(
  
  app/logic/db_utils
  [ db_get_connection, db_reset, ],
  
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  bootstrapPage(
    actionButton(ns("reset"), "Reset PSY_OQN db"),
    actionButton(ns("list"), "list  tables"),
    actionButton(ns("cols"), "Display cols table t1q2chcr_3"),
    actionButton(ns("up1"), "Upload sample from Jan 2023"),
    actionButton(ns("up2"), "Upload sample from Jul 2023"),
    textOutput(ns("out"))
  )
}

#' @export
server <- function(id) {
  
  box::use(
    app/logic/ovalide_data_utils[ ovalide_data_path, ],
    
    app/logic/nature_utils[ nature, ],
  )
  
  moduleServer(id, function(input, output, session) {
    
    db <- db_get_connection(nature("psy", "oqn"))
      
    output$out <- renderText("Click buttons")
    
    observeEvent(input$reset, {
      db_reset(nature("psy", "oqn"))
    })
    
    observeEvent(input$list, {
      output$out <- renderText(dbListTables(db))
    })
    
    observeEvent(input$cols, {
      output$out <- renderText(dbListFields(db, "t1q2chcr_3"))
    })
    
    observeEvent(input$up1, {
      file.copy("tests/interactive/data/psy.oqn.2023.1.sample.zip",
                ovalide_data_path("upload"))
    })
    
    observeEvent(input$up2, {
      file.copy("tests/interactive/data/psy.oqn.2023.7.sample.zip",
                ovalide_data_path("upload"))
    })
  })
}