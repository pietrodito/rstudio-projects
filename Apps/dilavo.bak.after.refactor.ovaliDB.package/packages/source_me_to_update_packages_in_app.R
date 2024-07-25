(packages <-  list.dirs("packages", recursive = FALSE))
(package_names <- basename(packages))

purrr::walk(packages, build)

renv::remove(package_names)
purrr::walk(package_names, renv::purge, prompt = FALSE)
renv::install(package_names, check = TRUE, prompt = FALSE)

rm(list = c("packages", "package_names"))
