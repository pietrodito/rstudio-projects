# app/view/table_builder

ui <- function(id) {
  
  box::use(
    shiny
    [ actionButton, NS, tagList, textInput, wellPanel, ], 
    
    tabulatorr
    [ tabulatorOutput, ],
  )
  
  ns <- NS(id)
  tagList(
    wellPanel(
      textInput(ns("table_name"), "Nom de la table"),
      actionButton(ns("create_col"), "Créer une colonne"),
    ),
    wellPanel(
      tabulatorOutput(ns("table"))
    )
  )
}

server <- function(id, table_name = NULL) {
  
  box::use(
    
    app/logic/table_builder_utils
    [ build_details, ],
    
    shiny
    [ moduleServer, updateTextInput, ],
    
    tabulatorr
    [ renderTabulator, tabulator, ],
  )
  
  moduleServer(
    id,
    function(input, output, session) {
      
      if(! is.null(table_name)) {
        updateTextInput(session, "table_name", value = table_name)
      }
      
      output$table <- renderTabulator(
        tabulator(
          data.frame(x = letters),
          autoColumns = TRUE,
          layout = "fitColumns"
        )
      )
    }
  )
}