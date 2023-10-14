#!/usr/bin/Rscript --vanilla

args <- commandArgs(trailingOnly=TRUE) 
dir_2_probe <- args[1]

dir_path <- paste0("ovalide_data/", dir_2_probe, "/")
  

box::use(
  
  app/logic/db_utils[
    db_connect,
  ],
    
  ./db_updater_utils[
    is_midnight,
    pick_file_in_ovalide_data,
    treat_file,
  ]
)

db_name <- dir_2_probe |> toupper()
db <- db_connect(db_name)

file <- NULL

while(TRUE) {
  if(is.null(file)) {
    Sys.sleep(.6)
    if(is_midnight()) {
      gc()
    }
  }
  file <- pick_file_in_ovalide_data(dir_path)
  if( ! is.null(file)) {
    treat_file(dir_2_probe, file, db)
  }
}

