proj_git_check <- function() {

  which_git <- system("which git", intern = TRUE)

  if( ! stringr::str_detect(which_git, "/git")) {
    stop("git is not found on your system...")
  }
}

project_status <- function(proj_path) {

  shell_command <- glue::glue("cd {proj_path}; git status 2> /dev/null")
  status <- suppressWarnings(system(shell_command, intern = TRUE))

  NOT_A_GIT_REPO <- 128
  git_return_value <- attr(status, "status")
  if (! is.null(git_return_value) && git_return_value == NOT_A_GIT_REPO) {
    return("")
  }

  nothing_to_commit <- stringr::str_detect(status, "nothing to commit")
  up_to_date        <- stringr::str_detect(status, "branch is up to date")
  not_staged        <- stringr::str_detect(status, "not staged for commit")
  untracked_files   <- stringr::str_detect(status, "Untracked files")

  nothing_to_commit <- if ( ! any(nothing_to_commit)) "x" else ""
  up_to_date        <- if ( ! any(up_to_date)       ) "+" else ""
  not_staged        <- if (   any(not_staged)       ) "!" else ""
  untracked_files   <- if (   any(untracked_files)  ) "?" else ""

  paste0(up_to_date, not_staged, untracked_files)
}

