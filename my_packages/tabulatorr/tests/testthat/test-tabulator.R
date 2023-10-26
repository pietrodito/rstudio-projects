{
  load_all()
  library(shiny)
  enrich_minimal_server             <- function(input) {

  }
  minimal_shiny_ui_server_GlobalEnv <- function() {

    ui <<- shiny::fluidPage(
      tabulatorOutput("table", height = NULL)
    )

    server <<- function(input, output, session) {

      output$table <- renderTabulator({
        tabulator(
          tibble::tribble(
            ~ "This", ~ "is",  ~ "a", ~ "test",
            1       , 2     ,  3    , 4,
            5       , 6     ,  7    , 8
          ),
          autoColumns = TRUE
        )
      })

      enrich_minimal_server(input)
    }
  }
  run <- function(fun) if(sys.nframe() == 1) do.call(fun, list())
  options(viewer = NULL)
}


simple_example          <- function() {
  tabulator(mtcars, autoColumns = TRUE)
}; run(simple_example)
example_with_parameters <- function() {
  tabulator(mtcars,
            height = FALSE,
            columns = list(
              list(title = "MPG", field = "mpg"),
              list(title = "CYL", field = "cyl")
            ))
}; run(example_with_parameters)

shiny_example    <- function() {
  minimal_shiny_ui_server_GlobalEnv()
  shinyApp(ui, server,
           options = list(launch.browser = T))
}; run(shiny_example)
module_example   <- function() {

  tabUI <- function(id) {
    ns <- NS(id)
    tagList(
      tabulatorOutput(ns("tab"), height = NULL)
    )
  }

  tabServer <- function(id) {
    moduleServer(
      id,
      function(input, output, session) {
        output$tab <- renderTabulator(
          tabulator(mtcars,
                    layout = "fitColumns",
                    autoColumns = TRUE)
        )
      }
    )
  }

  ui <- fluidPage(
    tabUI("tab")
  )

  server <- function(input, output, session) {
    tabServer("tab")
  }

  shinyApp(ui, server,
           options = list(launch.browser = T))
}; run(module_example)
cell_click_event <- function() {
  enrich_minimal_server <<- function(input) {

    observeEvent(input$table_cell_clicked, {
      req(input$table_cell_clicked)
      str(input$table_cell_clicked)
    })

  }
  minimal_shiny_ui_server_GlobalEnv()
  shinyApp(ui, server,
           options = list(launch.browser = T))
}; run(cell_click_event)
grouped_cols     <- function() {
  minimal_shiny_ui_server_GlobalEnv()

  server <- function(input, output, session) {
    output$table <- renderTabulator({
      tabulator(
        tibble::tribble(
          ~ "This", ~ "is",  ~ "a", ~ "test",
          1       , 2     ,  3    , 4,
          5       , 6     ,  7    , 8
        ),
        height = FALSE,
        columns = list(
          list(title = "A",
               columns = list(
                 list(title = "THIS", field = "This"),
                 list(title = "IS", field = "is"))),
          list(title = "B",
               columns = list(
                 list(title = "A", field = "a"),
                 list(title = "TEST", field = "test")))
        )
      )
    })
 }

  shinyApp(ui, server,
           options = list(launch.browser = T))
}; run(grouped_cols)

cell_context_menu <- function() {
  minimal_shiny_ui_server_GlobalEnv()

  server <- function(input, output, session) {

    output$table <- renderTabulator({
      tabulator(
        mtcars,
        columns = list(list(title = "MPG", field = "mpg")),
        cellContextMenuItems  = letters[1:3]
        )
    })

    observeEvent(input$table_context_menu_a, {
      req(input$table_context_menu_a)
      str(input$table_context_menu_a)
    })
  }

  shinyApp(ui, server,
           options = list(launch.browser = T))
}; run(cell_context_menu)
cell_context_menu_with_autoColumns <- function() {
  minimal_shiny_ui_server_GlobalEnv()

  server <- function(input, output, session) {

    output$table <- renderTabulator({
      tabulator(
        mtcars,
        autoColumns = TRUE,
        headerMenuItems = letters[24:26],
        cellContextMenuItems  = letters[1:3]
        )
    })

    observeEvent(input$table_context_menu_a, {
      req(input$table_context_menu_a)
      str(input$table_context_menu_a)
    })


    observeEvent(input$table_header_menu_x, {
      req(input$table_header_menu_x)
      str(input$table_header_menu_x)
    })
  }

  shinyApp(ui, server,
           options = list(launch.browser = T))
}; run(cell_context_menu_with_autoColumns)

reactive_value <- function() {

  ui <- fluidPage(
    selectInput("data", "Choose", c("mtcars", "faithful")),
    tabulatorOutput("table", height = NULL)
  )

  server <- function(input, output, session) {

    output$table <- renderTabulator({
      tabulator(get(input$data),
                layout = "fitColumns",
                autoColumns = TRUE)
    })
  }

  shinyApp(ui, server,
           options = list(launch.browser = T))
}; run(reactive_value)

detect_column_move <- function() {
  ui <- fluidPage(
    tabulatorOutput("table", height = NULL)
  )

  server <- function(input, output, session) {

    output$table <- renderTabulator({
      tabulator(mtcars,
                layout = "fitColumns",
                movableColumns = TRUE,
                autoColumns = TRUE)
    })

    observeEvent(input$table_column_moved, {
      req(input$table_column_moved)
      str(input$table_column_moved)
    })
  }

  shinyApp(ui, server,
           options = list(launch.browser = T))
}; run(detect_column_move)

rm(list = ls())
