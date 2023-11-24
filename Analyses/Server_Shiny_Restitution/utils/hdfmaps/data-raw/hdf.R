source("data-raw/autres_regions.R")

(hdf <-  regions[names(regions) == "Hauts-de-France"][[1]])

usethis::use_data(hdf, overwrite = TRUE)
