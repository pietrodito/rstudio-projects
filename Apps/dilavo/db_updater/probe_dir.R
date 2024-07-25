#!/usr/bin/Rscript --vanilla

options(future.rng.onMisuse = "ignore")

args <- commandArgs(trailingOnly=TRUE) 

if (length(args) == 0) {
  
  dir_2_probe <- readline("Tell me what dir to probe: ")

} else {

  dir_2_probe <- args[1]

}


dir_path <- paste0("ovalide_data/", dir_2_probe, "/")
  
send_message <- function(...) {
  
    write(
      paste0(...),
      "/ovalide_data/messages/public_message.txt"
    )
}

type_of_treated_files <- NULL

tryCatch(
  {
    box::use( ./db_updater_utils[ treat_csv_files, ] )
    type_of_treated_files <- treat_csv_files(dir_2_probe)
  },
  
  error = function(e) {
    message('ERROR when treating csv files')
    print(e)
  },
  
  finally = {
    ## remove all files
    unlink(paste0(dir_path, "*"))
    ## TODO écrire info update dans UPDATE_LOG table LOGS
    
    box::use( ovaliDB [ db_update_logs, ],)
    
    sliced <- stringr::str_split(dir_2_probe, "_", simplify = T)
    
    field <- sliced[1]
    status <- sliced[2]
    
    if(type_of_treated_files$csv) {
      db_update_logs(field, status, "maj_csv", Sys.time())
    }
    if(type_of_treated_files$k_v) {
      db_update_logs(field, status, "maj_cle_val", Sys.time())
    }
    if(type_of_treated_files$tdb) {
      db_update_logs(field, status, "maj_tdb", Sys.time())
    }
    
    send_message(
      "Les données ", dir_2_probe,
      " ont été mises à jour le ", Sys.time()
    )
  }
)