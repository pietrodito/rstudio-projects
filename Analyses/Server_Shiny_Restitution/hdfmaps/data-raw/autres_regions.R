source("data-raw/codes_postaux.R")

((
 codes_postaux
 %>% pull(Région)
 %>% unique()
 %>% sort()
 %>% as.list()
) -> nom_regions)

(names(nom_regions) <- nom_regions)

((
 nom_regions
 %>% map(function(region) {
  (
   codes_postaux
   %>% filter(Région == region)
  )
 })
) -> regions_CP)

((
 regions_CP
 %>% map2(names(regions_CP), function(region, name) {
   st_sf(Région = name, geometry = st_union(region))
 })
) -> regions)

(autres_regions_list <- regions[names(regions) != "Hauts-de-France"])


(autres_regions <- do.call(bind_rows, autres_regions_list))


usethis::use_data(autres_regions, overwrite = TRUE)
