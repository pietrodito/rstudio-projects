library(shiny)
library(shinyjs)
library(DT)

ui <- fluidPage(
  useShinyjs(),
  DTOutput("table")
)


server <- function(input, output, session) {
  output$table <- renderDT({
    datatable(
      mtcars
    )
  })
  
  ### I need to know the `dataTableVariable`
  runjs("dataTableVariable.row(':eq(0)').select();")
}

shinyApp(ui, server, options = list(
  launch.browser = TRUE
))