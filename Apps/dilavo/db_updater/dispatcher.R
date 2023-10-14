#!/usr/bin/Rscript --vanilla

box::use(

  ./db_updater_utils[
    pick_file_in_ovalide_data,
  ],

  app/logic/db_utils[
    dispatch_uploaded_file,
  ],
)

filepath <- NULL

while(TRUE) {
  if(is.null(filepath)) {
    Sys.sleep(.3)
  }
  filepath <- pick_file_in_ovalide_data("/ovalide_data/upload/")
  if(! is.null(filepath)) {
    dispatch_uploaded_file(filepath)
  }
}