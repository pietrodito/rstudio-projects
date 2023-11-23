world <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")
pays_limitrophes <- dplyr::filter(world,
                                  geounit == "Belgium"        |
                                  geounit == "Switzerland"    |
                                  geounit == "Germany"        |
                                  geounit == "Luxembourg"     |
                                  geounit == "Spain"          |
                                  geounit == "Italy"          |
                                  geounit == "United Kingdom" |
                                  geounit == "Austria" |
                                  geounit == "Netherlands")


usethis::use_data(pays_limitrophes, overwrite = TRUE)
