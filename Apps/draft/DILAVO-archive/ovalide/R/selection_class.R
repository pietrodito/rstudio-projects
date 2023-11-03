#' @export
selection <- function(lst = list()) {
  structure(
    lst,
    class = "selection"
  )
}

keep_last_occurrence_only <- function(lst) {
  lst |> rev() |> unique() |> rev()
}

#' @export
add_table <- function(selection, table_name, pos) {
  UseMethod("add_table")
}

#' @export
add_table.selection <- function(selection,
                                table_name,
                                pos = length(selection)) {
  new_selection <- append(selection, table_name, after = pos)
  result <- keep_last_occurrence_only(new_selection)
  selection(result)
}

#' @export
rm_table <- function(selection, table_name) {
  UseMethod("rm_table")
}
#' @export
rm_table.selection <- function(selection, table_name) {
  result <- setdiff(selection, table_name)
  selection(result)
}

selection_filepath <- function(column_name, nature) {
  paste0(data_save_dir(nature), "/", column_name, ".selection")
}

#' @export
write_selection <- function(selection, nature, column_name) {
  readr::write_rds(selection, selection_filepath(column_name, nature))
}

#' @export
read_selection <- function(nature, column_name) {
  file <- selection_filepath(column_name, nature)
  if (fs::file_exists(file)) {
    readr::read_rds(file)
  } else {
    selection()
  }
}

