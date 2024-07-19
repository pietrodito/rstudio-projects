#!/usr/bin/Rscript --vanilla

box::use(
  ./db_updater_utils
  [ dispatch_uploaded_file, pick_file_in_dir, ],
)

filepath <- NULL


while(TRUE) {

  filepath <- pick_file_in_dir("/ovalide_data/upload/")

  if(is.null(filepath)) {  Sys.sleep(.3); next }

  dispatch_uploaded_file(filepath)
}