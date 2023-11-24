((
 rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")
 %>% filter(geounit == "France")
) -> france)

usethis::use_data(france, overwrite = TRUE)


