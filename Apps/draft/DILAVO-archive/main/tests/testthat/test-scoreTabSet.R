library(shiny)
library(ovalideScoreTabSet)

if (interactive()) {

  ui <- fluidPage(
    scoreTabSetUI("sts")
  )

  server <- function(input, output, session) {
    nature <- reactiveVal(ovalide::nature("mco", "dgf"))
    scoreTabSetServer("sts", nature)
  }

  
  shinyApp(ui, server)
}
