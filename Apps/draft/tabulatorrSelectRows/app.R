library(shiny)
library(tabulatorr)

ui <- fluidPage(
  textOutput("debug"),
  tabulatorOutput("x")
)

server <- function(input, output, session) {
  
  output$debug <- renderText({
    debug()
  })
  
  output$x <- renderTabulator(
    tabulator(
      mtcars,
      # autoColumns = TRUE,
      # layout = "fitColumns",
      # height = "100%",
      # selectableRows = TRUE
    )
  )
}

shinyApp(ui, server, options = list(
  # launch.browser = TRUE
))