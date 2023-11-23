require(tidyverse)
require(sf)

((
 "~/_data/Code_Département_Région.csv"
 %>% read_csv()
 %>% bind_rows(tibble(Code = "020",
                      Département = "Corse",
                      Région = "Corse"))
) -> map_dpt_région)

((
 "~/_data/Fond de carte code postaux 2018/codes_postaux_region.shp"
 %>% st_read()
 %>% mutate(DEP = str_c("0", DEP))
 %>% left_join(map_dpt_région, by = c("DEP" = "Code"))
) -> codes_postaux)


usethis::use_data(codes_postaux, overwrite = TRUE)
