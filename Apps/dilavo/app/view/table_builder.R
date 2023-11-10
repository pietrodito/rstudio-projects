# app/view/table_builder

ui <- function(id) {
  
  box::use(
    
    ../logic/nature_utils
    [ all_fields, all_status, nature, ],
    
    shiny
    [ actionButton, column, fluidPage, fluidRow, NS,
      selectInput, tagList, textInput, uiOutput, wellPanel, ], 
    
    shinyjs
    [ useShinyjs, ],
    
    tabulatorr
    [ tabulatorOutput, ],
  )
  
  ns <- NS(id)
  fluidPage(
    useShinyjs(),
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
                                   actionButton(ns("new_cancel"),
                                                "Nouvelle table",
                                                width = "100%"),
                            ),
                            column(6, 
                                   actionButton(ns("edit"), "Éditer",
                                                width = "100%"),
                            ),
                          )
                        ),
                 ),
               ),
               selectInput(ns("table_name"),
                           "Table utilisateur",
                           choices = NULL),
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
  
  ## TODO decide where to save new created tables
  
  box::use(
    
    app/logic/db_utils
    [ build_tables, hospitals, ],
    
    app/logic/nature_utils
    [ nature, ],
    
    app/logic/table_builder_utils
    [ build_details, ],
    
    shiny
    [ actionButton,  modalButton, modalDialog, moduleServer, observe,
      observeEvent, reactiveValues, removeModal, req, showModal, tagList,
      textInput, updateActionButton, updateSelectInput, updateTextInput, ],
    
    shinyjs
    [ info, disable, enable, hide, show, ],
    
    tabulatorr
    [ renderTabulator, tabulator, ],
  )
  
  moduleServer(
    id,
    function(input, output, session) {
      
      ns <- session$ns
      
      r <- reactiveValues()
      r$edit_mode <- FALSE
      
      observe({
        r$nature <- nature(input$field, input$status)
        r$build_tables <- build_tables(r$nature)
      })
      
      observe({
        updateSelectInput(
          session, "table_name",
          choices = build_tables(r$nature),
          selected = table_name)
      })
      
      observe({
        req(r$nature)
        updateSelectInput(session, "hospital",
                          choices = hospitals(r$nature))
      })
      
      observeEvent(input$new_cancel, {
        r$edit_mode <- ! r$edit_mode
        if(r$edit_mode) {
          updateActionButton(session, "new_cancel", "Annuler éditon")
          hide("edit", anim = TRUE, animType = "fade")
        } else {
          updateActionButton(session, "new_cancel", "Nouvelle table")
          show("edit", anim = TRUE, animType = "fade")
        }
      })
      
      observeEvent(input$create, {
        removeModal()
        r$new_name <- input$new_name
        r$edit_mode <- TRUE
      })
      
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