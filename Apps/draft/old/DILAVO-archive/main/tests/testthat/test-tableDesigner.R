setup_ovalide_data <- function() {
  library(ovalide)
  library(ovalideTableDesigner)
  library(shiny)
  library(tidyverse)
}

setup_ovalide_data <- purrr::quietly(setup_ovalide_data)

testApp <- function() {
  ui <- fluidPage(
    fluidRow(
      shiny::column(4, 
                    shiny::selectInput("champ_select", "Choisir champ",
                                       choices = c("mco", "psy", "ssr", "had"))
      ),
      shiny::column(4, 
                    shiny::selectInput("statut_select", "Choisir statut",
                                       choices = c("dgf", "oqn"))
      ),
      shiny::column(4, 
                    shiny::selectInput("table_select", "Choisir table",
                                       choices = NULL)
      )
    ),
    tableDesignerUI("designer", debug = TRUE)
  )

  server <- function(input, output, session) {

    nature <- reactive({
      ovalide::nature(input$champ_select, input$statut_select)
    })
    
    observe({
      req(nature)
      ovalide::load_ovalide_tables(nature())
      shiny::updateSelectInput(
        session,
        "table_select",
        choices = names(ovalide::ovalide_tables(nature())))
    })
    
    table_name <- reactive({
      input$table_select
    })
    
    
    tableDesignerServer("designer", table_name, nature)
  }

  shinyApp(ui, server)
}

## interactive tests ######
if (interactive()) {
  setup_ovalide_data()


  # sink("log.txt")

  print("-------------------------------------------------------")
  print(paste0("Starting app @ ", Sys.time()))
  print("-------------------------------------------------------")

  testApp()
}
