# app/logic/log_utils.R

#' @export
log <- function(..., unique_arg_is_list = F) {
  
  args <- list(...)
  
  logpath <- "/logs/log.txt"
  
  if(unique_arg_is_list) {
    values <- args[[1]] |> unlist()
    names <- names(values)
    mapply(
      function(name, val) {
        write(
          paste0(name, ": ", val),
          logpath,
          append = TRUE
        )
      },
      name = names, val = values
    )
  } else {
    write(
      x      = paste0(...),
      file   = logpath,
      append = TRUE
    )
  }
}

