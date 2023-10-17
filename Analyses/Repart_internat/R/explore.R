library(tidyverse)
library(readxl)


(
  "./data/Amiens/Amiens - Répartition_SPECIALITES_MAI_2023 maj au 09.03.23.xlsx"
  |>  read_excel(sheet = 2, skip = 6)
)

((
  "data/Amiens/Amiens - Tableau de répartition Dr JUNIOR MAI 2023 au 10.02.2023.xlsx"
  |>  read_excel(sheet = 1, skip = 1)
) -> df)

(
  df
  |> select(2, 4, 5)
  |> arrange(`NOM DE L'ETABLISSEMENT`,
             `NOM DU SERVICE`, 
             `SPECIALITE (DES/DESC)`)
) |> pinf()

cols <- colnames(df)

col_values <- function(col) { unique(df[[col]]) }

map(cols, col_values)

