# app/logic/log_utils.R

#' @export
log <- function(..., list = F) {
  
  args <- list(...)
  
  logpath <- "/logs/log.txt"
  
  if(list) {
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

