library(tabulatorr)
library(shiny)

ui <- fluidPage(
  
  selectorUI("asdf")
  
)

server <- function(input, output, session) {
  
  selectorServer("asdf",
                 mtcars,
                 autoColumns = TRUE,
                 minHeight = "400px"
                 )
  
}

shinyApp(ui, server, options = list(
  launch.browser = TRUE
))
