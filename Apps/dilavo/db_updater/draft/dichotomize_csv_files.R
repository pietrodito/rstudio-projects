library(tidyverse)
library(glue)

setwd("~/tmp/")

(files <- list.files(pattern = "*.csv"))
first_half_files <- NULL
second_half_files <- NULL

zipfile <- "mco.oqn.2023.10.ovalide-tables-as-csv.zip"
upload_dir <- "~/Apps/dilavo/ovalide_data/upload/"

divide_files_in_two_groups <- function(files) {
  nb_files <- length(files)
  if(nb_files > 1) {
    half <- nb_files %/% 2
    tmp_files <- files
    first_half_files <<- tmp_files[1:half]
    second_half_files <<- tmp_files[(half+1):nb_files]
  } else {
    warning("Only one file!")
    first_half_files <<- files
    second_half_files <<- NULL
  }
}

test_files <- function(files) {
  move_archive_to_upload_dir <- function() {
    system(glue("mv {zipfile} {upload_dir}"))
  }
  system(glue("rm {zipfile} -f"))
  walk(glue("zip {zipfile} {files}"), system)
  move_archive_to_upload_dir()
}


divide_files_in_two_groups(files)

test_files(first_half_files)
test_files(second_half_files)

divide_files_in_two_groups(first_half_files)
divide_files_in_two_groups(second_half_files)

