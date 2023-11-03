#' Load ovalide table stored data in `the` internal state
#' @return list of ovalide table dataframes
#' @export
load_ovalide_tables <- function(nature, force = FALSE) {

  if (is.null(ovalide_tables(nature)) || force) {
    rds_filepath <- rds_filepath(nature)
    set_ovalide_tables(nature, readr::read_rds(rds_filepath))
  }

  invisible()
}
