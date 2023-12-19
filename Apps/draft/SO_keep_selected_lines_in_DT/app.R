library(tidyverse)
library(shiny)
library(DT)

df <- tribble(~ town     , ~ year  , ~ value,
              "A"        , 2000    ,  80   ,
              "B"        , 2000    ,  90    ,
              "C"        , 2000     , 100    ,
              
              "A"        , 2001    ,  90    ,
              "B"        , 2001    ,  80    ,
              "C"        , 2001    ,  100   ,
              
              "A"        , 2002    ,  90    ,
              "B"        , 2002    ,  100    ,
              "C"        , 2002    ,  80   ,
              )

ui <- fluidPage(
  
  radioButtons(
    inputId = "year",
    label = "Choose a year",
    choices = unique(df$year)
  ),
  
  DTOutput("table", width = "400px"),
  
  h4("Click on first line and then change the year..."),
  
  textOutput("debug"),
  
)

server <- function(input, output, session) {
  
  out <- reactiveVal()
  
  observe(
    out(df |> filter(year == input$year) |> arrange(value))
  )
  
  selection <- NULL
  
  observe({
    selection <<- (out() |> pull(town))[input$table_rows_selected]
    output$debug <- renderText(selection)
  })
  
  output$table <- renderDT(
    out(),
    options = list(dom = 't', pageLength = 10000, ordering = FALSE),
    selection = list(mode = "multiple",
                     selected =
                       which((df |> arrange_at(input$col) |> pull(town)) %in% selection )
                     ),
  )
  
}

shinyApp(ui, server, options = list(
  launch.browser = TRUE
))