library(shiny)
library(shiny.router)

root_page <- div(h2("Root page"))
other_page <- div(h3("Other page"))

ui <- fluidPage(
  title = "Router demo",
  router_ui(
    route("/", root_page),
    route("other", other_page)
  )
)

helper <- function(env) {
  router_server(env = env)
}

server <- function(input, output, session) {
  helper(environment())
}

shinyApp(ui, server)