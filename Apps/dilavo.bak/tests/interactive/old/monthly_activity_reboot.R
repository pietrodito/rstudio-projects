#' @export
ui <- function(id) {
  
  box::use(
    
    app/logic/db_utils
    [ hospitals, ],

    app/logic/nature_utils
    [ nature, ],

    tabulatorr
    [ tabulatorOutput, ],
    
    DT
    [ DTOutput, ],

 shiny
    [ actionButton, column, fluidPage, fluidRow, h1, NS, plotOutput,
      selectInput, selectizeInput, tableOutput, textOutput, ],
  )
  
  ns <- NS(id)
  fluidPage(
    
    tabulatorOutput(ns("debug_table")),
    textOutput(ns("debug_text")),
    
    h1("Activité mensuelle des établissements"),
    fluidRow(
      column(4,
             selectInput(
               ns("hospital"),
               "Établissement :",
               hospitals(nature())
             )
      ),
      column(4,
             actionButton(
               ns("update_graph"),
               "Mise à jour graphique")
      ),
      column(4,
             actionButton(
               ns("unselect_all"),
               "Vider sélection")
      ),
    ),

    fluidRow(
      column(3,
             tabulatorOutput(ns("cas")),
             ),
      column(6,
             plotOutput(ns("plot")),
      ),
      column(3,
             tabulatorOutput(ns("cmd")),
             ),
    ),
    tabulatorOutput(ns("previous_year")),
    tabulatorOutput(ns("current_year")),
  
  )
}

#' @export
server <- function(id) {
  
  box::use(

    app/logic/db_utils
    [ hospitals, ],

    app/logic/monthly_activity_utils
    [ available_cmd_cas_finess, ghm_etab_period, graph_this_and_last_years,
      stays_last_year_at_this_point, stays_this_year, ],

    app/logic/nature_utils
    [ nature, ],

    dplyr
    [ filter, group_by, mutate, pull, select, summarise, ],

    tabulatorr
    [
      renderTabulator, tabulator, ],
    
    DT
    [ renderDT, JS, ],
    
    ggplot2
    [ aes, expand_limits, geom_point, geom_smooth, ggplot, ],

    shiny
    [   moduleServer, observe, observeEvent, reactiveVal,
      renderPlot, renderTable,  renderText, ],

    stringr
    [ str_sub, ],
  )

  
  moduleServer(id, function(input, output, session) {
    
    finess <- reactiveVal()
    
    observe({
      finess(input$hospital |> str_sub(1, 9))
    })
    
    output$debug_text <- renderText({
      finess()
    })
    
    output$debug_table <- renderTabulator({
      tabulator(ghm_etab_period(finess()))
    })
    
  })
}