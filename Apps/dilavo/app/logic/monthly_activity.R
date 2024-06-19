#' @export
stays_by_month <- function(nature, finess, previous_year = 1) {
  
  box::use(
    app/logic/db_utils
    [ db_instant_connect, most_recent_year, ],
    
    dplyr
    [ across, arrange, collect, everything,  filter,
      lead, mutate, select, tbl, where, ],
    
    tidyr
    [ pivot_wider, replace_na, ],
  )
  
  year <- as.integer(most_recent_year(nature)) - previous_year
  
  (
    tbl(db_instant_connect(nature), "t1d2rtp_2")
    |> collect()
    |> filter(ipe == finess,
              annee == year,
              `_name_`  %in% c("nbrsa", "cmd90")
    )
    |> select(annee, periode, moisor, `_name_`, col1)
    |> mutate(
      across(
        all_of(c("periode", "moisor", "col1")), as.integer))
    |> arrange(periode, moisor, desc(`_name_`))
    |> mutate(periode = as.character(periode))
    |> mutate(N = col1 - lead(col1))
    |> filter(`_name_` == "nbrsa")
    |> select(-col1, -`_name_`)
    |> pivot_wider(names_from = moisor, values_from = N)
    |> mutate(
      Total = as.integer(rowSums(across(where(is.numeric)), na.rm = T)))
    |> mutate(across(where(is.numeric), ~ replace_na(.x, 0)))
  )
}


#' @export
stays_last_year <- function(nature, finess) {
  stays_by_month(nature, finess, previous_year = 1)
}

#' @export
stays_this_year <- function(nature, finess) {
  stays_by_month(nature, finess, previous_year = 0)
}

#' @export
stays_last_year_at_this_point <- function(nature, finess) {
  
  box::use(
    dplyr
    [ across, mutate, where, ],
  )  
  
  last_year <- stays_last_year(nature, finess)
  this_year <- stays_this_year(nature, finess)
  dims <- dim(this_year)
  (
    last_year[1:(dims[1]), 1:(dims[2] - 1)]
    |> mutate(
      Total = as.integer(rowSums(across(where(is.numeric)), na.rm = T))
    )
  )
}


#' @export
graph_this_and_last_years <- function(nature, finess) {
  
  box::use(
    dplyr
    [ bind_rows, ],
  )
  
  last_year <- stays_last_year_at_this_point(nature, finess)
  this_year <- stays_this_year(nature, finess)
  
  browser()
  
  (
    bind_rows(last_year, this_year)
  )
  
}