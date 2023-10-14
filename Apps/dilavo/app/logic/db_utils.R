# app/logic/db_utils.R

box::use(
  ../../app/logic/log_utils[
    log,
  ]
)

box::use(
  RPostgres[
    Postgres
    ],
  
  DBI[
    dbConnect
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
  if(filename_is_correct(filename)) {
    log("> File with correct filename: ", filename)
    
    info <- extract_info_from_filename(filename)
    
    dir_to_dispatch <- paste0("/ovalide_data/",
                              info$field, "_", info$status, "/")
    
    log("> The file will be moved to ", dir_to_dispatch)
    
    file.copy(filepath, dir_to_dispatch)
    file.remove(filepath)
    
    db_name <- basename(dir_to_dispatch)
    
    probe_cmd <- paste("./probe_dir.R", db_name, "&")
    log("> Updating database: ", probe_cmd)
    system(probe_cmd)
  } else {
    log("> File deleted because filename is not correct: ", filename)
    file.remove(filepath)
  }
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


