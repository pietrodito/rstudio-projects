library(readr)
library(purrr)

finess <- read_csv(
  "data-raw/data_sources/new_FINESS_GEOLOC_2022_plus_archives_HDF.csv"
)

((
  finess
  |> mutate(
    st_point = map2(finess$X, finess$Y, ~ c(.x, .y)) |> map(st_point),
    lambert93_features = st_sfc(st_point, crs = 2154),
    google_maps_features  = st_transform(lambert93_features, crs = 4236)
  )
  |> pull(google_maps_features)
) -> points)

geom_column <- st_sfc(points)

finess <- st_sf(finess[, 1:3], geometry = geom_column)
finess$X <- st_coordinates(finess$geometry)[, 1]
finess$Y <- st_coordinates(finess$geometry)[, 2]

usethis::use_data(finess, overwrite = T)

