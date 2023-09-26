#' @export
proj_reset_list <- function() {

  if (fs::file_exists(PROJECT_MANAGER_FILEPATH)) {
    fs::file_delete(PROJECT_MANAGER_FILEPATH)
  }

}
