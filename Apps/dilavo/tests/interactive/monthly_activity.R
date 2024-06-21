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
             DTOutput(ns("cas")),
             ),
      column(6,
             plotOutput(ns("plot")),
      ),
      column(3,
             DTOutput(ns("cmd")),
             ),
    ),
    tableOutput(ns("previous_year")),
    tableOutput(ns("current_year")),
    plotOutput(ns("debug")),

  )
}

#' @export
server <- function(id) {

  box::use(

    app/logic/db_utils
    [ hospitals, ],

    app/logic/monthly_activity
    [ available_cmd_cas_finess, ghm_etab_period, graph_this_and_last_years,
      stays_last_year_at_this_point, stays_this_year, ],

    app/logic/nature_utils
    [ nature, ],

    dplyr
    [ filter, group_by, mutate, pull, select, summarise, ],

    tabulatorr
    [ renderTabulator, tabulator, ],
    
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
      ghms(ghm_etab_period(finess()))
      cas_list(data.frame(CAS = sort(unique(ghms()$cas))))
      cmd_list(data.frame(CMD = sort(unique(ghms()$cmd))))
      selected_cas((cas_list() |> pull())[input$cas_rows_selected])
      selected_cmd((cmd_list() |> pull())[input$cmd_rows_selected])
    })
    
  # output$update_logs_table <- renderTabulator(
  #   tabulator(
  #     db_update_logs_table(),
  #     autoColumns = TRUE,
  #     layout = "fitColumns"
  #   )
  # )

    js <- "
      function ( e, dt, node, config ) {
        dt.rows().deselect();
      }"

    dt_options <- list(
      dom = 'Bfrtip',
      buttons = list(
        list(
          extend = "collection",
          text   = "DESELECT",
          action = JS(js)
        )
      ),
      pageLength = 100
    )

    output$cmd <- renderDT(
      cmd_list(),
      extensions = c("Buttons", "Select"),
      rownames = FALSE,
      selection = list(
        mode = 'multiple',
        selected = 1:nrow(cmd_list())
      ),
      options = dt_options
    )

    output$cas <- renderDT(
      cas_list(),
      # extensions = c("Buttons"),
      rownames = FALSE,
      selection = list(
        mode = 'multiple',
        selected = 1:nrow(cas_list())
      ),
      # options = dt_options
    )

    output$debug <- renderPlot({
    })

    observeEvent(input$update_graph, {

      output$plot <- renderPlot({
        graph_this_and_last_years(nature("mco", "dgf"), finess(),
                                  selected_cmd(), selected_cas())
      })

    })

    output$previous_year <- renderTable({
      stays_last_year_at_this_point(nature("mco", "dgf"), finess())
    })

    output$current_year <- renderTable({
      stays_this_year(nature("mco", "dgf"), finess())
    })

  })

}
