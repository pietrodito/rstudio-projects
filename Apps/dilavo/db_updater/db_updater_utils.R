box::use(
  
  
  app/logic/db_utils[
    db_connect,
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
  
  furrr[
    furrr_options,
    future_walk,
  ],
  
  future[
    plan,
    multicore,
  ],
  
  glue[
    glue,
  ],
  
  progressr[
    progressor,
  ], 
  
  purrr[
    walk,
  ],
  
  readr[
    locale,
    read_csv2,
  ],
  
  stringr[
    str_remove_all,
  ],
  
)



#' @export
treat_csv_files <- function(dir_2_probe) {
  db_name <- dir_2_probe |> toupper()
  log("---------------------------")
  log("         ", db_name)
  log("---------------------------")
  
  plan(multicore)
  
  filepaths <- list.files(paste0("/ovalide_data/", dir_2_probe),
                          pattern = "\\.csv$",
                          full.names = TRUE)
  filenames <- basename(filepaths)
  
  p <- progressor(along = filepaths)
  N <- length(filepaths)
  
  (
    filepaths
    |>  future_walk(treat_one_file, db_name, p
                    #, .options = furrr_options(seed = NULL)
                    )
  )
}

#' @export
pick_file_in_dir <- function(dir_path) {
  files <- list.files(dir_path)
  if(length(files) > 0) {
    paste0(dir_path, files[1])
  } else {
    NULL
  }
}

treat_one_file <- function(filepath, db_name, p, db) {
  
  log("> Enterting treat_one_file()", filepath)
  
  p(basename(filepath))
  
  log("> Reading data from file...")
  data <- read_csv2(
    filepath,
    locale = locale(encoding = "WINDOWS-1252"),
    name_repair = name_repair
  )
  
  log("> File read.")
  table_code <- extract_table_code(filepath)
  
  if(nrow(data) != 0) {
    (
      data
      |> mutate(ipe = str_remove_all(ipe, '[=|"]'),
                ipe = as.numeric(ipe))
    ) -> data
    
    log("> Trying to load data to db...")
    db <- db_connect(db_name)
    write_data_to_db(table_code, db, data, basename(filepath))
    
  } else {
    log("> Empty file...")
  }
  file.remove(filepath)
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


