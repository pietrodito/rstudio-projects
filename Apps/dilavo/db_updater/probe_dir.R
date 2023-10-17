#!/usr/bin/Rscript --vanilla

options(future.rng.onMisuse = "ignore")

args <- commandArgs(trailingOnly=TRUE) 

if (length(args) == 0) {
  
  dir_2_probe <- readline("Tell me what dir to probe: ")

} else {

  dir_2_probe <- args[1]

}


dir_path <- paste0("ovalide_data/", dir_2_probe, "/")
  

box::use(
  
  ./db_updater_utils[
    treat_csv_files,
  ]
)

tryCatch(
  treat_csv_files(dir_2_probe),
  error = function(e) {
    message('ERROR when treating csv files')
    print(e)
  },
  
  finally = {
    ## remove all files
    unlink(paste0(dir_path, "*"))
  }
)


  
