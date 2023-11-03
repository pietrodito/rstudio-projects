#' Extract column codes from a csv score file
#'
#' @param csv_filepath the path of the csv file
#'
#' @return column codes vector with NA for the column without codes
#' @export
#'
#' @examples
#' extract_column_codes_from_score_file("score.csv", "ssr", "oqn")
extract_column_codes_from_score_file <- function(csv_filepath) {
  (
    csv_filepath
    %>% readr::read_csv2(show_col_types = FALSE)
    %>% pick_and_order_proper_columns()
    %>% colnames()
    %>% get_column_codes()
  )
}

get_column_codes <- function(column_names) {
  (
    column_names
    %>% stringr::str_extract("\\(.*\\)")
    %>% stringr::str_remove("score")
    %>% stringr::str_remove_all("[(|)]")
    %>% stringr::str_trim()
  )
}
