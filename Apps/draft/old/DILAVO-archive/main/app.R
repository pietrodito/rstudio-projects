## app.R ##
  
options(shiny.maxRequestSize=80*1024^2) 


library(shiny)
library(shinydashboard)
library(main)
library(ovalide)
library(cookies)

ui <-
  dashboardPage(
    dashboardHeader(title = "DILAVO"),
    
    dashboardSidebar(
      sidebarMenu(
        menuItem("Récap. score", tabName = "scores"),
        selectInput("champ",  "Champ",  c(MCO = "mco",
                                          SSR = "ssr",
                                          HAD = "had",
                                          PSY = "psy")),
        selectInput("statut", "Statut", c(DGF = "dgf",
                                          OQN = "oqn")),
        hr(),
        menuItem("MàJ. données", tabName = "update"),
        selectInput("data", "Données", c("Scores",
                                         "Tables",
                                         "Contacts")),
        hr()
      )
    ),
    dashboardBody(
      tags$head( 
        tags$style(HTML("[data-toggle] { font-size: 24px; }"))
      ),
      tabItems(
        tabItem(tabName = "scores", scoreTabSetUI("tabset")),
        tabItem(tabName = "update", dataUploaderUI("uploader"))
      )
    )
  ) |> add_cookie_handlers()

server <- function(input, output, session) {
  
  observeEvent( input$champ, {
    set_cookie_response(
      cookie_name = "champ",
      cookie_value = input$champ
    )
  })
  observeEvent( input$statut, {
    set_cookie_response(
      cookie_name = "statut",
      cookie_value = input$statut
    )
  })
  observeEvent( input$data, {
    set_cookie_response(
      cookie_name = "data",
      cookie_value = input$data
    )
  })
  observeEvent(
    get_cookie("champ"),
    updateSelectInput(session,
                      "champ",
                      selected = get_cookie("champ")),
    once = TRUE
  )
  observeEvent(
    get_cookie("statut"),
    updateSelectInput(session,
                      "statut",
                      selected = get_cookie("statut")),
    once = TRUE
  )
  observeEvent(
    get_cookie("data"),
    updateSelectInput(session,
                      "data",
                      selected = get_cookie("data")),
    once = TRUE
  )
  
  
  scoreTabSetServer("tabset", reactive(nature(input$champ, input$statut)))
  dataUploaderServer("uploader",
                     reactive(input$champ),
                     reactive(input$statut),
                     reactive(input$data))
}

shinyApp(ui, server,
         options = list( launch.browser = TRUE))