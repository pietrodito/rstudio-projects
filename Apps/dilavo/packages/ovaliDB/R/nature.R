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

helper_all_natures <- NULL
for(field in all_fields) {
  for(status in all_status) {
    helper_all_natures <- c(helper_all_natures, list(nature(field, status)))
  }
}

#' @export
all_natures <- helper_all_natures

#' @export
db_name <- function(nature) {
  nature |> suffixe() |> toupper()
}

data_save_dir_root <- "ovalide_data"

#' @export
suffixe <- function(nature) {
  paste0(nature$field, "_", nature$status)
}

#' @export
data_save_dir <- function(nature) {
  glue::glue("{data_save_dir_root}/{suffixe(nature)}")
}

#' @export
score_filepath <- function(nature) {
  glue::glue("{data_save_dir(nature)}/score.csv")
}

#' @export
no_score_data <- function(nature) {
  glue::glue(
    "There is no score tables data for {nature$field} {nature$status}")
}

#' @export
rds_filepath <- function(nature) {
  glue::glue("{data_save_dir(nature)}/ovalide.rds")
}

#' @export
no_ovalide_data <- function(nature) {
  glue::glue(
    "There is no ovalide data for {nature$field} {nature$status}")
}

#' @export
report_proper_column_names <- function(nature) {
  get(glue::glue("proper_{nature$field}_colonnes"))
}

#' @export
report_columns_to_select <- function(nature) {
  get(glue::glue("colonnes_{nature$field}_select"))
}

#' @export
quality_table_name <- function(nature) {
  glue::glue("quality_{nature$field}_table_name")
}