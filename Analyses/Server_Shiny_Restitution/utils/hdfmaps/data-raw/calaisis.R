library(readxl)

calaisis <- read_excel(
  "data-raw/data_sources/Liste des codes géographiques_calaisis.xlsx"
)

load("data/codes_postaux.rda")

((
  codes_postaux
  |> filter(ID %in% calaisis$`Code géographique`)
  |> st_union()
) -> calaisis)

usethis::use_data(calaisis, overwrite = T)

