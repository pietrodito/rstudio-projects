#' Title
#'
#' @return A ggproto object.
#' @export
#'
#' @examples
#' (
#'   ggplot()
#'    + geom_sf(data = france)
#'    + zoom_france()
#' )

zoom_france <- function() {
 ggplot2::coord_sf(xlim = c(-5, 10), ylim = c(41, 52))
}

#' Title
#'
#' @return A ggproto object.
#' @export
#'
#' @examples
#' (
#'   ggplot()
#'    + geom_sf(data = france)
#'    + zoom_hdf()
#' )

zoom_hdf <- function() {
  ggplot2::coord_sf(xlim = c(1.4, 4.2), ylim = c(48.9, 51.05))
}
