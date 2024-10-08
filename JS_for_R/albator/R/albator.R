#' <Add Title>
#'
#' <Add Description>
#'
#' @import htmlwidgets
#'
#' @export
albator <- function(data, ..., width = NULL, height = NULL, elementId = NULL) {

  # forward options using x
  x = list(
    data = data,
    options = list(...)
  )

  attr(x, 'TOJSON_ARGS') <- list(dataframe = "rows")

  # create widget
  htmlwidgets::createWidget(
    name = 'albator',
    x,
    width = width,
    height = height,
    package = 'albator',
    elementId = elementId
  )
}

#' Shiny bindings for albator
#'
#' Output and render functions for using albator within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a albator
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name albator-shiny
#'
#' @export
albatorOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'albator', width, height, package = 'albator')
}

#' @rdname albator-shiny
#' @export
renderAlbator <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, albatorOutput, env, quoted = TRUE)
}
