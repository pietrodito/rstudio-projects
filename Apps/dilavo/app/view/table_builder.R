# app/view/table_builder

ui <- function(id) {
  
  box::use(
    shiny
    [ actionButton, NS, tagList, textInput, wellPanel, ], 
  )
  
  ns <- NS(id)
  wellPanel(
    textInput(ns("table_name"), "Nom de la table"),
    actionButton("create_col", "Créer une colonne"),
  )
}

server <- function(id) {
  
  box::use(
    shiny
    [ moduleServer, ],
  )
  
  moduleServer(
    id,
    function(input, output, session) {

    }
  )
}