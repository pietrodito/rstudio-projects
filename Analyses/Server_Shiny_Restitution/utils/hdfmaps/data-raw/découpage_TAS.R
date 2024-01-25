require(readxl)
require(dplyr)
require(stringr)
library(sf)

découpage_TAS <-
  read_excel("data-raw/data_sources/découpage_TAS_HDF.xlsx")


découpage_TAS


usethis::use_data(découpage_TAS, overwrite = TRUE)

load("data/codes_postaux.rda")

(
  codes_postaux
  |> inner_join(
    (
      découpage_TAS
      |> select(TAS_LIb, pmsi20_code)
      |> unique()
    ),
    by = c("ID" = "pmsi20_code"))
) -> geom_with_tas

tas_names <- unique(geom_with_tas$TAS_LIb)
replace_space_and_hyphen_with_underscore <- function(x) {
    str_replace_all(x, "[ |-]", "_")
} 

purrr::walk(tas_names,
            function(name) {
              assign(name |> replace_space_and_hyphen_with_underscore(),
                     geom_with_tas |> filter(TAS_LIb == name))
              eval(parse(text = str_c(
                "usethis::use_data(",
                name |> replace_space_and_hyphen_with_underscore(),
                ", overwrite = TRUE)"
              )))
            })
