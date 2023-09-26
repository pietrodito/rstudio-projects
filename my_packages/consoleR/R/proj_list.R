#' @export
proj_list <- function() {

  projects <- NULL
  nb_of_projects <- 0

  if (fs::file_exists(PROJECT_MANAGER_FILEPATH)) {

    projects <- readr::read_rds(PROJECT_MANAGER_FILEPATH)
    nb_of_projects <- length(projects)

    (
      projects
      |> present_projects()
      |> number_projects()
    )

  } else {

    message("No project saved!")

  }

  invisible(list(nb_of_projects = nb_of_projects,
                 projects = projects))
}



present_projects <- function(projects) {

    name_max_width <- max(nchar(projects))
    path_max_width <- max(nchar(names(projects)))

    (
      projects
      |> purrr::imap(\(project, path)
                     paste(stringr::str_pad(project,
                                            width = name_max_width,
                                            side = "right"),
                           "[",
                           stringr::str_pad(path,
                                            width = path_max_width,
                                            side = "right"),
                           "]",
                           project_status(path)
                           ))
    )
}

number_projects <- function(displayable_projects) {
  (
    displayable_projects
    |> purrr::map2(seq_along(displayable_projects),
                   ~ paste(.y |> stringr::str_pad(width = 3, side = "right"),
                           .x))
    |> purrr::walk(\(s) cat(s, "\n"))
  )
}
