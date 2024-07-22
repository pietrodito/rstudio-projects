#' @export
stays_by_month <- function(nature, finess, previous_year = 1) {
  
  box::use(
    app/logic/db_utils
    [ db_instant_connect, db_table_exists, most_recent_year, ],
    
    dplyr
    [ across, arrange, collect, everything,  filter,
      lead, matches, mutate, select, tbl, where, ],
    
    tidyr
    [ pivot_wider, replace_na, ],
  )
  
  year <- as.integer(most_recent_year(nature)) - previous_year
  
  if (db_table_exists(nature, "t1d2rtp_2")) {
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
  } else {
    NULL
  }
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
  if(! is.null(this_year)) {
    dims <- dim(this_year)
    (
      last_year[1:(dims[1]), 1:(dims[2] - 1)]
      |> mutate(
        Total = as.integer(rowSums(across(where(is.numeric)), na.rm = T))
      )
    )
  } else {
    NULL
  }
}

#' @export
graph_this_and_last_years <- function(nature, finess,
                                      selected_cmd, selected_cas) {
  
  box::use(
    app/logic/db_utils
    [  most_recent_year, most_recent_period, ],
    
    app/logic/nature_utils
    [ nature, ],
    
    dplyr
    [ bind_rows, filter, group_by, mutate, pull, summarise, ],
    
    ggplot2
    [ aes, annotate, expand_limits, geom_point, geom_smooth, ggplot, ],
  )
  
  last_year <- ghm_etab_year_period(finess,
                                    as.character(as.integer(
                                      most_recent_year(nature())) - 1), 
                                    most_recent_period(nature()))
  this_year <- ghm_etab_year_period(finess,
                                    most_recent_year(nature()),
                                    most_recent_period(nature()))
  
  
  evolution <- function(last_year, this_year) {
    last_month_total <- function(year) {
      
      the_period <- most_recent_period(nature()) |> as.integer()
      
      (
        year
        |> filter(periode == the_period)
        |> filter(cmd %in% selected_cmd)
        |> filter(cas %in% selected_cas)
        |> group_by(annee, periode)
        |> summarise(N = sum(N))
        |> pull(N)
      )
    }
    
    
    (
      (last_month_total(this_year) - last_month_total(last_year))
      /
        last_month_total(last_year)
    ) -> result
    
    prefixe <- ifelse(result >= 0, "+", "")
    paste0(prefixe, scales::percent_format(accuracy = .1)(result))
    
  }
  
  
  (
    bind_rows(last_year, this_year)
    |> mutate(periode = as.integer(periode))
    |> filter(cmd %in% selected_cmd)
    |> filter(cas %in% selected_cas)
    |> mutate(annee = as.character(annee))
    |> group_by(annee, periode)
    |> summarise(N = sum(N))
    |> ggplot(aes(periode, N, color = annee))
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

ghm_etab_year_period <- function(finess, year, period) {
  box::use(
    app/logic/db_utils
    [ db_instant_connect, db_table_exists, ],
    
    app/logic/nature_utils
    [ nature, ],
    
    dplyr
    [ collect, filter, group_by, mutate, select, summarise, tbl, ],
  )
  
  (
       db_table_exists(nature(), "t1d2cmr_1")
    && !is.null(year)
    && !is.null(period)
  ) -> possible
  
  if (possible) {
    (
      tbl(db_instant_connect(nature()), "t1d2cmr_1")
      |> filter(ipe == finess)
      |> mutate(cmd     = substr(racine, 1, 2),
                cas     = substr(racine, 3, 3),
                effh    = as.integer(effh),
                annee   = as.integer(annee),
                periode = as.integer(periode))
      |> filter(annee == year, periode <= period)
      |> select(annee, periode, cmd, cas, effh)
      |> collect()
      |> group_by(annee, periode, cmd, cas)
      |> summarise(N = sum(effh))
    )
  } else {
    NULL
  }
}

#' @export
ghm_etab_period <- function(finess) {
  box::use(
    app/logic/db_utils
    [ most_recent_year, most_recent_period, ],
    
    app/logic/nature_utils
    [ nature, ],
    
    dplyr
    [ bind_rows, ],
  )
  
  bind_rows(
    ghm_etab_year_period(finess,
                         as.character(as.integer(
                           most_recent_year(nature())) - 1),
                         most_recent_period(nature()))
    ,
    ghm_etab_year_period(finess,
                         most_recent_year(nature()),
                         most_recent_period(nature()))
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
    |> map(unique)
  )
}
