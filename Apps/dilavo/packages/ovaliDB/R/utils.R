#' @export
db_query <- function(nature, query, params = NULL) {
  
  box::use(
    ../../app/logic/nature_utils
    [ db_name, ],
    
    DBI
    [ dbGetQuery, ],
  )
  
  dbGetQuery(db(nature),
             query,
             params = params
  )
}

#' @export
db_execute <- function(nature, query, params = NULL) {
  
  box::use(
    app/logic/nature_utils
    [ db_name, ],
    
    DBI
    [ dbExecute, ],
  )
  
  dbExecute(db(nature),
            query,
            params = params
  )
}

#' @export
db_table_exists <- function(nature, table) {
  
  box::use(
    DBI
    [ dbExistsTable, ],
  )
  
  dbExistsTable(db(nature), table)
}

 #' @export
 most_recent_year <- function(nature) {
   
   if(db_table_exists(nature, "tdb")) {
     
     query <- "SELECT max(annee) AS year FROM tdb;"
     
     year <- db_query(nature, query)
     
     year[1, 1]
   } else {
     NULL
   }
 }
 
#  #' @export
#  most_recent_period <- function(nature) {
#    
#    box::use(
#      DBI
#      [ dbExistsTable, dbGetQuery, ],
#      
#      glue
#      [ glue, ],
#    )
#    
#    if(dbExistsTable(db_instant_connect(nature), "tdb")) {
#      
#      query <- glue("SELECT max(periode) AS period FROM tdb
#                      WHERE annee = '{most_recent_year(nature)}';")
#      
#      year <- db_query(nature, query)
#      
#      year[1, 1]
#    } else {
#      NULL
#    }
#  }
#  
#  #' @export
#  hospitals <- function(nature, year = most_recent_year(nature)) {
#    
#    box::use(
#      dplyr
#      [ collect, distinct, filter, mutate, pull, select, tbl, ],
#      
#      glue
#      [ glue, ],
#    )
#    
#    if (! is.null(year)) {
#      
#      tdb <- tbl(db_instant_connect(nature), "tdb")
#      
#      (
#        tdb
#        |> filter(annee == year)
#        |> select(ipe, `raison sociale`)
#        |> distinct()
#        |> collect()
#        |> mutate(Étabissement = paste0( ipe, " - ", `raison sociale`))
#        |> pull(Étabissement)
#        |> sort()
#      ) 
#      
#    } else {
#      NULL
#    }
#  }
#  
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