#!/usr/bin/Rscript --vanilla

args <- commandArgs(trailingOnly=TRUE) 
dir_2_probe <- args[1]

dir_path <- paste0("ovalide_data/", dir_2_probe, "/")
lock_file <- "dilavo.lock"
lock_path <- paste0(dir_path, lock_file)
  

box::use(
  
  ./db_updater_utils[
    pick_file_in_ovalide_data,
    treat_file,
  ]
)


while(TRUE) {
  Sys.sleep(.1)
  file <- pick_file_in_ovalide_data(dir_path, lock_path)
  if( ! is.null(file)) {
    treat_file(dir_2_probe, file)
  }
}