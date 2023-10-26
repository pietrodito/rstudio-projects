#' @import htmlwidgets
#' @export
tabulator <- function(data, ...,
                      headerMenuItems       = NULL,
                      headerMenuEvents      = headerMenuItems,
                      cellContextMenuItems  = NULL,
                      cellContextMenuEvents = cellContextMenuItems,
                      .width                = NULL,
                      .height               = NULL,
                      elementId             = NULL) {
  x <- list(
    data = data,
    options = list(...),
    headerMenuItems       = headerMenuItems,
    headerMenuEvents      = headerMenuEvents,
    cellContextMenuItems  = cellContextMenuItems,
    cellContextMenuEvents = cellContextMenuEvents
  )

  attr(x, 'TOJSON_ARGS') <- list(dataframe = "rows")

  htmlwidgets::createWidget(
    name = "tabulator",
    x,
    width  = .width,
    height = .height,
    package = "tabulatorr",
    elementId = elementId
  )
}

#' @name tabulator-shiny
#' @export
tabulatorOutput <- function(outputId, width = "100%", height = "100px") {
  htmlwidgets::shinyWidgetOutput(outputId, "tabulator", width, height, package = "tabulatorr")
}

#' @rdname tabulator-shiny
#' @export
renderTabulator <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) {
    expr <- substitute(expr)
  }
  htmlwidgets::shinyRenderWidget(expr, tabulatorOutput, env, quoted = TRUE)
}
