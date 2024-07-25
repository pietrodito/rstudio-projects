# app/logic/undo_utils

#' @export
details <- function(values = list(), undo_list = list(), current = 0) {
  
  if (current == 0) {
    list(
      values,
      details_undo_list = list(values),
      details_current = 1
    )
  } else {
    list(
      values,
      details_undo_list = undo_list,
      details_current = current
    )
  }
}

#' @export
update_details <- function(old_details, values) {
  
  undo_list <- list()
  current <- old_details$details_current
  old_undo <- old_details$details_undo_list
  if(current == 1) {
    undo_list <- c(old_undo, list(values))
  } else {
    undo_list <- c(
      old_undo[1:current],
      list(values)
    )
  }
  
  details(
    values,
    undo_list = undo_list,
    current = current + 1
  )
}

values <- function(details) {
  details$details_undo_list <- NULL
  details$details_current <- NULL
  details
}

#' @export
undo <- function(details) {
  current <- details$details_current
  if (current > 1) {
    details(
      details$details_undo_list[[ current - 1 ]],
      details$details_undo_list,
      current - 1
    )
  } else {
    details
  }
}

#' @export
redo <- function(details) {
  
  current <- details$details_current
  undo_list <- details$details_undo_list
  
  if (current < length(undo_list)) {
    details(
      undo_list[[ current + 1 ]],
      undo_list,
      current + 1
    )
  } else {
    details
  }
}


