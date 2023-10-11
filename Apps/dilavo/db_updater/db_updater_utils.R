box::use(
  app/logic/db_utils[
    db_connect,
  ],
  
  app/logic/log_utils[
    log,
  ],
)

#' @export
pick_file_in_ovalide_data <- function(dir_path) {
  files <- list.files(dir_path)
  if(length(files) > 0) {
    paste0(dir_path, files[1])
  } else {
    NULL
  }
}

#' @export
treat_file <- function(dir_2_probe, filepath) {
  
  log("---------------------------")
  log("         ", dir_2_probe |> toupper())
  log("---------------------------")
  
  filename <- basename(filepath)
  
  db_name <- dir_2_probe |> toupper()
  db <- db_connect(db_name)
  
  if (is.null(db)) {
    log("> Unable to connect to database ", db_name)
  } else {
    
    log("> Trying to load data to db...")
    
    if (endsWith(filename, ".csv")) {
      treat_csv_file(filepath, db)
    }
    
    if (endsWith(filename, ".zip")) {
      treat_zip_file(filepath, db)
    }
  }
  
  log("> Deleting ", filename)
  file.remove(filepath)
}


treat_csv_file <- function(filepath, db) {
  log("> Reading CSV file: ", filepath)
}

treat_zip_file <- function(filepath, db) {
  log("> Reading ZIP file: ", filepath)
}

