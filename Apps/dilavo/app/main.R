options(shiny.maxRequestSize = 100 * 1024^2)
interactive_tests <-  Sys.getenv("RHINO_PROD") != "true"

box::use(
  app/logic/ovalide_data_utils[ ovalide_data_path, ],
) 

updater_message_file <- ovalide_data_path( "messages/public_message.txt" )

app_ui <-  function(ns) { 
  
  box::use(
    tabulatorr
    [ tabulatorOutput, ],
    
    shiny
    [ actionButton, fluidPage, h2,  ],
  )
  
  fluidPage(
    h2("DILAVO"),
    tabulatorOutput(ns("update_logs_table"), height = 1000)
  )
}

app_server <- function(input, output, session) {
  
  say_hello()
  remove_public_message_file_if_exists()
  notify_updater_messages(output)
  render_update_logs_table(output)
}

render_update_logs_table <- function(output) {
  box::use(
    app/logic/db_utils
    [ db_update_logs_table, ],
    
    tabulatorr
    [ renderTabulator, tabulator, ],
  )
  
  output$update_logs_table <- renderTabulator(
    tabulator(
      db_update_logs_table(),
      autoColumns = TRUE,
      layout = "fitColumns"
    )
  )
}


notify_updater_messages <- function(output) {
  
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
    render_update_logs_table(output) 
   }
 })
}

say_hello <- function() {
  box::use(
    shiny
    [ showNotification, ],
  )
  showNotification("Bienvenue !",
                   id = "only-one",
                   type = "message")
}

remove_public_message_file_if_exists <- function() {
  if (file.exists(updater_message_file)) {
    file.remove(updater_message_file)
  }
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


