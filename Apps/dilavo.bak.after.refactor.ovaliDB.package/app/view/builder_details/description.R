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
      modal_is_on <- reactiveVal(FALSE)
      
      
      observe({
        if(edit_mode()) {
          enable("edit")
        } else {
          disable("edit")
        }
      })
      
      observeEvent(input$edit, {
        if(edit_mode()) {
          modal_is_on(TRUE)
          showModal(
            modalDialog(
              textInput(
                inputId = ns("description"),
                label = "Description",
                value = details$description,
                placeholder = "Décrivez la table"),
              footer = tagList(
                modalButton("Annuler")
              )
            )
          )
        }
      })
      
      observeEvent(input$enterKeyReleased, {
        if(modal_is_on()) {
          details$description <- input$description
          modal_is_on(FALSE)
          removeModal()
        }
      })
      
      details
    })
}