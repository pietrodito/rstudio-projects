#!/usr/bin/Rscript --vanilla

options(future.globals.onReference = "error")

args <- commandArgs(trailingOnly=TRUE) 
dir_2_probe <- args[1]

dir_path <- paste0("ovalide_data/", dir_2_probe, "/")
  

box::use(
  
  ./db_updater_utils[
    treat_csv_files,
  ]
)

treat_csv_files(dir_2_probe)
  
