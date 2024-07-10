#' @export
ui <- function(id) {

  box::use(

    app/logic/db_utils
    [ hospitals, ],

    app/logic/nature_utils
    [ nature, ],

    tabulatorr
    [ selectorUI, ],
    
    shiny
    [ actionButton, column, fluidPage, fluidRow, h1, NS, plotOutput,
      selectInput, selectizeInput, tableOutput, textOutput, ],
  )

  ns <- NS(id)
  fluidPage(
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
             selectorUI(ns("cas")),
             ),
      column(6,
             selectorUI(ns("plot")),
      ),
      column(3,
             selectorUI(ns("cmd")),
             ),
    ),
    selectorUI(ns("previous_year")),
    selectorUI(ns("current_year")),
    # textOutput(ns("debug")),

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
      selectorServer,
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
    available_cmd_cas <- reactiveVal()
    cas_list <- reactiveVal()
    cmd_list <- reactiveVal()
    ghms <- reactiveVal()
    selected_cas <- reactiveVal()
    selected_cmd <- reactiveVal()

   observe({
     finess(input$hospital |> str_sub(1, 9))
     if(finess() != "") {
       ghms(ghm_etab_period(finess()))
       cas_list(data.frame(CAS = sort(unique(ghms()$cas))))
       cmd_list(data.frame(CMD = sort(unique(ghms()$cmd))))
       selected_cas((cas_list() |> pull())[input$cas_rows_selected])
       selected_cmd((cmd_list() |> pull())[input$cmd_rows_selected])
     }
   })
   
   selectorServer(
     "cmd",
     cmd_list(),
     autoColumns = TRUE,
     layout = "fitColumns",
     selectableRows = TRUE,
     minHeight = "400px" 
   )
   
  #  output$cas <- renderTabulator(tabulator(cas_list()))


  # output$debug <- renderText({
  #   debug()
  # })

  #  observeEvent(input$update_graph, {
  #    output$plot <- renderPlot({
  #      graph_this_and_last_years(nature("mco", "dgf"), finess(),
  #                                selected_cmd(), selected_cas())
  #    })
  #  })

  #  output$previous_year <- renderTable({
  #    stays_last_year_at_this_point(nature("mco", "dgf"), finess())
  #  })

  #  output$current_year <- renderTable({
  #    stays_this_year(nature("mco", "dgf"), finess())
  #  })

  })
}
