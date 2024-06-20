#' @export
ui <- function(id) {
  
  box::use(
    
    app/logic/db_utils
    [ hospitals, ],
    
    app/logic/nature_utils 
    [ nature, ],
    
    DT
    [ DTOutput, ], 
    
    shiny
    [ bootstrapPage, DT, h1, NS, plotOutput, selectInput,
      selectizeInput, tableOutput, textOutput, ],
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
    DTOutput(ns("cmd")),
    DTOutput(ns("cas")),
    textOutput(ns("debug")),
    
    
  )
}

#' @export
server <- function(id) {
  
  box::use(
    
    app/logic/db_utils
    [ hospitals, ],
    
    app/logic/monthly_activity
    [ available_cmd_cas_finess, ghm_etab_periode, graph_this_and_last_years,
      stays_last_year_at_this_point, stays_this_year, ],
    
    app/logic/nature_utils 
    [ nature, ],
    
    DT
    [ renderDT, ], 
    
    shiny
    [  moduleServer, observe, observeEvent, reactiveVal, 
      renderPlot, renderTable,  renderText, ],
    
    stringr
    [ str_sub, ],
    
    
  )
  
  moduleServer(id, function(input, output, session) {
    
    finess <- reactiveVal()
    available_cmd_cas <- reactiveVal()
    
    observe({
      finess(input$hospital |> str_sub(1, 9))
      available_cmd_cas(available_cmd_cas_finess(finess()))
    })
    
    output$cmd <- renderDT({
      available_cmd_cas() |> select(cmd)
    })
    
    output$cas <- renderDT({
      available_cmd_cas() |> select(cas)
    })
    
    output$debug <- renderText({
      list_cmd_cas <- available_cmd_cas_finess(finess())
      purrr::exec(paste, list_cmd_cas)
    })
    
    output$plot <- renderPlot({
      graph_this_and_last_years(nature("mco", "dgf"), finess())
    })

    output$previous_year <- renderTable({
      stays_last_year_at_this_point(nature("mco", "dgf"), finess())
    })

    output$current_year <- renderTable({
      stays_this_year(nature("mco", "dgf"), finess())
    })
    
  })
    
}

