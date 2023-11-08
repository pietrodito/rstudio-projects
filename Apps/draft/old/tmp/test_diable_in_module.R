library(shiny)
library(shinyjs)


#Define ui
input_module_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    textInput(
      inputId = ns("input"),
      label = "Input:",
      value = "A"
    )
  )
}

#Define server logic 
input_module_server <- function(input, output, session) {
  
  #List of things to return for use in other modules
  return(input)
  
}


#Define ui
output_module_ui <- function(id){
  ns <- NS(id)
  
  tagList(
    useShinyjs(),
    textInput(inputId = ns("output"),
              label = "Output:", 
              value = ""
    )
  )
}

#Define server logic 
output_module_server <-
  function(input,
           output,
           session,
           module_input) {
    
    observe({
      
      output <- module_input$input
      updateTextInput(session, "output", value = output)
      disable(id = "output")
      
    })
  }


# Define UI
ui <- fluidPage(
  
  # Application title
  titlePanel("Demo"),
  
  # Sidebar 
  sidebarLayout(
    sidebarPanel(
      input_module_ui("input")
    ),
    
    mainPanel(
      output_module_ui("output")
    )
  )
)

# Define server logic 
server <- function(input, output, session) {
  
  callModule(input_module_server, "input")
  res <- callModule(input_module_server, "input")
  
  callModule(output_module_server, "output", res)
  
}

# Run the application 
shinyApp(ui = ui, server = server)
