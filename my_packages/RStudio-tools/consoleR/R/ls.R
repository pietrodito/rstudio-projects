#' @export
ls_ <- function(path = ".", hidden = TRUE) {


  dirname <- fs::path_abs(path)

  path_size <- stringr::str_length(dirname)

  print_line <- function() {
    cli::cat_line(paste(rep("*", path_size), collapse = ""))
  }

  print_box <- function(text) {
    print_line()
    cli::cat_line(dirname)
    print_line()
  }

  print_box(dirname)

  (
    path
    |> fs::dir_info(all = hidden)
    |> dplyr::mutate(hidden = stringr::str_starts(path, "\\."))
    |> dplyr::arrange(hidden, type, path)
    |> dplyr::select(path)
  )
}
