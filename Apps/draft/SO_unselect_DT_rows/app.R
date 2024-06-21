library(shiny)
library(DT)


ui <- fluidPage(

  DTOutput("table"),
  textOutput("debug")

)

server <- function(input, output, session) {

  js <- "
    function ( e, dt, node, config ) {
      dt.rows().deselect();
    }
    "

  output$table <- renderDT(
    iris,
    extensions = c("Buttons", "Select"),
    # selection = "none",
    selection = list(
      mode = 'multiple',
      selected = 1:3
    ),
    options = list(
      "dom"     = "Bfrtip",
      "select"  = TRUE,
      "buttons" = list(
        list(
          "extend" = "collection",
          "text"   = "DESELECT",
          "action" = JS(js)
        )
      )
    )
  )


  output$debug <- renderText({
    input$table_rows_selected
  })

}

shinyApp(ui, server, options = list(
  launch.browser = TRUE
))
