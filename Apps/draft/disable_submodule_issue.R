library(shiny)
library(shinyjs)

# ____________________________________________
##############
# SUB MODULE #
##############

subUI <- function(id) {
  ns <- NS(id)
  tagList(
    useShinyjs(),
    actionButton(ns("click"), "CLICK!")
  )
}

subServer <- function(id, enabled) {
  # stopifnot(is.reactive(enabled))
  
  moduleServer(
    id,
    function(input, output, session) {
      observe({
        if(enabled) {
          enable("click")
        } else {
          disable("click")
        }
      })
    }
  )
}

# ____________________________________________
##############
# MAIN APP   #
##############
ui <- fluidPage(
  actionButton("toggle", "Toggle"),
  subUI("sub")
)

server <- function(input, output, session) {
  
  r <- reactiveValues()
  r$enabled <- TRUE
  
  subServer("sub", r$enabled)
  
  observeEvent(input$toggle, { r$enabled <- ! r$enabled })
}

shinyApp(ui, server, options = list(
  launch.browser = TRUE
))