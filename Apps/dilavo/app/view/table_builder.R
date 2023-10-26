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

server <- function(id) {
  
  box::use(
    shiny
    [ moduleServer, ],
    
    tabulatorr
    [ renderTabulator, tabulator, ],
  )
  
  moduleServer(
    id,
    function(input, output, session) {
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