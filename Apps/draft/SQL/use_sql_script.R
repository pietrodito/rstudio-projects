library(shiny)

ui <- fluidPage(
  actionButton("ok", "OK"),
  tableOutput("out")
)

server <- function(input, output, session) {
  
  box::use(
    ./nature_utils
    [ nature, ],
    
    ./db_utils
    [ db_instant_connect, ],
  )
  
  observeEvent(input$ok, {
    output$out <- renderTable(
      RPostgres::dbGetQuery(db_instant_connect(nature()),
                           statement = readr::read_file('test_db.sql'))
    )
  })
}

shinyApp(ui, server, options = list(
  launch.browser = TRUE
))

