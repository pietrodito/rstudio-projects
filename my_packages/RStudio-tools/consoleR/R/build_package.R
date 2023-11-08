#' Build package
#' @export
build_package <- function(path = ".", quiet = F) {


  path <- fs::path_abs(path)
  stopifnot(fs::dir_exists(path))

  message("Building package ", path)

  owd <- getwd()
  setwd(path)
  withr::defer(setwd(owd))

  do_pre_build_actions()

  if (folder_has_changed(path)) {

    devtools::document()

    package_name <- fs::path_file(path)
    build_in_shell(path, package_name, quiet)
  } else {
    message("Package has not changed... Nothing to do!")
  }
}

sha1sum_backup_folder <- "~/.sha1sum_footprints"

path_to_footprint_name <- function(path) {
  path_to_file_name <- stringr::str_replace_all(path, "/", "_")
  paste0(sha1sum_backup_folder, "/", path_to_file_name, ".rds")
}

get_old_sha1sum_footprint <- function(path) {
  footprint_file <- path_to_footprint_name(path)
  if (fs::file_exists(footprint_file)) {
    readr::read_rds(footprint_file)
  } else {
    NULL
  }
}

compute_package_sha1sum <- function(path) {

  if ( ! fs::dir_exists(sha1sum_backup_folder)) {
    fs::dir_create(sha1sum_backup_folder)
  }

  shell_command <-
    "find . -type f -print0 | sort -z | xargs -0 sha1sum | sha1sum"
  (foot_print <- system(shell_command, intern = TRUE))

  readr::write_rds(foot_print, path_to_footprint_name(path))

  foot_print
}

folder_has_changed <- function(path) {
  old_footprint <- get_old_sha1sum_footprint(path)

  ! identical(old_footprint, compute_package_sha1sum(path))
}

do_pre_build_actions <- function() {
  action_path <- "pre_build_actions.R"
  if (fs::file_exists(action_path)) {
    source(action_path)
  }
}


shell_command <- function(path, package_name, parent_dir, quiet) {

  redirection <- ""
  if (quiet) redirection <- "2>/dev/null 1>&2"

  set_working_dir <- paste("cd", parent_dir, ";")
  build_cmd <- "R CMD INSTALL --preclean --no-multiarch --with-keep.source"

  result <- paste(set_working_dir, redirection, build_cmd, package_name)

  result
}

build_in_shell <- function(path, package_name, quiet) {
  parent_dir <- fs::path_dir(path)
  command <- shell_command(path, package_name, parent_dir, quiet)
  system(command)
}
