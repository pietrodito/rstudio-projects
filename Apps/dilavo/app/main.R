options(shiny.maxRequestSize = 100 * 1024^2)
interactive_tests <-  Sys.getenv("RHINO_PROD") != "true"

box::use(
  app/logic/ovalide_data_utils[ ovalide_data_path, ],
) 

updater_message_file <- ovalide_data_path(
  "messages/public_message.txt"
)

if (file.exists(updater_message_file)) {
  file.remove(updater_message_file)
}

app_ui <-  function(ns) { 
  
  box::use(
    shiny[ actionButton, fluidPage, h2, ],
  )
  
  fluidPage(
    h2("Bienvenue dans DILAVO !"),
    actionButton(ns("app_button"), "Un bouton !")
  )
}

app_server <- function(input, output, session) {
  
  notify_updater_messages() 
}

notify_updater_messages <- function() {
  
  box::use(
    app/logic/ovalide_data_utils[ ovalide_data_path, ],
    
    shiny[ observe, reactiveFileReader, req, showNotification,
    ],
  ) 
  
  readFunc <- function(filePath) {
    if(! file.exists(filePath)) {
      return(NULL)
    } else {
      lines <- readLines(filePath)
      paste0(lines, collapse = "\n")
    }
  }
  
  publicMessage <- reactiveFileReader(
    intervalMillis = 1000,
    session = NULL,
    filePath = updater_message_file,
    readFunc = readFunc
  )
  
 observe({
   req(publicMessage)
   if( ! is.null(publicMessage())) {
     showNotification(publicMessage(),
                      id = "only-one",
                      type = "message")
   }
 })
}

## DO NOT MODIFY lines below
## Add modules in the tests/interactive directory
## with just ui and server functions


#' @export
ui <- function(id) {
  
  ## DO NOT MODIFY

  
  box::use(
    
    bslib
    [ bs_theme, ],
    shiny
    [ fluidPage, NS, ],
  )
  
  ns <- NS(id)
  
  title <- "DILAVO"
  
  custom_theme <- bs_theme(
    version = 5,
    secondary = "#aaaaff7f",
  )
  
  
  adapt_ui_if_tests <- function() {
    
    fluidPage(
      theme = custom_theme,
      title = title,
      if (interactive_tests) {
        test_ui(ns)
      } else {
        app_ui(ns)
      }
    )
  }
  
  adapt_ui_if_tests()
}

#' @export
server <- function(id) {
  
  ## DO NOT MODIFY
  
  box::use(
    shiny[ moduleServer, ],
  )
  
  moduleServer(id, function(input, output, session) {
    
    app_server(input, output, session)
    
    if (interactive_tests) {
      test_server(input, output, session)
    }
  })
}

test_ui <-  function(ns) {
  ## DO NOT MODIFY
  
  box::use(
    purrr[ map, ],
    
    shiny[ a, tags, wellPanel, ],
    
    shiny.router[ route, route_link, router_ui],
  )
  
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
    wellPanel(menu),
    do.call(router_ui, router_ui_args)
  )
}

test_server <- function(input, output, session) {
  
  ## DO NOT MODIFY
  
  box::use(
    purrr[ map, ],
    shiny.router[ router_server,],
  )
  
  router_server()
  
  serve <- function(name) {
      get(name)[["server"]](name)
  }
  (
    interactive_test_module_names
    |> map(serve)
  )
}

setup_env_for_tests <- function(env) {
  
  box::use(
    
    fs[ dir_ls, ],
    
    stringr[ str_remove, ]
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
