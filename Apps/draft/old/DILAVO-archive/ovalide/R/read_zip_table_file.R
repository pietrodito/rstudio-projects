#' Read table data from zip ovalide file
#'
#' @param zip_filepath the zip file path
#' @param champ the PMSI champ
#' @param statut private or public status
#'
#' @return NULL
#' @export
#'
#' @examples
#' read_zip_table_file("file.zip", "had", "oqn")
#'
#' # can be called with `progressr::with_progress`
#' with_progressr(read_zip_table_file("file.zip", "had", "oqn"))
#'
#' # can also be called with `progressr::withProgressShiny`
read_zip_table_file <- function(zip_filepath, nature) {

  fs::dir_create(unzip_location())
  withr::defer(fs::dir_delete("./tmp"))

  prepare_csv_files(zip_filepath)

  dfs <- read_all_csv_files()

  save_all_tibbles_to_rds(dfs, nature)
}

columns_to_discard <- c("champ",
                        "statut",
                        "annee",
                        "periode",
                        "date du resultat",
                        "ipe",
                        "per_comp",
                        "date_comp",
                        "temp_comp")

unzip_location <- function() glue::glue(".{tempdir()}/")

prepare_csv_files <- function(zip_filepath) {
  silent_unzip(zip_filepath)
  remove_readme_file()
  rename_csv_files()
}

silent_unzip <- function(zip_filepath) {
  silent <- TRUE
  shell_command <- glue::glue("unzip {zip_filepath} -d {unzip_location()}")
  system(shell_command, intern = silent)
  invisible()
}

remove_readme_file <- function() {
  fs::file_delete(glue::glue("{unzip_location()}/LisezMoi.txt"))
}

rename_csv_files <- function() {
  old_names <- fs::dir_ls(unzip_location())
  dir_name <- dirname(old_names[1])
  ((
    old_names
    %>% basename()
    %>% stringr::str_sub(start = 14L, end = -5L)
    %>% stringr::str_remove("[:digit:]+\\.")
    %>% stringr::str_to_upper()
    %>% stringr::str_c(dir_name, "/", .)
  ) -> new_names)
  fs::file_move(old_names, new_names)
}

read_all_csv_files <- function() {

  future::plan(future::multisession)
  filepaths <- fs::dir_ls(unzip_location())
  filenames <- basename(filepaths)

  p <- progressr::progressor(along = filepaths)
  N <- length(filepaths)

  silent_read_csv <- function(csv_filepath) {
    p(basename(csv_filepath))
    read_csv2 <- purrr::quietly(readr::read_csv2)
    quiet_output <- read_csv2(csv_filepath,
                              locale = readr::locale(encoding = "WINDOWS-1252"))

    df <- quiet_output$result

    if("finess_comp" %in% names(df)) {
     (
       df
       %>% dplyr::select(- dplyr::any_of(columns_to_discard))
       %>% dplyr::mutate(finess_comp =
                           stringr::str_sub(finess_comp, start = 2L))
     ) -> df
    }
    df
  }
  (
    filepaths
    %>% furrr::future_map(silent_read_csv)
  ) -> dfs
  names(dfs) <- filenames
  dfs
}

save_all_tibbles_to_rds <- function(dfs, nature) {

  fs::dir_create(data_save_dir(nature))
  readr::write_rds(dfs, rds_filepath(nature))

  invisible()
}
