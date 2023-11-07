# app/view/table_builder

ui <- function(id) {
  
  box::use(
    
    ../logic/nature_utils
    [ all_fields, all_status, nature, ],
    
    shiny
    [ actionButton, column, fluidPage, fluidRow, NS,
      selectInput, tagList, textInput, wellPanel, ], 
    
    tabulatorr
    [ tabulatorOutput, ],
  )
  
  ns <- NS(id)
  fluidPage(
    fluidRow(
      column(4, 
             wellPanel(
               fluidRow(
                 column(3, 
                        selectInput(ns("field"), "Champ", all_fields, "mco"),
                 ),
                 column(3, 
                        selectInput(ns("status"), "Statut", all_status, "dgf"),
                 ),
                 column(6, 
                        wellPanel(
                          fluidRow(
                            column(6, 
                                   actionButton(ns("new"), "Nouvelle table",
                                                width = "100%"),
                            ),
                            column(6, 
                                   actionButton(ns("rename"), "Renommer",
                                                width = "100%"),
                            ),
                          )
                        ),
                 ),
               ),
               selectInput(ns("table_name"), "Nom de la table", NULL),
               selectInput(ns("hospital"), "Établissement", NULL),
             )),
      column(4, 
             wellPanel(
               
               fluidRow(
                 column(3, actionButton(ns("undo"), "⟲ Undo", width = "100%")), 
                 column(3, actionButton(ns("redo"), "⟳ Redo", width = "100%")), 
                 column(6, actionButton(ns("save"),
                                        "💾 Sauvegarder", width = "100%") ), 
               ),
             )),
      column(4, 
             wellPanel(
               actionButton(ns("create_col"), "Créer une colonne"),
             )),
    ),
      fluidRow(
        column(4, 
               wellPanel(
                 actionButton(ns("new_one"), "new one"),
               )
        ),
        column(4, 
               wellPanel(
                 actionButton(ns("new_two"), "new two"),
               )
        )),
      fluidRow(
        wellPanel(
          tabulatorOutput(ns("table"))
        )
      )
  )
}

server <- function(id, table_name = NULL) {
  
  box::use(
    
    app/logic/db_utils
    [ hospitals, ],
    
    app/logic/nature_utils
    [ nature, ],
    
    app/logic/table_builder_utils
    [ build_details, ],
    
    shiny
    [ moduleServer, observe, req, updateSelectInput, updateTextInput, ],
    
    tabulatorr
    [ renderTabulator, tabulator, ],
  )
  
  moduleServer(
    id,
    function(input, output, session) {
      
      if(! is.null(table_name)) {
        updateTextInput(session, "table_name", value = table_name)
      }
      
      observe({
        req(input$field); req(input$status)
        nature <- nature(input$field, input$status)
        updateSelectInput(session, "hospital",
                          choices = hospitals(nature))
      })
      
      ## TODO create a Modal where you can create a new table
      ## choosing a name and if table is for all hospitals or one hospital
      ## Or leave a checkbox in the UI for that (better)
      
      
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