# app/logic/db_utils.R

box::use(
  ../../app/logic/log_utils[
    log,
  ],
  
  ../../app/logic/df_utils[
    name_repair,
  ],
  
)

box::use(
  RPostgres[
    Postgres
    ],
  
  DBI[
    dbConnect
    ],
  
  dplyr[
    mutate,
    pull,
    rename,
  ],
  
  readr[
    read_csv2,
    write_csv2,
  ],
  
  stringr[
    str_remove,
    str_replace,
  ],
  
  utils[
    unzip,
    zip,
  ],
)

#' @export
db_connect <- function(db_name) {
  
  tryCatch(
    {
      dbConnect(Postgres(),
                host     = Sys.getenv("DB_HOST"    ),
                port     = Sys.getenv("DB_PORT"    ),
                user     = Sys.getenv("DB_USER"    ),
                password = Sys.getenv("DB_PASSWORD"),
                dbname  = db_name)
    },
    error = function(cond) {
      message("Unable to connect to db:")
      message(cond |> conditionMessage())
      NULL
    }
  ) -> db
  
  if (is.null(db)) {
    log("> Failed to connect to  ", db_name)
  } else {
    log("> Connected to: ", format(db))
  }
  db
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
  
  if (file_extension == "zip") {
    treat_zip_file(filepath)
  }
  
  if (file_extension == "csv") {
    treat_csv_file(filepath)
  }
    
}


treat_csv_file <- function(filepath) {
  created_filepath <- prepare_raw_key_value_4_db(filepath) 
  zip_file(created_filepath)
  
}

zip_file <- function(created_filepath) {
  filename <- basename(created_filepath)
  zipname <- str_replace(filename, "\\.csv", ".zip")
  zipfile <- paste0("/ovalide_data/upload/", zipname)
  
  
  zip(zipfile = zipfile,
      files = created_filepath,
      extras = "-j")
  
  
  file.remove(created_filepath)
}


prepare_raw_key_value_4_db <- function(filepath) {
  df <- read_csv2(filepath, name_repair = name_repair) 
  
  (
    df
    |> rename(
      champ = Champ,
      statut = Statut,
      annee = Annee, 
      periode = Period,
      ipe = IPE
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
  
  zip_dir <- tempdir()
  unzip(filepath, exdir = zip_dir)
  
  log("> File unziped...", zip_dir)
  
  
  from <- paste0(zip_dir, "/")
  file.copy(from = file.path(from, list.files(from)),
            to   = dir_to_dispatch)
  
  log("> File rename from: ", from)
  log("> File rename to: ",  dir_to_dispatch)
  
  file.remove(filepath)
  
  launch_probe_dir(dir_to_dispatch)
  
}


launch_probe_dir <- function(dir_to_dispatch) {
  
  db_name <- basename(dir_to_dispatch)
  
  probe_cmd <- paste("./probe_dir.R", db_name, "&")
  log("> Updating database: ", probe_cmd)
  system(probe_cmd)
}

#' @export
columns_from_db_table <- function(db, table) {
  
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
    as.integer(info$year) >= 2023                 &&
    as.integer(info$month) %in% 1:12
}

#' @export
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


