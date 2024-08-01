box::use(
  
  mylog
  [ init_log_format, ],
  
  logger
  [ ... ],
  
  furrr
  [ future_walk, ],
  
  future
  [ plan, multicore, ],
  
  ovaliDB
  [ nature, ],
  
  progressr
  [ progressor, ], 
  
  purrr
  [ walk, ],
  
  stringr
  [ str_detect, str_split, ],
)

init_log_format()

#' @export
treat_csv_files <- function(dir_2_probe) {
  
  DB_NAME <- dir_2_probe |> toupper()
  splt_name <- str_split(dir_2_probe, "_") |> unlist()
  nature <- nature(splt_name[1], splt_name[2])
  
  log_debug("##### {DB_NAME} #####")
  
  plan(multicore)
  
  filepaths <- list.files(paste0("/ovalide_data/", dir_2_probe),
                          pattern = "\\.csv$",
                          full.names = TRUE)
  filenames <- basename(filepaths)
  
  p <- progressor(along = filepaths)
  N <- length(filepaths)
  
  which_walk <- future_walk
  if (Sys.getenv("DEBUG") != "NO") {
    which_walk <- walk
  } 
  
  if(! identical(filepaths, unique(filepaths))) {
    log_error("DUPLICATES: ", filepaths |> paste(collapse = " "))
  }
  
  (
    filepaths
    |> which_walk(treat_one_file, nature, p)
  )
  
  tdb_files <- str_detect(filenames, "tdb")
  k_v_files <- str_detect(filenames, "key_value")
  csv_files <- ! tdb_files & ! k_v_files
  
  list(
    csv = any(csv_files),
    k_v = any(k_v_files),
    tdb = any(tdb_files)
  )
}

#' @export
pick_file_in_dir <- function(dir_path) {

  files <- list.files(dir_path)
  if(length(files) == 0) return(NULL) 

  paste0(dir_path, files[1])
}

check_if_data_properly_added <- function(db,
                                         table_code,
                                         data,
                                         info,
                                         filepath) {
  box::use(
    DBI
    [ dbGetQuery, ],
    
    dplyr
    [ all_of, arrange, as_tibble, pick, select, ],
    
    glue
    [ glue, ],
  )
  
  from_db <- dbGetQuery(db, glue(
    "SELECT * FROM public.{table_code}
       WHERE champ   = '{info$field}'
         AND statut  = '{info$status}'
         AND annee   = '{info$year}'
         AND periode = '{info$month}'")) |> as_tibble()
  
  useless_cols <- c("champ", "statut", "annee", "periode")
  
  data <- select(data, -all_of(useless_cols))
  from_db <- select(from_db, -all_of(useless_cols))
  
  cols <- names(data)
  from_db <- select(from_db, all_of(cols))
 
  
  data <- arrange(data, pick(all_of(cols)))
  from_db <- arrange(from_db, pick(all_of(cols)))
  
  if(! identical(data, from_db)) {
    log_warn("DATA NOT PROPERLY INSERTED: {filepath}")
    browser()
  }
}

treat_one_file <- function(filepath, nature, p) {

  box::use(
    ovaliDB
    [ db, db_instant_connect, ],
    
    DBI
    [ dbDisconnect, ],
    
    dplyr
    [ mutate, ],
    
    pool
    [ localCheckout, ],
    
    stringr
    [ str_remove_all, ],
  )
  
  log_trace("READING FILE: ", basename(filepath))
  
  p(basename(filepath))
  
  db <- db_instant_connect(nature)
  table_code <- extract_table_code(filepath)
  data <- guess_encoding_and_read_file(filepath)
  info <- extract_info_from_filename(filepath)
  
  if(nrow(data) != 0) {
    (
      data
      |> mutate(ipe = str_remove_all(ipe, '[=|"]'))
    ) -> data
    
    tryCatch(
      write_data_to_db(db,
                       table_code,
                       data,
                       info),
      error = function(cond) {
        log_error("WRITING DATA: ", basename(filepath))
        log_error(cond)
      }
    )
    
    check_if_data_properly_added(db,
                                 table_code,
                                 data,
                                 info,
                                 filepath)
  } else {
    log_debug("Empty file...")
  }
  
    if(! file.remove(filepath)) {
     log_error("treat_one_file NOT EXISTS: ", basename(filepath))
    }
}

write_data_to_db <- function(db, table_code, data, info) {
  
  box::use(
    DBI
    [ dbCreateTable, dbExistsTable, ],
  )
  
  if( ! dbExistsTable(db, table_code)) {
    
    log_debug("write_data_to_db NOT EXISTS: ", table_code)
    dbCreateTable(db, table_code, data)
    
  } else {
    log_debug("ALLREADY EXISTS: ", table_code)
    add_cols_if_necessary(table_code, db, data)
  }
  
  update_values_in_table(table_code, db, data, info)
}

table_exists_in_db <- function(table_code, db) {
  
  box::use(
    DBI
    [ dbExistsTable, ],
    
    glue
    [ glue, ],
  )
  
  answer <- dbExistsTable(db, glue(
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
  
  log_debug("> create_new_cols table: ", tablename)
  log_debug("> create_new_cols db: ", format(db))
  log_debug("> create_new_cols types: ", types)
  
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
    
    log_debug(" > new_cols in ", table_code, ": ", new_cols)

    types <- find_postgres_types(new_cols, data)
    
    create_new_cols(table_code, db, types)
    
    log_debug(" > cols created in ", table_code)
  }
}

update_values_in_table <- function(table_code, db, data, info) {
  
  box::use(
    DBI
    [ dbAppendTable, dbExecute, ],
    
    glue
    [ glue, ],
  )
  
  
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
  log_info("NEW FILE FOUND: {filename} ")
  
  N <- nchar(filepath)
  file_extension <- substr(filepath, N - 2, N)
  
  switch(file_extension,
         zip = {
           dispatch_zip_file(filepath)
         },
         
         csv = {
           dispatch_csv_file(filepath)
         },
         
         ## default:
         {
           log_debug("> File deleted because extension is not correct: ", filename)
           
           if(! file.remove(filepath)) {
             log_error("dispatch_uploaded_file NOT EXISTS: ", basename(filepath))
           }
           
           return(NULL)
         })
}

dispatch_csv_file <- function(filepath) {
  
  box::use(
    stringr
    [ str_detect, ],
  )
  
  
  dashboard_file <- function(filepath) { str_detect(filepath, "TDB") }
  
  created_filepath <- NULL
  
  if(dashboard_file(filepath)) {
    created_filepath <- prepare_raw_dashboard_4_db(filepath) 
  } else {
    created_filepath <- prepare_raw_key_value_4_db(filepath) 
  }
  
  zipname <- zip_file(created_filepath)
  log_debug("ZIPPED INTO: {zipname}")
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
      extras = "-j",
      flags = "-q")
  
    if(! file.remove(created_filepath)) {
      log_error("zip_file NOT EXISTS: ", basename(created_filepath))
    }
  
  zipname
}

prepare_raw_dashboard_4_db <- function(filepath) {
  box::use(
    dplyr
    [ mutate, pull, rename, select, ],
    
    readr
    [ write_csv2, ],
    
    stringr
    [ str_remove_all, str_replace, str_split, ],
  )
  
  df <- guess_encoding_and_read_file(filepath)
  
  filename <- basename(filepath) |> str_replace("TDB", "tdb")
  
  details <- filename |> str_split("\\.") |> unlist()
  
  champ <- details[1]
  statut <- details[2]
  annee <- details[3]
  periode <- details[4]
  
  if(champ == "ssr") champ <- "smr"
  
  (
    df
    |> mutate(ipe = str_remove_all(ipe, '[=|"]'),
              champ = champ,
              statut = statut,
              annee = annee,
              periode = periode)
    |> select(- finess)
  ) -> df

  if (champ == "ssr") champ <- "smr"
  
  created_filepath <- paste0(
    "/ovalide_data/", champ, "_", statut, "/", filename)
  
  write_csv2(df, created_filepath)
  
    if(! file.remove(filepath)) {
      log_error("prepare_raw_dashboard_4_db NOT EXISTS: ", basename(filepath))
    }
  
  return(created_filepath)
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

  filename <- paste(champ, statut, annee, periode,
                    "key_value", "csv", sep = ".")
  
  created_filepath <- paste0("/ovalide_data/",
                             champ, "_", statut, "/", filename)
  
  write_csv2(df, created_filepath)
  
    if(! file.remove(filepath)) {
      log_error("prepare_raw_key_value_4_db OT EXISTS: ", basename(filepath))
    }
  
  return(created_filepath)
}

dispatch_zip_file <- function(filepath) {

  box::use(
    stats
    [ runif, ],
    
    utils
    [ unzip, ],
  )
  
  filename <- basename(filepath)
  
  if(filename_is_correct(filename)) {
    log_debug("CORRECT FILENAME: ", filename)
  } else {
    log_warn("> File deleted, name is not correct: ", filename)
    
    if(! file.remove(filepath)) {
      log_error("dispatch_zip_file NOT EXISTS: ", basename(filepath))
    }
    
    return(NULL)
  }
  
  info <- extract_info_from_filename(filename)
  
  dir_to_dispatch <- paste0("/ovalide_data/",
                            info$field, "_", info$status, "/")
  
  wait_for_no_more_csv_files_in <- function(dir_to_dispatch) {
    while(length(list.files(dir_to_dispatch)) > 0) {
      Sys.sleep(.3)
    }
  }
  
  ## TODO if probe_dir.R fails the dispatcher is stuck here
  wait_for_no_more_csv_files_in(dir_to_dispatch)
  
  zip_dir <- paste0(tempdir(), runif(1))
  unzip(filepath, exdir = zip_dir)
  
  
  from <- paste0(zip_dir, "/")
  file.copy(from = file.path(from, list.files(from)),
            to   = dir_to_dispatch)
  
  log_debug("UNZIPPED TO ",  dir_to_dispatch |> basename() |> toupper())
  
    if(! file.remove(filepath)) {
      log_error("dispatch_zip_file NOT EXISTS: ", basename(filepath))
    }
  
  system(paste0("rm -rf ", zip_dir))
    
  if (Sys.getenv("DEBUG") == "NO") {
    launch_probe_dir(dir_to_dispatch)
  } 
}

launch_probe_dir <- function(dir_to_dispatch) {
  
  db_name <- basename(dir_to_dispatch)
  
  probe_cmd <- paste("./probe_dir.R", db_name, " > /logs/probe &")
  log_debug("> Updating database: ", probe_cmd)
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
  infos <- strsplit(basename(filename), "\\.") |> unlist()
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
    
    dplyr
    [ filter, mutate, pull, row_number, ],
    
    readr
    [ cols, guess_encoding, locale, read_delim, ],
    
  )
  
  if(file.size(filepath) > 0) {
    (
      filepath
      |> guess_encoding(threshold = 0)
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
  
  
  if(! is.null(data$champ |> suppressWarnings())) {
    data <- mutate(data, champ = ifelse(champ == "SSR", "SMR", champ))
    data <- mutate(data, champ = ifelse(champ == "ssr", "smr", champ))
  }
  data
}

name_repair <- function(nm) {
  
  (empty <- nm == "")
  (fill_empty <- paste0("empty_", seq_len(sum(empty))))
  (nm[empty] <- fill_empty)
  
  nm <- tolower(nm)
  make.unique(nm, sep = "_")
}
