#' @export
stays_by_month <- function(nature, finess, previous_year = 1) {
  
  box::use(
    app/logic/db_utils
    [ db_instant_connect, most_recent_year, ],
    
    dplyr
    [ across, arrange, collect, everything,  filter,
      lead, matches, mutate, select, tbl, where, ],
    
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
    |> select(-matches("NA"))
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
    [ bind_rows, mutate, ],
    
    ggplot2
    [ aes, annotate, expand_limits, geom_point, geom_smooth, ggplot, ],
  )
  
  last_year <- stays_last_year_at_this_point(nature, finess)
  this_year <- stays_this_year(nature, finess)
  
  
  evolution <- function(last_year, this_year) {
    last_month_total <- function(year) {
      year[nrow(year), "Total"]
    }
    
    (
      (last_month_total(this_year) - last_month_total(last_year))
      /
        last_month_total(this_year)
    ) -> result
    
    prefixe <- ifelse(result$Total >= 0, "+", "")
    paste0(prefixe, scales::percent_format(accuracy = .1)(result$Total))
    
  }
  
  
  (
    bind_rows(last_year, this_year)
    |> mutate(periode = as.integer(periode))
    |> ggplot(aes(periode, Total, color = annee))
    +  geom_point()
    +  geom_smooth(method = "lm")
    +  expand_limits(y = 0)
    +  annotate("text",
                x = - Inf,
                y = - Inf,
                label = evolution(last_year, this_year),
                vjust = -6,
                hjust = -6.5,
                size = 10)
  )
}

#' @export
ghm_etab_periode <- function(nature, finess, annee_, periode_) {
  
  box::use(
    app/logic/db_utils
    [ db_instant_connect, most_recent_year, ],
    
    dplyr
    [ collect, filter, group_by, mutate, select, summarise, tbl, ],
  )
  
  (
    tbl(db_instant_connect(nature), "t1d2cmr_1")
    |> filter(ipe == finess)
    |> mutate(cmd     = substr(racine, 1, 2),
              cas     = substr(racine, 3, 3),
              effh    = as.integer(effh),
              annee   = as.integer(annee),
              periode = as.integer(periode))
    |> filter(annee == annee_, periode == periode_)
    |> select(ipe, cmd, cas, effh) 
    |> collect()
    |> group_by(ipe, cmd, cas)
    |> summarise(N = sum(effh))
  )
  
}

#' @export
available_cmd_cas_finess <- function(finess) {
  
  box::use(
    app/logic/db_utils
    [ db_instant_connect, most_recent_year, ],
    
    app/logic/nature_utils 
    [ nature, ],
    
    dplyr
    [ collect, distinct, filter, group_by, mutate, select, summarise, tbl, ],
    
    purrr
    [ map, ],
  )
  
  (
    tbl(db_instant_connect(nature("mco", "dgf")), "t1d2cmr_1")
    |> filter(ipe == finess)
    |> mutate(cmd     = substr(racine, 1, 2),
              cas     = substr(racine, 3, 3))
    |> select(cmd, cas)
    |> distinct()
    |> collect()
  )
}

