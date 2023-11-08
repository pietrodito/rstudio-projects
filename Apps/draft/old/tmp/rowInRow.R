library(shiny)

ui <- fluidPage(
  fluidRow(
    column(6, 
           wellPanel(
             fluidRow(
               column(6,  selectInput("i", "LABEL", letters) ),
               column(6,  selectInput("i", "LABEL", letters) ),
             ),
           ),
    ),
    column(6, 
           wellPanel(
             fluidRow(
               column(6,  selectInput("i", "LABEL", letters) ),
               column(6,  selectInput("i", "LABEL", letters) ),
             ),
           ),
    ),
  )
)

server <- function(input, output, session) {

}

shinyApp(ui, server, options = list(
  launch.browser = TRUE
))