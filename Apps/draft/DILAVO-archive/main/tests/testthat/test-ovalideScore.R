library(shiny)
library(ovalideScore)

ui <- fluidPage(
  shiny::selectInput("champ", "Champ", choices = c("mco", "psy")),
  shiny::selectInput("statut", "Statut", choices = c("dgf", "oqn")),
  shiny::textOutput("out"),
  ovalideScoreUI("score")
)

server <- function(input, output, session) {
  
  nature <- reactiveVal(NULL)
  
  observe({
    nature(ovalide::nature(input$champ, input$statut))
  })
  
  out <- ovalideScoreServer("score", nature)
  
  output$out <- shiny::renderText({
    as.character(
      paste("Column nb."  , out$column_nb(), 
            "Column name" , out$column_name(),
            "Cell value"  , out$cell_value(),
            "Établissment", out$etablissement(),
            "FINESS"      , out$finess()
      )
    )
  })
}

shinyApp(ui, server)