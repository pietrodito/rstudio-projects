dev_mode <- Sys.getenv("R_CONTEXT") == "dev"

box::use(
  shiny[
    a,
    fluidPage,
    div,
    h2,
    h3,
    moduleServer,
    NS,
    renderUI,
    tags,
    uiOutput,
    wellPanel
  ],
  
  shiny.router[
    route,
    route_link,
    router_ui,
    router_server
  ],
)

#' @export
ui <- function(id) {
  
  ns <- NS(id)
  
  title <- "DILAVO"
  
  adapt_ui_if_dev <- function() {
    
    if (dev_mode) {
      fluidPage(
        title = title,
        dev_ui(ns)
      )
    } else {
      fluidPage(
        title = title,
        root_ui(ns)
      )
    }
  }
  adapt_ui_if_dev()
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    root_server(input, output, session)
    
    if (dev_mode) {
      dev_server(input, output, session)
    }
  })
}

root_ui <-  function(ns) { 
  uiOutput(ns("message"))
}

root_server <- function(input, output, session) {
  
  output$message <- renderUI({
    div(
      style =
        "display: flex; justify-content: center; align-items: center; height: 100vh;",
      tags$h1(
        tags$a("Check out Rhino docs!",
               href = "https://appsilon.github.io/rhino/")
      )
    )
  })
}

dev_ui <-  function(ns) {
  
  box::use(purrr[map])
  
  (
    interactive_test_module_names
    |> map(function(name) {
      tags$li(a(class = "item",
                href = route_link(name),
                name))
    })
  ) -> module_name_item
  
  menu <- tags$ul(
    tags$li(a(class = "item",
              href = route_link("/"),
              "Application")),
    module_name_item
  )
  
  c_x_y <- function(x, y) { c(list(x), y) }
  
  (
    interactive_test_module_names
    |>map(function(name) {
      route(name, get(name)[["ui"]](ns(name)))
    })
    |> c_x_y(x = route("/", root_ui(ns)), y = _)
  ) -> router_ui_args
  
  
  list(
    do.call(router_ui, router_ui_args),
    wellPanel(menu)
  )
}

dev_server <- function(input, output, session) {
  router_server()
  
  serve <- function(name) {
      get(name)[["server"]](name)
  }
  (
    interactive_test_module_names
    |> purrr::map(serve)
  )
}


dev_hack <- function(env) {
  
  box::use(
    fs[
      dir_ls,
    ],
    
    stringr[
      str_remove,
    ]
  )
  
  box_use_chr <- function(string, env) {
    
    box::use(purrr[map])
    
    string_to_eval =  paste0("box::use(", string, ")")
    
    map(string, function(s) {
      eval(
        parse(text = string_to_eval), 
        envir = env
      )
    })
  }
  
  dir <- "tests/interactive/"
  
  (
    dir
    |> dir_ls()
    |> str_remove("\\.R$")
  ) ->  interactive_test_modules
  
  assign("interactive_test_modules",
         interactive_test_modules,
         envir = env)
  
  (
    interactive_test_modules
    |> str_remove(dir)
  ) -> interactive_test_module_names
  
  assign("interactive_test_module_names",
         interactive_test_module_names,
         envir = env)
  (
    interactive_test_modules
    |> box_use_chr(env = env)
  )
  
  
}

if (dev_mode) {
  dev_hack(environment())
}  
