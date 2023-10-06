first_argument_position <- 5
dir_2_probe <- commandArgs()[first_argument_position]
dir_path <- paste0("ovalide_data/", dir_2_probe, "/")
lock_file <- "dilavo.lock"
lock_path <- paste0(dir_path, lock_file)
  

pick_file_in_ovalide_data <- function() {
  if (file.exists(lock_path)) {
    NULL
  } else {
    files <- list.files(dir_path)
    if(length(files) > 0) {
      paste0(dir_path, files[1])
    } else {
      NULL
    }
  }
}

init_message <- paste("Starting to probe:", dir_2_probe)

write(
  x      = init_message,
  file   = "log.txt",
  append = TRUE
 )

while(TRUE) {
  Sys.sleep(1)
  file <- pick_file_in_ovalide_data()
  if( ! is.null(file)) {
    write(dir_2_probe, "log.txt", append = TRUE)
    write(file, "log.txt", append = TRUE)
    file.remove(file)
  }
}
