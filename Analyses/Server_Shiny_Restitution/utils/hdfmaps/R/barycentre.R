#' Title
#'
#' @param sf_tbl
#' @param weights
#'
#' @return
#' @export
#'
#' @examples
barycentre <- function(sf_tbl, weights) {
 ((
  sf_tbl
  %>% dplyr::mutate(w = weights)
 %>% mutate(lon = map_dbl(sf_tbl$geometry, function(g) g[1]),
            lat = map_dbl(sf_tbl$geometry, function(g) g[2]),
            w.lon = w * lon,
            w.lat = w * lat)
 %>% summarise(across(all_of(c("w.lon", "w.lat", "w")), sum))
 %>% mutate(c.lon = w.lon / w,
            c.lat = w.lat / w)
 ) -> centroid)
 st_sfc(st_point(c(centroid$c.lon, centroid$c.lat)))
}

