library(shiny)
library(shinyjs)
library(glue)

box::use(
  ./description
)

  

server <- function(input, output, session) {
  
  
}

shinyApp(ui, server, options = list(
  launch.browser = TRUE
))