#' @export
db_query <- function(nature, query, params = NULL) {
  
  tryCatch(
    DBI::dbGetQuery(db(nature),
                    query,
                    params = params),
    error = function(cond) {
      message(glue(
          "Query failure in DB {db_name(nature)}:
           {query}"))
    }
  )
}

#' @export
db_execute <- function(nature, query, params = NULL) {
  
  tryCatch(
    DBI::dbGetQuery(db(nature),
                    query,
                    params = params),
    error = function(cond) {
      message(glue(
        "Query failure in DB {db_name(nature)}:
           {query}"))
    }
  )
  
}


 #' @export
 most_recent_year <- function(nature) {
   
   query <- "SELECT max(annee) AS year FROM tdb;"
   
   year <- NULL
   year <- db_query(nature, query)
   
   if(is.null(year)) {return(NULL)}
   year[1, 1]
 }
 
 
 #' @export
 most_recent_period <- function(nature) {
   
   query <- glue("SELECT max(periode) AS period FROM tdb
                    WHERE annee = '{most_recent_year(nature)}';")
   
   period <- NULL
   period <- db_query(nature, query)
   
   if(is.null(period)) {return(NULL)}
   period[1, 1]
   
 }
 
#' @export
finess_rs <- function(nature, year = most_recent_year(nature)) {
  
  if (is.null(year)) { return(NULL) }
  
   query <- glue(
     '
     SELECT hospital FROM(
       SELECT DISTINCT ipe || \' - \' || "raison sociale" AS hospital
       ,                ipe
       FROM tdb
       WHERE annee = \'{year}\'
       ORDER BY ipe
     )
     ;'
   )
   db_query(nature, query)
  
}

#' @export 
extract_finess <- function(finess_rs) {
  substr(finess_rs, 1, 9)
}

#' @export 
extract_rs <- function(finess_rs) {
  stringr::str_sub(finess_rs, 13)
}

#  #' @export
#  build_tables <- function(nature) {
#    
#    box::use(
#      dplyr
#      [ collect, distinct, filter, mutate, pull, select, tbl, ],
#      
#      glue
#      [ glue, ],
#    )
#    
#    build_tables <- tbl(db_instant_connect(nature), "build_tables")
#    
#    (
#      build_tables
#      |> select(name)
#      |> collect()
#      |> pull(name)
#      |> sort()
#    ) 
#  }
#  
#  #' @export
#  save_build_table_details <- function(nature, table_name, details) {
#    
#    box::use(
#      dbplyr
#      [ copy_inline, ],
#      
#      dplyr
#      [ rows_upsert, tbl, ],
#      
#      glue
#      [ glue, ],
#      
#      jsonlite
#      [ serializeJSON, ],
#    )
#    
#    db <- db_instant_connect(nature)
#    
#    build_tables <- tbl(db, "build_tables")
#    
#    new_row <- copy_inline(db, data.frame(
#      name = table_name,
#      details = serializeJSON(details) |> as.character()
#    ))
#    
#    rows_upsert(
#      build_tables,
#      new_row,
#      by = c("name"),
#      in_place = TRUE
#    ) 
#    
#  }
#  
#  #' @export
#  load_build_table_details <- function(nature, table_name) {
#    
#    box::use(
#      glue
#      [ glue, ],
#      
#      jsonlite
#      [ unserializeJSON, ],
#    )
#    
#    query_result <-
#      db_query(
#        nature,
#        glue(
#          "SELECT details FROM build_tables WHERE name = '{table_name}';"
#        )
#      )
#    
#    if(nrow(query_result) == 1) {
#      unserializeJSON(query_result[1, 1])
#    } else {
#      NULL
#    }
#  }
#  
#  #' @export
#  del_build_table_details <- function(nature, table_name) {
#    
#    box::use(
#      DBI
#      [ dbRemoveTable, ],
#      
#      glue
#      [ glue, ],
#    )
#    
#    query <- glue("DELETE FROM build_tables WHERE name = '{table_name}' ")
#    
#    db_execute(nature, query)
#  }
#  
#  #' @export
#  db_reset <- function(nature) {
#    
#    box::use(
#      DBI
#      [ dbListTables, dbRemoveTable, ],
#      
#      purrr
#      [ walk, ],
#    )
#    
#    tables <- dbListTables(db_instant_connect(nature))
#    tables <- base::setdiff(tables, "build_tables")
#    walk(tables, ~ dbRemoveTable(db_instant_connect(nature), .x))
#  }
#  
#  #' @export
#  db_reset_all <- function() {
#   box::use(
#     app/logic/nature_utils
#     [ all_natures, ],
#   ) 
#    
#   lapply(all_natures, db_reset)
#  }