#' @export
ui <- function(id) {
  
  box::use(
    
    app/logic/db_utils
    [ hospitals, ],
    
    app/logic/nature_utils 
    [ nature, ],
    
    shiny
    [ bootstrapPage, h1, NS, plotOutput, selectInput,
      selectizeInput, tableOutput, ],
  )
  
  ns <- NS(id)
  bootstrapPage(
    h1("Activité mensuelle des établissements"),
    selectInput(
      ns("hospital"),
      "Établissement :",
      hospitals(nature())
    ),
    plotOutput(ns("plot")),
    tableOutput(ns("previous_year")),
    tableOutput(ns("current_year")),
    tableOutput(ns("debug")),
    
  )
}

#' @export
server <- function(id) {
  
  box::use(
    
    app/logic/db_utils
    [ hospitals, ],
    
    app/logic/monthly_activity
    [ graph_this_and_last_years, stays_last_year_at_this_point,
      stays_this_year, ],
    
    app/logic/nature_utils 
    [ nature, ],
    
    shiny
    [  moduleServer, observeEvent, reactiveVal, renderPlot, renderTable, ],
    
    stringr
    [ str_sub, ],
    
    
  )
  
  moduleServer(id, function(input, output, session) {
    
    output$plot <- renderPlot({

      finess <- input$hospital |> str_sub(1, 9)
      graph_this_and_last_years(nature("mco", "dgf"), finess)
    })
    
    output$previous_year <- renderTable({
      finess <- input$hospital |> str_sub(1, 9)
      stays_last_year_at_this_point(nature("mco", "dgf"), finess)
    })
    
    output$current_year <- renderTable({
      finess <- input$hospital |> str_sub(1, 9)
      stays_this_year(nature("mco", "dgf"), finess)
    })
  })
  
}

