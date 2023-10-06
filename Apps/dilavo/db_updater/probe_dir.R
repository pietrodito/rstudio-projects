#!/usr/bin/Rscript --vanilla

args <- commandArgs(trailingOnly=TRUE) 
dir_2_probe <- args[1]

dir_path <- paste0("ovalide_data/", dir_2_probe, "/")
lock_file <- "dilavo.lock"
lock_path <- paste0(dir_path, lock_file)
  

box::use(
  ./db_utils[
    db_connect,
  ],
)

db <- db_connect()

pick_file_in_ovalide_data <- function() {
  if (file.exists(lock_path)) {
    NULL
  } else {
    files <- list.files(dir_path)
    if(length(files) > 0) {
      paste0(dir_path, files[1])
    } else {
      NULL
    }
  }
}


while(TRUE) {
  Sys.sleep(.1)
  file <- pick_file_in_ovalide_data()
  if( ! is.null(file)) {
    write(dir_2_probe, "/logs/log.txt", append = TRUE)
    write(file, "/logs/log.txt", append = TRUE)
    file.remove(file)
  }
}