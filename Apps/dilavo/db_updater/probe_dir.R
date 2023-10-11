#!/usr/bin/Rscript --vanilla

args <- commandArgs(trailingOnly=TRUE) 
dir_2_probe <- args[1]

dir_path <- paste0("ovalide_data/", dir_2_probe, "/")
  

box::use(
  
  ./db_updater_utils[
    pick_file_in_ovalide_data,
    treat_file,
  ]
)


while(TRUE) {
  Sys.sleep(.3)
  file <- pick_file_in_ovalide_data(dir_path)
  if( ! is.null(file)) {
    treat_file(dir_2_probe, file)
  }
}