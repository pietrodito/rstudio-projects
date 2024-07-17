library(readxl)
library(tidyverse)

## Extract finness mapping
((
  "Finess2024HDFbis.xlsx" 
  |> read_excel(sheet = "Feuil1")
  |> select(finess, rs)
) -> map_finess)

pinf(map_finess)


## Data
((
  "ARRETE_BLANC.xlsx"
  |>  read_excel(sheet = "MP24_P2A - Credits Beneficiaire")
  |> select("CODE ARS", "MESURE NIVEAU 1", "BENEFICIAIRE",
            "CREDIT_ALLOUE")
) -> df)

((
  df
  |> left_join(map_finess, by = c("BENEFICIAIRE" = "finess"))
  |> pivot_wider(names_from = `MESURE NIVEAU 1`, values_from = CREDIT_ALLOUE)
  |> filter(! is.na(rs))
  |> mutate(Dotations = `Dotation populationnelle SMR` +
              `Dotation pédiatrique SMR` +
              `Dotation MIGAC SMR` +
              `Dotation pédiatrique SMR` +
              `IFAQ SMR`
              )
  |> mutate(Activité = `Montant au titre de l'activite de SMR` +
              `Dotation pour les molécules onéreuses SMR`)
  |> select(`CODE ARS`, rs, BENEFICIAIRE, Dotations, Activité,
            `Dotation de transition - Majoration ou minoration de la dotation forfaitaire`,
            `Montant du différentiel`
            )
  |> rename(`Dotation de transition` = `Dotation de transition - Majoration ou minoration de la dotation forfaitaire`)
  |> mutate(`Déséquilibre` = `Montant du différentiel` - `Dotation de transition` )
  |> mutate(`Déséquilibre / Activité` = Déséquilibre / Activité)
  |> mutate(`Déséquilibre / Activité (%)` = scales::percent_format(1)(`Déséquilibre / Activité`))
  |> arrange(`Déséquilibre / Activité`)
  |> mutate(`Transition / Activité` = - `Dotation de transition` / Activité)
  |> mutate(`Transition / Activité (%)` = scales::percent_format(1)(`Transition / Activité`))
  |> select(c(1:3, 10, 12, 4:8, 5:9))
) -> proper_df)
(
  proper_df
  |> select(c(2, 4, 5, 7))
  |> pinf()
)


hist(proper_df$`Déséquilibre / Activité`,breaks = -10:10/100)
