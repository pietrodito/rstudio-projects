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

server <- function(id, description) {
  
  box::use(
    shiny
    [ actionButton, modalDialog, modalButton, moduleServer, observe,
      observeEvent, reactive, reactiveVal, removeModal, renderText, showModal,
      tagList, textInput, ],
  )
  
  moduleServer(
    id,
    function(input, output, session) {
      
     ns <- session$ns
     
     return_value <- reactiveVal()
      
     output$description <- renderText(description())
     
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
       return_value(input$description)
       removeModal()
     })
     
     return_value
    })
}