#' @export
formatting <- function(selected_columns   = NULL,
                       translated_columns = NULL,
                       filters            = NULL,
                       row_names          = NULL,
                       rows_translated    = NULL,
                       proper_left_col    = FALSE,
                       description        = "",
                       undo_list          = NULL) {
  structure(
    list(
      selected_columns   = selected_columns  ,
      translated_columns = translated_columns,
      filters            = filters           ,
      row_names          = row_names         ,
      rows_translated    = rows_translated   ,
      proper_left_col    = proper_left_col   ,
      description        = description,
      undo_list          = undo_list
    ),
    class = "formatting"
  )
}

format_filepath <- function(table_name, nature) {
  paste0(data_save_dir(nature), "/", table_name, ".format")
}

#' @export
table_format_last_changed <- function(table_name, nature) {
  if (fs::file_exists(format_filepath(table_name, nature))) {
    file <- format_filepath(table_name, nature)
    info <- fs::file_info(file)
    info$modification_time 
  } else {
    NULL
  }
}

#' @export
write_table_format <- function(table_name, nature, formatting) {
  readr::write_rds(formatting, format_filepath(table_name, nature))
}

#' @export
read_table_format <- function(table_name, nature) {
  if ( is.null(table_name)) return(NULL)
  if ( ! fs::file_exists(format_filepath(table_name, nature))) {
    
    create_empty_formatting(table_name, nature)
    
  } else {
    
    readr::read_rds(format_filepath(table_name, nature))
  }
}

create_empty_formatting <- function(table_name, nature) {
  ((
    ovalide_table(nature, table_name)
    |> names()
    |> setdiff("finess_comp")
  ) -> original_table_names)
  
  formatting(selected_columns = original_table_names,
             translated_columns = original_table_names)
}