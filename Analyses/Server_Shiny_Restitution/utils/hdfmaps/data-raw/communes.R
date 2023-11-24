require(tidyverse)
require(readxl)

add_leading_zero <- function(x, nb_digits = 5) {
 deltas <- nb_digits - str_length(x)
 zeros <- map(deltas, ~ str_c(rep("0", .), collapse = ""))
 str_c(zeros, x)
}

((
 "~/_data/codepost2022.xlsx"
 %>% read_excel()
 %>% select(1, 5)
 ) -> mapping_post_geo)

((
 "~/_data/communes-departement-region.csv"
 %>% read_csv()
 %>% mutate(
  ## First transform them in geometric points
  st_point = map2(.$longitude,
                  .$latitude,
                  ~ c(.x, .y))
  %>% map(st_point),
  ## Create feature telling we are using ESPG:4236
  sfc = st_sfc(st_point, crs = 4236)
  )
 %>% select(1, 2, 3, 17)
 %>% rename(geometry = sfc)
 %>% st_sf()
 %>% mutate(across(starts_with("code"), add_leading_zero))
 %>% left_join(mapping_post_geo, by = c("code_postal" = "Code postal 2022"))
) -> communes)

usethis::use_data(communes, overwrite = TRUE)
