# ./description

#' @export
ui <- function(id) {
  
  box::use(
    glue
    [ glue, ],
    
    shiny
    [ actionButton, column, fluidRow, NS, textOutput, tags,
      wellPanel, ],
    
    shinyjs
    [ useShinyjs, ],
  )
  
  ns <- NS(id)
  ns_prefixe <- ns("")
  wellPanel(
     
    fluidRow(
      useShinyjs(),
      tags$script(glue('App.enterKeyReleased("{ns_prefixe}");')),
      column(2, actionButton(ns("edit"), "Décrire", width = '100%'),),
      column(10, textOutput(ns("description")),                     ),
    )
  )
  
}

#' @export
server <- function(id, details, edit_mode) {
  
  box::use(
    shiny
    [ is.reactive, is.reactivevalues, modalButton, modalDialog, moduleServer,
      observe, observeEvent, reactive, reactiveVal, removeModal, renderText, req, showModal,
      tagList, textInput, ],
    
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
              inputId = ns("read_description"),
              label = "Description",
              placeholder = "Décrivez la table"),
            footer = tagList(
              modalButton("Annuler")
            )
          )
        )
      })
      
      observeEvent(input$enterKeyReleased, {
        details$description <- input$read_description
        removeModal()
      })
      
      details
    })
}