library(tidyverse)
library(readxl)

replace_Inf_NaN <- function(x) {
  ifelse(is.finite(x), x, NA)
}

((
  "data/activite_sae.xlsx"
  |> read_excel()
  |> replace_na(list(hc_19 = 0,
                     hc_22 = 0,
                     hp_19 = 0,
                     hp_22 = 0))
) -> sae_2019_2022)

((
  "data/activite_sae.xlsx"
  |> read_excel(sheet = 2)
  |> replace_na(list(jour_hc_19 = 0,
                     jour_hc_22 = 0,
                     jour_hp_19 = 0,
                     jour_hp_22 = 0))
  |> select(1, 2, 4, 6, 3, 5)
  |> mutate(evo_hp = (jour_hp_22 / jour_hp_19) |> replace_Inf_NaN())
  |> mutate(evo_hc = (jour_hc_22 / jour_hc_19) |> replace_Inf_NaN())
) -> activite_2019_2022_ratio)

((
  sae_2019_2022
  |> left_join(activite_2019_2022_ratio)
  |> mutate(TO_hp_19 = (jour_hp_19 / 365 / hp_19) |> replace_Inf_NaN())
  |> mutate(TO_hp_22 = (jour_hp_22 / 365 / hp_22) |> replace_Inf_NaN())
  |> mutate(TO_hc_19 = (jour_hc_19 / 365 / hc_19) |> replace_Inf_NaN())
  |> mutate(TO_hc_22 = (jour_hc_22 / 365 / hc_22) |> replace_Inf_NaN())
  |> mutate(place_hp_selon_TO = (floor((1 - TO_hp_22) * hp_22)) |> replace_Inf_NaN())
  |> mutate(place_hc_selon_TO = (floor((1 - TO_hc_22) * hc_22)) |> replace_Inf_NaN())
  |> mutate(place_hp_selon_evo_activite = (floor(hp_19 * (1 - evo_hp) - (hp_19 - hp_22))) |>  replace_Inf_NaN())
  |> mutate(place_hc_selon_evo_activite = (floor(hc_19 * (1 - evo_hc) - (hc_19 - hc_22))) |>  replace_Inf_NaN())
  |> select(1, 2, 4, 6 ,14, 16)
) -> places_libres)
