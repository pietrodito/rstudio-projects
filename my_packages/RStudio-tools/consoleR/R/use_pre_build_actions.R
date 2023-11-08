#' @export
use_pre_build_actions <- function() {
  action_filepath <- paste0(usethis::proj_path(), "/pre_build_actions.R")
  usethis::edit_file(action_filepath)
}
