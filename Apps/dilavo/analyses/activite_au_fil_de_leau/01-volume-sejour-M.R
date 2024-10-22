source('analyses/activite_au_fil_de_leau/00-setup-and-packages.R')

substitue_year <- function(df, year_substitution) {
  if( ! is.na(year_substitution)) {
    mutate(df, annee = year_substitution)
  } else {
    df
  }
}

nbr_de_sejours <- function(statut, year, month, year_substitution = NA) {
  (
    tc(t1d2rtp_1, "mco", statut)
    |> filter(annee == year)
    |> filter(periode == month)
    |> filter(`_name_` %in% c("nbrsa0", "nbrsah0"))
    |> select(statut, finess_comp, `_name_`, col1, annee)
    |> mutate(finess_comp = str_sub(finess_comp, start = 2L))
    |> rename(finess = finess_comp, data = `_name_`, value = col1)
    |> select(-data)
    |> group_by(statut, finess, annee)
    |> summarise(N = sum(value))
    |> ungroup()
    |> collect()
  ) -> return_value
  substitue_year(return_value, year_substitution)
}

extraction_volume_sejour_M <- function(statut) {
  (
    bind_rows(
      nbr_de_sejours(statut, year, month, "YEAR"),
      nbr_de_sejours(statut, year - 1, month, "LAST_YEAR"))
    |> pivot_wider(names_from = annee, values_from = N)
    |> collect()
    |> mutate(evolution = (YEAR - LAST_YEAR) / LAST_YEAR)
    |> mutate(across(everything(), ~ replace_na(.x, 0)))
    |> select(statut, finess, LAST_YEAR, YEAR, evolution)
  )
}

(volume_sejour_M <- bind_rows(
  extraction_volume_sejour_M("dgf"),
  extraction_volume_sejour_M("oqn")))


      