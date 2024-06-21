tab <- data.frame(names = c("shelly","bob","jim","frank","jess"),
                  numbers = c(30,45,55,70,90))

library(shiny)
library(DT)

# Define UI ----
ui <- fluidPage(
  titlePanel("simpleApp"),
  sidebarLayout(
    sidebarPanel(),
    mainPanel (
      dataTableOutput("table"),
      dataTableOutput("select_table")
    )
  )

)

# Define server logic ----
server <- function(input, output) {

  output$table <- DT::renderDataTable(tab, selection='multiple')



  data3<- reactive({
    data.frame(tab[input$table_rows_selected,])})

  output$select_table<-DT::renderDataTable({
    if(nrow(data3()) > 0) {
      transform(data3(), numbers = numbers - 12)
    }
  })
}

# Run the app ----
shinyApp(ui = ui, server = server)
