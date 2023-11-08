ui <- function(id) {
  
  box::use(
    
    
    shiny
    [ actionButton, column, fluidPage, fluidRow, NS,
      selectInput, tagList, textInput, uiOutput, wellPanel, ], 
    
    shinyjs
    [ useShinyjs, ],
  )
  
  ns <- NS(id)
  fluidPage(
    wellPanel(
      actionButton(ns("new_cancel"), "Nouvelle table"),
      actionButton(ns("edit"), "Éditer")
    )
  )
}

server <- function(id, table_name = NULL) {
  
  
  box::use(
    
    shiny
    [ actionButton,  modalButton, modalDialog, moduleServer, observe,
      observeEvent, reactiveValues, removeModal, req, showModal, tagList,
      textInput, updateActionButton, updateSelectInput, updateTextInput, ],
    
    shinyjs
    [ disable, enable, ],
    
  )
  
  moduleServer(
    id,
    function(input, output, session) {
      
      ns <- session$ns
      
      r <- reactiveValues()
      r$edit_mode <- FALSE
      
      observeEvent(input$new_cancel, {
        r$edit_mode <- ! r$edit_mode
        if(r$edit_mode) {
          updateActionButton(session, "new_cancel", "Annuler éditon")
          disable("edit")
        } else {
          updateActionButton(session, "new_cancel", "Nouvelle table")
        }
      })
      
    }
  )
}