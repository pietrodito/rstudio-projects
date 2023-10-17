box::use(
  
  app/logic/db_utils[
    db_connect,
    extract_info_from_filename,
    guess_encoding_and_read_file,
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
    dbClearResult,
    dbDisconnect,
    dbFetch,
    dbListFields,
    dbSendStatement,
    dbWriteTable,
  ],
  
  dplyr[
    bind_rows,
    left_join,
    mutate,
    select,
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
    map,
    pmap_chr,
    walk,
  ],
  
  readr[
    locale,
  ],
  
  stringr[
    str_remove_all,
  ],
  
  tibble[
    tribble,
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
  
  which_walk <- future_walk
  if (Sys.getenv("DEBUG") == "YES") {
    which_walk <- walk
  } 
  
  (
    filepaths
    |> which_walk(treat_one_file, db_name, p)
  )
  invisible()
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
  
  log("> Reading file ", filepath)
  
  p(basename(filepath))
  
  
  data <- guess_encoding_and_read_file(filepath)
  
  table_code <- extract_table_code(filepath)
  
  if(nrow(data) != 0) {
    (
      data
      |> mutate(ipe = str_remove_all(ipe, '[=|"]'))
    ) -> data
    
    db <- db_connect(db_name)
    
    write_data_to_db(table_code, db, data, basename(filepath))
    
    dbDisconnect(db)
  } else {
    log("> Empty file...")
  }
  file.remove(filepath)
}

write_data_to_db <- function(table_code, db, data, filename) {
  if( ! table_exists_in_db(table_code, db)) {
    
    log("> Table ", table_code, " does NOT exists")
    dbWriteTable(db, table_code, data)
    
  } else {
    
    log("> Table ", table_code, " does exists")
    add_cols_if_necessary(table_code, db, data)
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

find_postgres_types <- function(new_cols, data) {
  
  types <- map(new_cols, function(col) {
    tibble::tibble(
      col = col,
      R_type = class(data[[col]])
    )
  })
  
  types <- do.call(bind_rows, types)
  
  R_2_db_types <- tribble(
    ~R_type    , ~postgres_type,
    "numeric"  , "double precision",
    "character", "text",
    "Date"     , "date"
  )
  
  (
    types
    |> left_join(R_2_db_types, by = "R_type")
    |> select(col, postgres_type)
  )
}

create_new_cols <- function(tablename, db, types) {
  
  log("> create_new_cols table: ", tablename)
  log("> create_new_cols db: ", format(db))
  log("> create_new_cols types: ", types)
  
  add_col <- function(col, postgres_type) {
    statement <- paste0(
      "ALTER TABLE ", tablename,
      " ADD COLUMN ", col, " ", postgres_type, ";"
    )
  }
  
  statements <- pmap_chr(types, add_col)
  
  walk(statements, function(s) {
    rs <- dbSendStatement(db, s)
    dbClearResult(rs)
  })
}

add_cols_if_necessary <- function(table_code, db, data) {
  
  old_cols <- dbListFields(db, table_code)
  
  new_cols <- setdiff(names(data), old_cols)
  
  if(length(new_cols) > 0) {
    
    log(" > new_cols in ", table_code, ": ", new_cols)

    types <- find_postgres_types(new_cols, data)
    
    create_new_cols(table_code, db, types)
    
    log(" > cols created in ", table_code)
  }
}

update_values_in_table <- function(table_code, db, data, filename) {
  info <- extract_info_from_filename(filename)
  dbSendStatement(db, glue(
    "DELETE FROM public.{table_code}
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


