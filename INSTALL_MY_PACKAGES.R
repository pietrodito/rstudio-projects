setwd("~")

follow_symlinks <- function(paths) {
  
  merge_path <- function(path, link) {
    paste0(dirname(path), "/", link)
  }
  
  (
    paths
    |> Sys.readlink() 
    |> (\(x) ifelse(x == "", paths, merge_path(paths, x)))()
  )
}

(
  "./my_packages/RStudio-tools"
  |> fs::dir_ls()
  |> follow_symlinks()
  |> purrr::walk(~ devtools::install(.))
)
