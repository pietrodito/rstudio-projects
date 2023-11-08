library(shiny)
library(ovalide)
library(ovalideTableSelector)

ui <- fluidPage(
  fluidRow(
    column(3, 
           selectInput("finess", "Finess", c("620100057", "020000063"))),
    column(3,  selectInput("champ", "Champ", c("mco", "psy"))),
    column(3,  selectInput("statut", "Statut", c("dgf", "oqn"))),
    column(3,  selectInput("column_name", "Colonne", LETTERS))
  ),
  textOutput("table_selector_return"),
  ovalideTableSelectorUI("selector")
)

server <- function(input, output, session) {
  
  nature <- reactiveVal(NULL)
  column_name <- reactiveVal(NULL)
  finess <- reactiveVal(NULL)
  cell_value <- reactiveVal(10)
    
  observe({
    nature(ovalide::nature(input$champ, input$statut))
    column_name(input$column_name) 
    finess(input$finess)
  })
  
  table_selector_return <-  ovalideTableSelectorServer("selector",
                                                       finess,
                                                       nature,
                                                       column_name,
                                                       cell_value)
  output$table_selector_return <- renderText({
    as.character(table_selector_return())
  })
}

shinyApp(ui, server)