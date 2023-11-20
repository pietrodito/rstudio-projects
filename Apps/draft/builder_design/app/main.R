box::use(
  
  app/view/description,
  app/view/other,
  app/view/df_detail,
  
  shiny[actionButton, fluidPage, moduleServer, NS, observe, observeEvent,
        reactive, reactiveValues, renderText, renderTable, req, textOutput,
        tableOutput, wellPanel, ], 
  
  shinyjs
  [ useShinyjs, ],
  
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  fluidPage(
    useShinyjs(),
    wellPanel(
      actionButton(ns("save"), "Save"),
      actionButton(ns("edit"), "Edit"),
      textOutput(ns("debug1")),
      textOutput(ns("debug2")),
      tableOutput(ns("debugdf")),
    ),
    wellPanel(
      description$ui(ns("description")),
      other$ui(ns("other")),
      df_detail$ui(ns("df"))
    )
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    
    details <- reactiveValues()
    r <- reactiveValues()
    
    r$edit_mode <- FALSE
    
    output$debug1 <- renderText({
      details$description
    })
    
    output$debug2 <- renderText({
      details$other
    })
    
    details <-
      description$server(
        "description", details, reactive(r$edit_mode))
    
    details <-
      other$server(
        "other", details, reactive(r$edit_mode))
    
    details <-
      df_detail$server("df", details, reactive(r$edit_mode))
    
    output$debugdf <- renderTable({
      req(details$df)
      utils::head(details$df)
    })
    
    observeEvent(input$edit, {
      r$edit_mode <- ! r$edit_mode
    })
    
  })
}
