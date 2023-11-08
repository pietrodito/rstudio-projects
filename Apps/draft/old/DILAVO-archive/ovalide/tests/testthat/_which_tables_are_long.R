library(ovalide)
library(purrr)

source("R/nature_class.R")

(champs <- c("mco", "had", "ssr", "psy"))
(statuts <- c("dgf", "oqn"))

(
  champs
  %>% map(function(.c) { map(statuts, function(.s) nature(.c, .s)) })
  %>% flatten()
) -> natures

(
  natures
  %>% walk(load_ovalide_tables)
)

(
  natures
  %>% map_chr(ovalide_tables)
) -> internal_names

show_table_and_name <- function(internal_name_nb, table_nb) {
  names <- names(the[[internal_names[[internal_name_nb]]]])
  cat("->", internal_names[internal_name_nb], "\n")
  cat("#", names[table_nb], "\n")
  table <- the[[internal_names[internal_name_nb]]][[table_nb]]
  table <- dplyr::filter(table, finess_comp == sample(table$finess_comp, 1))
  print(table)
}

show_table_and_name(1, 6)
