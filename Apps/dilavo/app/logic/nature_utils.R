# app/logic/nature_utils

#' @export
all_fields <- c("mco", "smr", "psy", "had")

#' @export
all_status <- c("dgf", "oqn")

#' @export
nature <- function(field = "mco", status = "dgf") {
  list(
    field = field,
    status = status
  )
}

#' @export
db_name <- function(nature) {
  nature |> suffixe() |> toupper()
}

data_save_dir_root <- "ovalide_data"

#' @export
suffixe <- function(nature) {
  box::use(  stringr [ str_c, ], )
  
  str_c(nature$field, "_", nature$status)
}

#' @export
data_save_dir <- function(nature) {
  box::use( glue [ glue, ], )
  
  glue("{data_save_dir_root}/{suffixe(nature)}")
}

#' @export
score_filepath <- function(nature) {
  box::use( glue [ glue, ], )
  
  glue("{data_save_dir(nature)}/score.csv")
}

#' @export
no_score_data <- function(nature) {
  box::use( glue [ glue, ], )
  
  glue(
    "There is no score tables data for {nature$field} {nature$status}")
}

#' @export
rds_filepath <- function(nature) {
  box::use( glue [ glue, ], )
  
  glue("{data_save_dir(nature)}/ovalide.rds")
}

#' @export
no_ovalide_data <- function(nature) {
  box::use( glue [ glue, ], )
  
  glue(
    "There is no ovalide data for {nature$field} {nature$status}")
}

#' @export
report_proper_column_names <- function(nature) {
  box::use( glue [ glue, ], )
  
  get(glue("proper_{nature$field}_colonnes"))
}

#' @export
report_columns_to_select <- function(nature) {
  box::use( glue [ glue, ], )
  
  get(glue("colonnes_{nature$field}_select"))
}

#' @export
quality_table_name <- function(nature) {
  box::use( glue [ glue, ], )
  
  glue("quality_{nature$field}_table_name")
}
