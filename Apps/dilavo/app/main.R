interactive_tests <-  Sys.getenv("RHINO_PROD") != "true"

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

app_ui <-  function(ns) { 
  uiOutput(ns("message"))
}

app_server <- function(input, output, session) {
  
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

## DO NOT MODIFY lines below
## Add modules in the tests/interactive directory
## with just ui and server functions

#' @export
ui <- function(id) {
  
  ## DO NOT MODIFY
  
  ns <- NS(id)
  
  title <- "DILAVO"
  
  adapt_ui_if_tests <- function() {
    
    if (interactive_tests) {
      fluidPage(
        title = title,
        test_ui(ns)
      )
    } else {
      fluidPage(
        title = title,
        app_ui(ns)
      )
    }
  }
  adapt_ui_if_tests()
}

#' @export
server <- function(id) {
  
  ## DO NOT MODIFY
  
  moduleServer(id, function(input, output, session) {
    
    app_server(input, output, session)
    
    if (interactive_tests) {
      test_server(input, output, session)
    }
  })
}

test_ui <-  function(ns) {
  
  ## DO NOT MODIFY
  
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
  
  create_route_page <- function(name) {
      route(name, get(name)[["ui"]](ns(name)))
  }
  
  (
    interactive_test_module_names
    |> map(create_route_page)
    |> c_x_y(x = route("/", app_ui(ns)), y = _)
  ) -> router_ui_args
  
  
  list(
    do.call(router_ui, router_ui_args),
    wellPanel(menu)
  )
}

test_server <- function(input, output, session) {
  
  ## DO NOT MODIFY
  
  router_server()
  
  serve <- function(name) {
      get(name)[["server"]](name)
  }
  (
    interactive_test_module_names
    |> purrr::map(serve)
  )
}

setup_env_for_tests <- function(env) {
  
  box::use(
    fs[
      dir_ls,
    ],
    
    stringr[
      str_remove,
    ]
  )
  
  box_use_with_character <- function(string, env) {
    
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
  
  R_extension_pattern <- "\\.R$"
  
  (
    dir
    |> dir_ls(regexp = R_extension_pattern)
    |> str_remove(R_extension_pattern)
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
    |> box_use_with_character(env = env)
  )
  
  
}

if (interactive_tests) {
  setup_env_for_tests(environment())
}  
