#' @export
create_all_connections <- function() {
  
  box::use(
    ./db_utils [ db_get_connection, ],
    
    ./log_utils [ log, ],
    
    ./nature_utils [ all_natures, suffixe, ],
    
    glue [ glue, ],
    
    purrr [ walk, ],
  )
  
  helper <- function(nature) {
    assign(glue("perm_conn_{suffixe(nature)}"),
           db_get_connection(nature),
           inherits = TRUE)
  }
  
  walk(all_natures, helper)
  
}

#' @export
extract_nature_from_sql_script <- function(filepath) {
  box::use(
    ./nature_utils
    [ nature, ],
    
    stringr
    [ str_extract, ],
    
  )
  
  preview_line <- grep("-- !preview", readLines(filepath), value = TRUE)
  
  field  <- str_extract(preview_line, "mco|had|psy|smr")
  status <- str_extract(preview_line, "dgf|oqn")
  
  nature(field, status)
}
