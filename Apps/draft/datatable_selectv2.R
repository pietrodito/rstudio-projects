library(shiny)
library(DT)


ui <- fluidPage(
  DTOutput("table")
)


server <- function(input, output, session) {
  output$table <- renderDT({
    datatable(
      mtcars,
      options = list(
        dom = 't',
        initComplete = JS(js)
      )
    )
  })
}

shinyApp(ui, server, options = list(
  launch.browser = TRUE
))

