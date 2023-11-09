box::use(
  shiny
  [ actionButton, fluidPage, moduleServer, tags, ], 
  
  shinyjs
  [ hidden, useShinyjs, ], 
)

ui <- function(id) {
  
  fluidPage(
    useShinyjs(),
    tags$h1("Hide away!"),
    actionButton("btn", "I'm trying...")
  )
}

server <- function(id, table_name = NULL) {
  moduleServer(id, function(input, output, session) {} )
}