#' @export
nature <- function(champ = "mco", statut = "dgf") {
  structure(
    list(champ = champ,
         statut = statut),
    class = "ovalide_nature"
  )
}

data_save_dir_root <- "ovalide_data"

#' @export
data_save_dir <- NULL

produce_UseMethod <- function(generic_name) {
  assign(x = generic_name,
         value = function(x) {
           UseMethod(generic_name)
         },
         envir = parent.env(environment()))
}

generics <- c(
  "suffixe",
  "data_save_dir",

  "score_filepath",
  "no_score_data",

  "rds_filepath",
  "no_ovalide_data",

  "report_proper_column_names",
  "report_columns_to_select",
  "quality_table_name"
); purrr::walk(generics, produce_UseMethod)

suffixe.ovalide_nature <- function(nature) {
  stringr::str_c(nature$champ, "_", nature$statut)
}

#' @export
data_save_dir.ovalide_nature <- function(nature) {
  glue::glue("{data_save_dir_root}/{suffixe(nature)}")
}

score_filepath.ovalide_nature <- function(nature) {
  glue::glue("{data_save_dir(nature)}/score.csv")
}

no_score_data.ovalide_nature <- function(nature) {
  glue::glue(
    "There is no score tables data for {nature$champ} {nature$statut}")
}

rds_filepath.ovalide_nature <- function(nature) {
  glue::glue("{data_save_dir(nature)}/ovalide.rds")
}

no_ovalide_data.ovalide_nature <- function(nature) {
  glue::glue(
    "There is no ovalide data for {nature$champ} {nature$statut}")
}

report_proper_column_names.ovalide_nature <- function(nature) {
    get(glue::glue("proper_{nature$champ}_colonnes"))
}

report_columns_to_select.ovalide_nature <- function(nature) {
    get(glue::glue("colonnes_{nature$champ}_select"))
}

quality_table_name.ovalide_nature <- function(nature) {
  glue::glue("quality_{nature$champ}_table_name")
}
  