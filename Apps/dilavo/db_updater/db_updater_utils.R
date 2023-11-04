box::use(
  app/logic/log_utils
  [ log, ],
)
  
#' @export
treat_csv_files <- function(dir_2_probe) {
  
  box::use(
    furrr
    [ future_walk, ],
    
    future
    [ plan, multicore, ],
    
    progressr
    [ progressor, ], 
    
    purrr
    [ walk, ],
  )
  
  
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
  
  box::use(
    app/logic/db_utils
    [ db_connect, ],
    
    DBI
    [ dbDisconnect, ],
    
    dplyr
    [ mutate, ],
    
    stringr
    [ str_remove_all, ],
  )
  
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
  
  box::use(
    DBI
    [ dbWriteTable, ],
  )
  
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
  
  box::use(
    DBI
    [ dbGetQuery, ],
    
    glue
    [ glue, ],
  )
  
  answer <- dbGetQuery(db, glue(
    "SELECT EXISTS (
     SELECT 1
     FROM information_schema.tables
     WHERE table_name = '{table_code}'
   ) AS table_existence;" )
  )
  answer[1, 1]
}

find_postgres_types <- function(new_cols, data) {
  
  box::use(
    dplyr
    [ bind_rows, left_join, select, ],
    
    purrr
    [ map, ],
    
    tibble
    [ tribble, ],
  )
  
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
  
  box::use(
    DBI
    [ dbExecute, ],
    
    purrr
    [ pmap_chr, walk, ],
  )
  
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
    dbExecute(db, s)
  })
}

add_cols_if_necessary <- function(table_code, db, data) {
  
  box::use(
    DBI
    [ dbListFields, ],
  )
  
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
  
  box::use(
    DBI
    [ dbAppendTable, dbExecute, ],
    
    glue
    [ glue, ],
  )
  
  info <- extract_info_from_filename(filename)
  dbExecute(db, glue(
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

#' @export
dispatch_uploaded_file <- function(filepath) {
  filename <- basename(filepath)
  log("-----------------------------")
  log("      NEW FILE UPLOADED      ")
  log("-----------------------------")
  log("> ", filename)
  
  N <- nchar(filepath)
  file_extension <- substr(filepath, N - 2, N)
  
  switch(file_extension,
         zip = {
           treat_zip_file(filepath)
         },
         
         csv = {
           treat_csv_file(filepath)
         },
         
         ## default:
         {
           log("> File deleted because extension is not correct: ", filename)
           file.remove(filepath)
           return(NULL)
         })
}

treat_csv_file <- function(filepath) {
  log("> CSV file detected: ", filepath)
  created_filepath <- prepare_raw_key_value_4_db(filepath) 
  zip_file(created_filepath)
}

zip_file <- function(created_filepath) {
  
  box::use(
    stringr
    [ str_replace, ],
    
    utils
    [ zip, ],
  )
  
  filename <- basename(created_filepath)
  zipname <- str_replace(filename, "\\.csv", ".zip")
  zipfile <- paste0("/ovalide_data/upload/", zipname)
  
  
  zip(zipfile = zipfile,
      files = created_filepath,
      extras = "-j")
  
  
  file.remove(created_filepath)
}

prepare_raw_key_value_4_db <- function(filepath) {
  
  box::use(
    dplyr
    [ mutate, pull, rename, ],
    
    readr
    [ write_csv2, ],
  )
  
  
  df <- guess_encoding_and_read_file(filepath)
  
  (
    df
    |> rename(
      champ = champ,
      statut = statut,
      annee = annee, 
      periode = period,
      ipe = ipe
    )
    |> mutate(
      champ = tolower(champ),
      statut = ifelse(statut == "PUBLIC", "dgf", "oqn")
    )
  ) -> df
  
  champ   <- pull(df[1, ], champ  )
  statut  <- pull(df[1, ], statut )
  annee   <- pull(df[1, ], annee  )
  periode <- pull(df[1, ], periode)
  ipe     <- pull(df[1, ], ipe    )
  
  filename <- paste(champ, statut, annee, periode, "key_value", "csv", sep = ".")
  
  created_filepath <- paste0("/ovalide_data/", champ, "_", statut, "/", filename)
  
  write_csv2(df, created_filepath)
  
  file.remove(filepath)
  
  return(created_filepath)
}

treat_zip_file <- function(filepath) {
  
  box::use(
    stats
    [ runif, ],
    
    utils
    [ unzip, ],
  )
  
  filename <- basename(filepath)
  
  if(filename_is_correct(filename)) {
    log("> File with correct filename: ", filename)
  } else {
    log("> File deleted because filename is not correct: ", filename)
    file.remove(filepath)
    return(NULL)
  }
  
  info <- extract_info_from_filename(filename)
  
  dir_to_dispatch <- paste0("/ovalide_data/",
                            info$field, "_", info$status, "/")
  
  log("> Unziping file...")
  
  wait_for_no_more_csv_files_in <- function(dir_to_dispatch) {
    while(length(list.files(dir_to_dispatch)) > 0) {
      Sys.sleep(.3)
    }
  }
  
  wait_for_no_more_csv_files_in(dir_to_dispatch)
  
  zip_dir <- paste0(tempdir(), runif(1))
  unzip(filepath, exdir = zip_dir)
  
  log("> File unziped...", zip_dir)
  
  
  from <- paste0(zip_dir, "/")
  file.copy(from = file.path(from, list.files(from)),
            to   = dir_to_dispatch)
  
  log("> File rename from: ", from)
  log("> File rename to: ",  dir_to_dispatch)
  
  file.remove(filepath)
  system(paste0("rm -rf ", zip_dir))
    
  if (Sys.getenv("DEBUG") == "NO") {
    launch_probe_dir(dir_to_dispatch)
  } 
}

launch_probe_dir <- function(dir_to_dispatch) {
  
  db_name <- basename(dir_to_dispatch)
  
  probe_cmd <- paste("./probe_dir.R", db_name, "&")
  log("> Updating database: ", probe_cmd)
  system(probe_cmd)
}

filename_is_correct <- function(filepath) {
  (
    endsWith(filepath, ".zip") || endsWith(filepath, ".csv")
  )  &&
    info_are_correct(
      extract_info_from_filename(filepath)
    )
}

info_are_correct <- function(info) {
    info$field %in% c("mco", "had", "psy", "smr") &&
    info$status %in% c("oqn", "dgf")              &&
    as.integer(info$year) >= 2011                 &&
    as.integer(info$month) %in% 1:12
}

extract_info_from_filename <- function(filename) {
  infos <- strsplit(filename, "\\.") |> unlist()
  info <- list(
    field  = infos[1],
    status = infos[2],
    year   = infos[3],
    month  = infos[4]
  )
  
  update_ssr_to_smr(info)
}

update_ssr_to_smr <- function(info) {
  if (info$field == "ssr") info$field <- "smr"
  info
}

guess_encoding_and_read_file <- function(filepath) {
  
  box::use(
    app/logic/df_utils
    [ name_repair, ],
    
    dplyr
    [ filter, pull, row_number, ],
    
    readr
    [ cols, guess_encoding, locale, read_delim, ],
    
  )
  
  if(file.size(filepath) > 0) {
    (
      filepath
      |> guess_encoding()
      |> filter(row_number() == 1)
      |> pull(encoding)
    ) -> encoding
    
    data <- read_delim(
      filepath,
      delim = ";",
      locale = locale(encoding = encoding),
      name_repair = name_repair,
      col_types = cols()
    )
    
  } else {
    data <- read_delim(filepath,
                       delim = ";",
                       col_types = cols())
  }
  data[] <- lapply(data, as.character)
  data
}