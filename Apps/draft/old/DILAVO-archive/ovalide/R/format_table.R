#' Format table
#' @export
format_table <- function(table,
                         finess,
                         formatting = NULL) {
  if (is.null(table) || is.null(finess) || is.null(formatting)) {
    return(NULL)
  }
  
  if (nrow(table) == 0) {
    return(tibble::tibble("La fichier csv est vide" = ""))
  } 
  
  selected_columns   <- formatting$selected_columns
  translated_columns <- formatting$translated_columns
  filters            <- formatting$filters           
  row_names          <- formatting$row_names         
  rows_translated    <- formatting$rows_translated   
  proper_left_col    <- formatting$proper_left_col   
  undo_list          <- formatting$undo_list
  
 if ( ! all(selected_columns %in% colnames(table))) {
   return(tibble::tibble("table et format désynchronisés"))
 }
  
  (
    table
    %>% filter_on_finess(finess)
    %>% rename_1st_col_rows(proper_left_col, selected_columns,
                            row_names, rows_translated)
    %>% apply_all_filters(filters)
    %>% select_columns(selected_columns)
    %>% rename_cols(translated_columns)
    %>% arrange_marked_column()
    %>% format_percentage_columns()
  ) -> result
  
  if (nrow(result) == 0) {
    return(tibble::tibble("Pas de données pour cet établissment" =
                            glue::glue("FINESS : {finess}")))
  } else {
    return(result)
  }
}


#' @export
present_table <- function(table_name, nature, finess) {
  ovalide::load_ovalide_tables(nature)
  table <- ovalide::ovalide_table(nature, table_name)
  formatting <- ovalide::read_table_format(table_name, nature)
  format_table(table, finess, formatting)
}

#' @export
get_description <- function(table_name, nature) {
  formatting <- ovalide::read_table_format(table_name, nature)
  formatting$description
}

filter_on_finess <- function(result, finess) {
  dplyr::filter(result, finess_comp == finess)
}

rename_1st_col_rows <- function(result,
                                proper_left_col,
                                selected_columns,
                                row_names,
                                rows_translated) {
  
  if (proper_left_col && length(rows_translated) > 0
      && length(rows_translated) == length(row_names)) {
    first_col_name <- selected_columns[1]
    mapping <- tibble::tibble(row_names, rows_translated)
    
    join_by <- "row_names"
    names(join_by) <- first_col_name
    (
      result
      |> dplyr::left_join(mapping, by = join_by)
      |> dplyr::mutate( {{ first_col_name }} := rows_translated)
      |> dplyr::select(- rows_translated)
    ) -> result
  }
  result
}

arrange_marked_column <- function(df) {
  
  try_to_convert_to_numeric <- function(df, column) {
    suppressWarnings(num_col <- as.numeric(df[[ column ]]))
    if ( any(is.na(num_col)) ) {
      df
    } else {
      df[[ column ]] <- num_col
      df
    }
  }
  
  count_consecutive_stars <- function(character) {
    (
      character
      |> stringr::str_extract("[*]+")
      |> stringr::str_length()
    ) -> stars_count
    names(stars_count) <- character
    names(sort(stars_count))
  }
  column_to_arrange_order <- count_consecutive_stars(names(df))
  
  for ( col in column_to_arrange_order ) {
    df <- try_to_convert_to_numeric(df, col)
  }
  
  dplyr::arrange(df, dplyr::across(dplyr::all_of(column_to_arrange_order),
                                   dplyr::desc))
}

apply_all_filters <- function(result, filters) {

  apply_filter <- function(df, filter) {
    if (is.na(filter$value)) {
      dplyr::filter(df, !is.na(.data[[filter$column]]))
    } else {
      dplyr::filter(df, .data[[filter$column]] != filter$value)
    }
  }

  for (f in filters) result <- apply_filter(result, f)
  result
}

select_columns <- function(result, selected_columns) {
    dplyr::select(result, all_of(selected_columns))
}

rename_cols <- function(result, translated_columns) {
  names(result) <- translated_columns
  result
}

format_percentage_columns <- function(result) {
   dplyr::mutate(
    result,
    dplyr::across(dplyr::contains("%"),
      ~ scales::percent(as.numeric(.) / 100)))
}
