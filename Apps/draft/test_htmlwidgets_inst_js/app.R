library(shiny)
library(tabulatorr)

ui <- fluidPage(
  tags$h1("here"),
  tabulatorOutput("table", height = NULL)
)

server <- function(input, output, session) {
  output$table <- renderTabulator({
    tabulator( mtcare
             , autoColumns = TRUE
    )
  })
}

shinyApp(ui, server, options = list(
  launch.browser = TRUE
))
