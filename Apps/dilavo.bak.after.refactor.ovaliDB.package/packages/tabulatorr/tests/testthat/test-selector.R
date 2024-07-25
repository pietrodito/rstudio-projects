library(tabulatorr)
library(shiny)

ui <- fluidPage(
  
  selectorUI("asdf"),
  actionButton("debug", "DEBUG")
  
)

server <- function(input, output, session) {
  
  selectorServer("asdf",
                 mtcars,
                 autoColumns = TRUE,
                 minHeight = "400px"
                 )
  
  observeEvent(input$asdf_row_selection_confirmed_data, {
     str(input$asdf_row_selection_changed_data)
     str(input$asdf_row_selection_changed_row_numbers)
   })
  
}

shinyApp(ui, server, options = list(
  launch.browser = TRUE
))
