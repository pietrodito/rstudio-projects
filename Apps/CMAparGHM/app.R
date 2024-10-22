library(stringr)
library(shiny)
library(readr)
library(dplyr)
library(tidyr)

ui <- fluidPage(
  textInput("ghm", "Tapez un GHM"),
  textOutput("debug"),
  textOutput("current_level"),
  fluidRow(
    column(4, textOutput("label2")),
    column(4, textOutput("label3")),
    column(4, textOutput("label4")),
  ),
  fluidRow(
    column(4, tableOutput("niv2")),
    column(4, tableOutput("niv3")),
    column(4, tableOutput("niv4")),
  )
  
)


server <- function(input, output, session) {
  
  level <- reactive({str_sub(input$ghm, start = -1L)})
  
  output$current_level <- renderText({
    paste0("Niveau du GHM: ", level())
    })
  displayable_df <- function(level) {
    if(level() >= level) return(tibble())
    target_ghm <- paste0(str_sub(input$ghm, end = -2L), level)
    (
      df
      |> filter(NIV == level, GRG_GHM == target_ghm)
      |> select(-NIV, - GRG_GHM)
      |> mutate(N = as.integer(N)) 
    )
  }
  df <- read_csv2("data/cma_par_ghm.csv")
  output$niv2 <- renderTable(displayable_df(2))
  output$niv3 <- renderTable(displayable_df(3))
  output$niv4 <- renderTable(displayable_df(4))
  output$label2 <- renderText("Niveau 2")
  output$label3 <- renderText("Niveau 3")
  output$label4 <- renderText("Niveau 4")
}

shinyApp(ui, server, options = list(
  launch.browser = TRUE
))