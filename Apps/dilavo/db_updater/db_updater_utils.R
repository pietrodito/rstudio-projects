box::use(
  ./db_utils[
    db_connect,
  ],
  
  utils[
    str,
  ],
)
  
pick_file_in_ovalide_data <- function(dir_path, lock_path) {
  if (dir_not_locked(lock_path)) {
    first_file_name(dir_path)
  }
}

treat_file <- function(dir_2_probe, filepath) {
  
  log("---------------------------")
  log("         ", dir_2_probe |> toupper())
  log("---------------------------")
  
  filename <- basename(filepath)
  
  if (ends_with_csv(filename)) {
    log("> CSV file detected: ", filepath)
    treat_csv_file(filepath)
  }
  
  if (ends_with_zip(filename)) {
    log("> ZIP file detected: ", filepath)
  }
  
  if (! ends_with_csv(filename) && ! ends_with_zip(filename)) {
    log("> file extension not recognized: ", filepath)
  }
  
  file.remove(filepath)
}

treat_csv_file <- function(filepath) {
  (
    filepath
    |> extract_info_from_csv_filename()
    |> update_ssr_to_smr()
  ) -> info
  
  if ( csv_info_are_correct(info) ) {
    load_data_to_db(info, filepath)
  } else {
    log("> The file does not seem to have a proper name")
  }
}

update_ssr_to_smr <- function(info) {
  if (info$field == "ssr") info$field <- "smr"
}

csv_info_are_correct <- function(info) {
    info$field %in% c("mco", "had", "psy", "smr") &&
    info$status %in% c("oqn", "dgf")                     &&
    as.integer(info$year) > 2023                         &&
    as.integer(info$month) %in% 1:12
}

load_data_to_db <- function(info, filepath) {
  log("> Trying to connect to database...")
  db <- db_connect()
  log("Connected to: ", format(db))
  
}

extract_info_from_csv_filename <- function(filepath) {
  filename <- basename(filepath)
  infos <- strsplit(filename, "\\.") |> unlist()
  info <- list(
    field  = infos[1],
    status = infos[2],
    year   = infos[3],
    month  = infos[4]
  )
  
  log(info, list = T)
  
  info
}

dir_not_locked <- function(lock_path) {
  ! file.exists(lock_path)
}

first_file_name <- function(dir_path) {
  files <- list.files(dir_path)
  if(length(files) > 0) {
    paste0(dir_path, files[1])
  } else {
    NULL
  }
}

log <- function(..., list = F) {
  
  args <- list(...)
  
  logpath <- "/logs/log.txt"
  
  if(list) {
    values <- args[[1]] |> unlist()
    names <- names(values)
    mapply(
      function(name, val) {
        write(
          paste0(name, ": ", val),
          logpath,
          append = TRUE
        )
      },
      name = names, val = values
    )
  } else {
    write(
      x      = paste0(...),
      file   = logpath,
      append = TRUE
    )
  }
}

ends_with_csv <- function(x) {
  grepl("\\.csv$", x)
}

ends_with_zip <- function(x) {
  grepl("\\.zip$", x)
}