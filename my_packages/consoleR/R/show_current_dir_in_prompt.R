#' @export
show_current_dir_in_prompt <- function(logical = TRUE) {

  if (logical) {

    the$manager <- taskCallbackManager()
    the$manager$add(prompt_handler_fn, name = "promptHandler")

  } else {

    if ( !is.null(the$manager$callbacks()$promptHandler)) {
      the$manager$remove("promptHandler")
    }
  }
  invisible()
}


prompt_handler_fn <-  function(expr, value, ok, visible) {

      options(prompt = get_prompt())
      TRUE
}

get_prompt <- function() {

  location <- NULL
  if ( !is.null(getOption("consoleR_server_name"))) {
    location <- paste0(" @ ", getOption("consoleR_server_name"), " ")
  }
  if (is.null(location)) location <- " "

  paste0(basename(getwd()), location, "> ")
}
