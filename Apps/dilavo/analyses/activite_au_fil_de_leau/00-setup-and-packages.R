year <- 2024
month <- 8

## install.packages("packages/ovaliDB_0.0.0.9000.tar.gz")

library(readxl)
library(RPostgres)
library(ovaliDB)
library(tidyverse)
library(scales)
library(glue)

table_connection <- function(table_name, nature) {
  assign(table_name,
         dplyr::tbl(db(nature), table_name),
         .GlobalEnv)
}

tc <- function(table, champ, statut) {
  table <- rlang::quo_name(rlang::enquo(table))
  table_connection(table, nature(champ, statut))
}

(tableau_de_base <-
    read_excel(
      "analyses/activite_au_fil_de_leau/fichier_base_activite_mco.xlsx"))

((
  tableau_de_base
  |> select(finess, rs, statut, hprox)
) -> info_etablissement)

((
  info_etablissement
  |> filter(statut == "DGF", hprox == 0)
  |> pull(finess)
) -> etab_dgf_hors_hprox)

((
  info_etablissement
  |> filter(statut == "DGF", hprox == 1)
  |> pull(finess)
) -> etab_dgf_hprox)


