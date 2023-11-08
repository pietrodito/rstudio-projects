setwd("~")
(
  "./my_packages/RStudio-tools"
  |>  fs::dir_ls()
  |>  purrr::walk(~ devtools::install(.))
)
