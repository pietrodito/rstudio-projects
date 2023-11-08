#' @export
proj_add <- function(path = ".") {

  stopifnot(fs::dir_exists(path))
  path <- path |> fs::path_expand() |> fs::path_abs()
  project <- basename(path)
  names(project) <- path

  if ( ! fs::file_exists(PROJECT_MANAGER_FILEPATH)) {

    print(project)
    readr::write_rds(project, PROJECT_MANAGER_FILEPATH)

  } else {

    projects <- readr::read_rds(PROJECT_MANAGER_FILEPATH)

    (
      project
      |> c(projects)
      |> (\(x) x[ ! duplicated(x)])()
      |> sort()
    ) -> projects

    readr::write_rds(projects, PROJECT_MANAGER_FILEPATH)
  }
}
