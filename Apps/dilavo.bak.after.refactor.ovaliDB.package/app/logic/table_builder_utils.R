box::use(
  ./undo_utils
  [ details, update_details, undo, redo ],
)

#' @export
build_details <- function(
    table_name         = NULL,
    description        = NULL ) {
  
  details(
    table_name         = table_name,
    description        = description
  )
}

#' @export
load_details <- function(table_name) {
}

#' @export
save_details <- function(details, table_name, nature) {
  box::use(
    ./db_utils
    [ , ],
  )
  
  
}

