# app/view/builder_details/description

ui <- function(id) {
  
  box::use(
    glue
    [ glue, ],
    
    shiny
    [ actionButton, column, fluidRow, NS, tagList, tags,
      textOutput, wellPanel, ],
  )
  
  ns <- NS(id)
  ns_prefixe <- ns("")
  wellPanel(
    tags$script(glue('App.enterKeyReleased("{ns_prefixe}");')),
    fluidRow(
      column(2, actionButton(ns("edit"), "Décrire", width = '100%'),),
      column(10, textOutput(ns("description")),                     ),
    )
  )
}

server <- function(id, description, edit_mode) {
  
  
  box::use(
    shiny
    [ actionButton, is.reactive, isolate, modalDialog, modalButton,
      moduleServer, observe, observeEvent, reactive, reactiveValues,
      removeModal, renderText, showModal, tagList, textInput, ],
    
    shinyjs
    [ disable, enable, ],
    
  )
  
  moduleServer(
    id,
    function(input, output, session) {
      
      
      ns <- session$ns
      
      r <- reactiveValues()
      r$return_value <- NULL
      r$edit_mode <- isolate(edit_mode)
      
      output$description <- renderText(description())
      
      
      observe({
        browser()
        if(r$edit_mode) {
          enable("edit")
        } else {
          disable("edit")
        }
      })
      
      observeEvent(input$edit, {
        showModal(
          modalDialog(
            textInput(
              inputId = ns("description"),
              label = "Description",
              placeholder = "Décrivez la table"),
            footer = tagList(
              modalButton("Annuler")
            )
          )
        )
      })
      
      observeEvent(input$enterKeyReleased, {
        r$return_value <- input$description
        removeModal()
      })
      
      reactive(r$return_value)
    })
}