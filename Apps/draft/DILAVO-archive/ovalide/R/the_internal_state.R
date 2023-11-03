the <- new.env(parent = emptyenv())

table_var <- "{nature$champ}_{nature$statut}_ovalide"

#' @export
ovalide_table <- function(nature, table_name) {
  ovalide_tables(nature)[[table_name]]
}

#' @export
ovalide_tables <- function(nature) {
  the[[glue::glue(table_var)]]
}

#' @export
set_ovalide_tables <- function(nature, value) {
  the[[glue::glue(table_var)]] <- value
}


score_var <- "{nature$champ}_{nature$statut}_scores"

#' @export
score <- function(nature) {
  the[[glue::glue(score_var)]]
}
#' @export
set_score <- function(nature, value) {
  the[[glue::glue(score_var)]] <- value
}
