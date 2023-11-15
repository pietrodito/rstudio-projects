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

server <- function(id, details, edit_mode) {
  
  box::use(
    shiny
    [ actionButton, is.reactive, is.reactivevalues, isolate, modalDialog,
      modalButton, moduleServer, observe, observeEvent, reactive, reactiveVal,
      removeModal, renderText, showModal, tagList, textInput, ],
    
    shinyjs
    [ disable, enable, ],
    
  )
  
  stopifnot(is.reactive(edit_mode))
  stopifnot(is.reactivevalues(details))
  
  
  moduleServer(
    id,
    function(input, output, session) {
      
      
      ns <- session$ns
      
      output$description <- renderText({
        details$description
      })
      
      return_value <- reactiveVal()
      
      
      observe({
        if(edit_mode()) {
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
        # browser()
        return_value(input$description)
        removeModal()
      })
      
      return_value
    })
}