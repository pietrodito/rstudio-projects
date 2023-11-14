# app/view/builder_details/description

ui <- function(id) {
  
  box::use(
    shiny
    [ actionButton, NS, tagList, tags, textOutput, ],
  )
  
  ns <- NS(id)
  tagList(
    tags$h2("Description"),
    textOutput(ns("description")),
    actionButton(ns("edit"), "Modifier"),
  )
}

server <- function(id, description) {
  
  box::use(
    shiny
    [ actionButton, modalDialog, modalButton, moduleServer, observe,
      observeEvent, reactive, renderText, showModal, tagList, textInput, ],
  )
  
  moduleServer(
    id,
    function(input, output, session) {
      
     ns <- session$ns
      
     output$description <- renderText(description)
     
     observeEvent(input$edit, {
       showModal(
         modalDialog(
           textInput(
             inputId = "desciption",
             label = "Description",
             placeholder = "Décrivez la table"),
           footer = tagList(
             modalButton("Annuler"),
             actionButton("ok", "OK")
           )
         )
       )
     })
     
     
    }
  )
}