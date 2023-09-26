#' @export
proj_build <- function() {

  project_info <- proj_list()
  nb_of_projects <- project_info$nb_of_projects
  projects <- project_info$projects

  if (nb_of_projects > 0) {

    suppressWarnings(answer <- readline("Build project: ") |> as.numeric())

    if (is.numeric(answer) && answer %in% 1:nb_of_projects) {
      build_package(names(projects)[answer])
    }
  }
}
