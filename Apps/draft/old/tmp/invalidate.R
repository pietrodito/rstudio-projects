library(shiny)

ui <- fluidPage(
  sliderInput("n", "Number of observations", 2, 1000, 500),
  uiOutput("countertext"),
  plotOutput("plot"),
  actionButton("invalidate", "Invalidate")
)

server <- function(input, output, session) {
  
  r <- reactiveValues()
  r$update_counter <- 0
  r$invalidate <- 0
  
  output$plot <- renderPlot({
    print(r$invalidate)
    isolate(r$update_counter <- r$update_counter + 1)
    hist(rnorm(isolate(input$n)))
  })

  output$countertext <- renderUI({
    h1(paste0("counter: ", r$update_counter))
  })
  
  observeEvent(
    input$n,
    r$update_counter <- 0
  )
  
  observeEvent(
    input$invalidate,
    r$invalidate <- r$invalidate + 1
  )
}

shinyApp(ui, server)
