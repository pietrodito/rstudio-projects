box::use(
  ./db_utils[
    db_connect,
  ],
)

db <- db_connect()


pick_file_in_ovalide_data <- function() {
  path <- "ovalide_data/"
  lock <- "dilavo.lock"
  if (file.exists(paste0(path, lock))) {
    NULL
  } else {
    files <- list.files(path)
    if(length(files) > 0) {
      paste0(path, files[1])
    } else {
      NULL
    }
  }
}


while(TRUE) {
  Sys.sleep(.1)
  file <- pick_file_in_ovalide_data()
  if( ! is.null(file)) {
    write(file, "log.txt", append = TRUE)
    file.remove(file)
  }
}