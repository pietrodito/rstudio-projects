library(readxl)
library(tidyverse)


sectorisation_psy <-
  read_excel("data-raw/data_sources/psy_communes_par_secteur.xlsx")


table(sectorisation_psy$`Etablissement de santé`)

(
  sectorisation_psy
  |> rename(ES = `Etablissement de santé`,
            COD_COM = `Code commune`)
  |> mutate(ES = ifelse(str_detect(ES, "Douai"), "CH DOUAI",
                 ifelse(str_detect(ES, "Lens"), "CH LENS",
                 ifelse(str_detect(ES, "Agglo"), "EPSM AGGLOM. LILLOISE",
                 ifelse(str_detect(ES, "EPSMDA"), "EPSM Aisne", ES)))))
) -> sectorisation_psy


usethis::use_data(sectorisation_psy, overwrite = TRUE)
