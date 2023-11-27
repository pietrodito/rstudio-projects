#' Title
#'
#' @return
#' @export
#'
#' @examples
carte_4236 <- function(fill = land_color, alpha = 2, lty = 1, col = "black") {
  geom_sf(data = france, fill = fill, alpha = 1, lty = 1, col = col)
}
