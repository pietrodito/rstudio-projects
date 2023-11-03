#' Load saved score
#' @export
load_score <- function(nature) {
   set_score(nature, readr::read_csv(score_filepath(nature),
                                     show_col_types = FALSE))
}
