#' @export
mco_dgf <- function() { the$mco_dgf }

#' @export
mco_oqn <- function() { the$mco_oqn }



#' @export
had_dgf <- function() { the$had_dgf }

#' @export
had_oqn <- function() { the$had_oqn }



#' @export
psy_dgf <- function() { the$psy_dgf }

#' @export
psy_oqn <- function() { the$psy_oqn }



#' @export
smr_dgf <- function() { the$smr_dgf }

#' @export
smr_oqn <- function() { the$smr_oqn }



#' @export
db_update_logs <- function() {
  box::use( dplyr [ tbl, ], )
  the$upd_log |> tbl("logs")
}



#' @export
db <- function(nature) {
  
  box::use(
    ../../app/logic/nature_utils
    [ suffixe,],
    
    purrr
    [ exec, ],
  )
  
  get(suffixe(nature)) |> exec()
}