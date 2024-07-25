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
upd_log <- function() { the$upd_log }

#' @export
db_update_logs <- function() {
  
  box::use(
    
    dplyr
    [ arrange, collect, mutate_at, rename_all, tbl, vars, ],
    
    lubridate
    [ day, hour, minute, month, year, ymd_hms, ],
    
  )
  
  readable_date <- function(x) {
    d <- ymd_hms(x)
    ifelse(is.na(x),
           "", 
           paste0(
             "Le ", day(d), "/", month(d), "/", year(d),
             " à ", hour(d), "h", minute(d)
           )
    )
  }
  
  # 2024-01-05T07:57:31Z
  
  (
    the$upd_log
    |> tbl("logs")
    |> collect()
    |> arrange(champ, statut)
    |> rename_all(function(x) {
      c("Champ", "Statut",
        "MàJ fichiers CSV", "MàJ tableau de bord", "MàJ Clé / Valeur")
    })
    |> mutate_at(vars(starts_with("MàJ")), readable_date)
  )
}



#' @export
db <- function(nature) {
  
  get(suffixe(nature))()
}