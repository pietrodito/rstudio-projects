library(tidyverse)
library(readxl)

(df <- read_excel("data/Nouveau recours 2023.xlsx"))
(df <- read_excel("data/Nouveau recours 2023_avec autorisation 50.xlsx"))

(
  df
  |> mutate(Dpt = str_sub(codepost, end = -4))
  |> mutate(type_hospitUM = ifelse(type_hospitUM == 1, "HC", "HP"))
) -> df

(
  df
  |> count(Dpt, type_hospitUM, finess, rs)
  |> arrange(desc(n))
  |> write_csv("Par_dpt_patient.csv")
)

(
  df
  |> count(finess, rs, type_hospitUM)
  |> arrange(desc(n))
  |> write_csv("Par_finess.csv")
)
