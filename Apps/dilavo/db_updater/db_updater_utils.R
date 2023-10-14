box::use(
  app/logic/db_utils[
    extract_info_from_filename,
  ],
  
  app/logic/df_utils[
    name_repair
  ],
  
  app/logic/log_utils[
    log,
  ],
)

box::use(
  DBI[
    dbAppendTable,
    dbWriteTable,
    dbDisconnect,
    dbFetch,
    dbSendStatement,
  ],
  
  dplyr[
    mutate,
  ],
  
  
  glue[
    glue,
  ],
  
  readr[
    locale,
    read_csv2,
  ],
  
  stringr[
    str_remove_all,
  ],
  
  utils[
    unzip,
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
treat_file <- function(dir_2_probe, filepath, db) {
   log("---------------------------")
  log("         ", dir_2_probe |> toupper())
  log("---------------------------")
  
  filename <- basename(filepath)
  
  
  N <- nchar(filepath)
  file_extension <- substr(filepath, N - 2, N)
  
  

  if (is.null(db)) {
    
    log("> Unable to connect to database ", db_name)
    
  } else {
    
    log("> Treating ", file_extension |> toupper(), " file: ", filepath)
    log("> file size: ", file.info(filepath)$size)
    
    
    if (file_extension == "csv") {
      treat_csv_file(filepath, db)
    }
    
    if (file_extension == "zip") {
      log("> Unziping file...")
      unzip(filepath, exdir = paste0("/ovalide_data/", dir_2_probe))
    }
  }
  
  log("> Deleting ", filename)
  file.remove(filepath)
}

#' @export
is_midnight <- function() {
  extract_hours_and_minutes <- function(time) {
    (
      time
      |> format()
      |> strsplit("[:| ]")
      |> unlist()
    ) -> v
    v[2:3]
  }
  
  all_equal_to_zero_zero <- function(v) {
    all(v == "00")
  }
  
  (
    Sys.time()
    |> extract_hours_and_minutes()
    |> all_equal_to_zero_zero() 
  )
}

treat_csv_file <- function(filepath, db) {
  log("> Reading data from file...")
  data <- read_csv2(
    filepath,
    locale = locale(encoding = "WINDOWS-1252"),
    name_repair = name_repair
  )
  
  table_code <- extract_table_code(filepath)
  
  if(nrow(data) != 0) {
    (
      data
      |> mutate(ipe = str_remove_all(ipe, '[=|"]'),
                ipe = as.numeric(ipe))
    ) -> data
    
    log("> Trying to load data to db...")
    write_data_to_db(table_code, db, data, basename(filepath))
  } else {
    log("> Empty file...")
  }
}

write_data_to_db <- function(table_code, db, data, filename) {
  if( ! table_exists_in_db(table_code, db)) {
    
    log("> Table ", table_code, " does NOT exists")
    log("> Creating table ", table_code, " in ", format(db))
    dbWriteTable(db, table_code, data)
    
  } else {
    
    log("> Table ", table_code, " does exists")
    log("> Inserting values...")
    update_values_in_table(table_code, db, data, filename)
    
  }
}

table_exists_in_db <- function(table_code, db) {
 rs <- dbSendStatement(db, glue(
   "SELECT EXISTS (
     SELECT 1
     FROM information_schema.tables
     WHERE table_name = '{table_code}'
   ) AS table_existence;" )
 )
 answer <- dbFetch(rs)
 answer[1, 1]
}

update_values_in_table <- function(table_code, db, data, filename) {
  info <- extract_info_from_filename(filename)
  dbSendStatement(db, glue(
    "DELETE FROM {table_code}
       WHERE champ   = '{info$field}'
         AND statut  = '{info$status}'
         AND annee   = '{info$year}'
         AND periode = '{info$month}'"
  ))
  dbAppendTable(db, table_code, data)
}

extract_table_code <- function(filepath) {
  filename <- basename(filepath)
  infos <- strsplit(filename, "\\.") |> unlist()
  infos[5]
}


