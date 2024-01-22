library(tidyverse)

(psy <- hdfmaps::sectorisation_psy)
(tas <- hdfmaps::découpage_TAS)


(
  psy
  |> left_join(tas, by = c("COD_COM" = "COM23_CODE"))
  |> select(ES,
            Secteur,
            pmsi20_code,
            PMSI20_LIB_COURT,
            PMSI20_LIB)
  |> unique()
) -> sectorisation_psy

## J'ai un souci avec la sectorisation PSY :

# Je souhaite savoir si je peux relier un code commune PMSI à 
# un seul établissement adulte et enfant ?
# Réponse = NON
# Preuve : le code commune 59C05

(
  sectorisation_psy
  |> filter(pmsi20_code == "59C05")
)

# renvoie :

# A tibble: 8 × 5
# `Etablissement de santé`    Secteur pmsi20_code PMSI20_LIB_COURT    PMSI20_LIB                
# <chr>                       <chr>   <chr>       <chr>               <chr>                     
#   1 EPSM LILLE METROPOLE      59G07   59C05       Lille (+2 communes) Lille, Lezennes, Capinghem
# 2 EPSM LILLE METROPOLE        59G21   59C05       Lille (+2 communes) Lille, Lezennes, Capinghem
# 3 EPSM AGGLOM. LILLOISE       59G22   59C05       Lille (+2 communes) Lille, Lezennes, Capinghem
# 4 EPSM AGGLOM. LILLOISE       59G23   59C05       Lille (+2 communes) Lille, Lezennes, Capinghem
# 5 EPSM AGGLOM. LILLOISE       59G24   59C05       Lille (+2 communes) Lille, Lezennes, Capinghem
# 6 EPSM LILLE METROPOLE        59I03   59C05       Lille (+2 communes) Lille, Lezennes, Capinghem
# 7 EPSM Agglomération lilloise 59I04   59C05       Lille (+2 communes) Lille, Lezennes, Capinghem
# 8 EPSM Agglomération lilloise 59I06   59C05       Lille (+2 communes) Lille, Lezennes, Capinghem


# Y a-t-il ambiguité possible pour l'EPSM DES FLANDRES ?

(
  sectorisation_psy
  |> filter(ES == "EPSM DES FLANDRES")
  |> pull(pmsi20_code)
  |> unique()
) -> communes_EPSM_FLANDRES

(
  sectorisation_psy
  |> filter(pmsi20_code %in% communes_EPSM_FLANDRES)
  |> pull(ES)
  |> unique()
)

# NON !!! Il n'y a pas d'ambiguité

(
  tibble(COD_COM = communes_EPSM_FLANDRES)
  |> write_csv("communes_EPSM_FLANDRES.csv")
  |> pinf()
)


## Ambiguité entre communes et regroupement secteurs
## G01-03, G02-04 et G05-06

(
  sectorisation_psy
  |> filter(ES == "EPSM DES FLANDRES", str_detect(Secteur, "G"))
  |> select(Secteur, pmsi20_code)
  |> count(pmsi20_code)
  |> filter(n > 1)
  |> pull(pmsi20_code)
) -> communes_multi_secteurs

(
  sectorisation_psy
  |> filter(ES == "EPSM DES FLANDRES", str_detect(Secteur, "G"))
  |> filter(pmsi20_code %in% communes_multi_secteurs)
  |> arrange(pmsi20_code)
  |> select(2:4)
)

## Seul le G05-06 est non ambigu
(
  sectorisation_psy
  |> filter(ES == "EPSM DES FLANDRES", str_detect(Secteur, "G"))
  |> select(pmsi20_code, Secteur)
  |> mutate(Secteur = str_sub(Secteur, 5, 5))
  |> group_by(pmsi20_code)
  |> summarise(Secteurs = paste0(Secteur, collapse = "|"))
  |> mutate(`G05-06` = str_detect(paste0(Secteurs), "5|6"))
  |> pinf()
)

