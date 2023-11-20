# ./description

#' @export
ui <- function(id) {
  
  # ns <- NS(id)
  # ns_prefixe <- ns("")
  # wellPanel(
  #   fluidRow(
  #     column(2, actionButton(ns("edit"), "Décrire", width = '100%'),),
  #     column(10, textOutput(ns("description")),                     ),
  #   )
  # )
  
  tagList()
}

#' @export
server <- function(id, details, edit_mode) {
  
  
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
        return_value(input$description)
        removeModal()
      })
      
      return_value
    })
}