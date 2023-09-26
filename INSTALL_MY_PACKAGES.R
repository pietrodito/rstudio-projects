setwd("~")
(
  "./my_packages/"
  |>  fs::dir_ls()
  |>  purrr::walk(~ devtools::install(.))
)
