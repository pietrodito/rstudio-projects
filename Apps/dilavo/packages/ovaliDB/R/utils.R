db_get_connection_by_name <- function(db_name) {
  box::use(
    RPostgres
    [ Postgres ],
    
    DBI
    [ dbConnect, dbDisconnect ],
  )
  
  host     <- NULL
  port     <- NULL
  user     <- NULL
  password <- NULL
  
  if(Sys.getenv("RUN_IN_DOCKER") == "YES") {
    host     <- Sys.getenv("DB_HOST"    )
    port     <- Sys.getenv("DB_PORT"    )
    user     <- Sys.getenv("DB_USER"    )
    password <- Sys.getenv("DB_PASSWORD")
  } else {
    host     <- "localhost"
    port     <- "5432"
    user     <- "postgres"
    password <- "postgres"
  }
  tryCatch(
    {
      dbConnect(Postgres(),
                host     = host    ,
                port     = port    ,
                user     = user    ,
                password = password,
                dbname  = db_name)
    },
    error = function(cond) {
      message("Unable to connect to db:")
      message(cond |> conditionMessage())
      NULL
    }
  ) -> db
  
  if (is.null(db)) {
    log("> Failed to connect to  ", db_name(nature))
  } else 
    db
}

#' @export
db_get_connection <- function(nature) {
  db_get_connection_by_name(db_name(nature))
}

#' @export
db_query <- function(nature, query, params = NULL) {
  
  tryCatch(
    DBI::dbGetQuery(db(nature),
                    query,
                    params = params),
    error = function(cond) {
      message(glue::glue(
          "Query failure in DB {db_name(nature)}:
           {query}"))
    }
  )
}

#' @export
db_instant_connect <- function(nature) {
  
  box::use(
    withr
    [ defer_parent, ],
    
    DBI
    [ dbDisconnect ],
  )
  
  db <- db_get_connection(nature)
  
  if (! is.null(db)) {
    defer_parent(dbDisconnect(db))
  }
  
  db
}

#' @export
db_execute <- function(nature, query, params = NULL) {
  
  tryCatch(
    DBI::dbGetQuery(db(nature),
                    query,
                    params = params),
    error = function(cond) {
      message(glue::glue(
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
   
   query <- glue::glue("SELECT max(periode) AS period FROM tdb
                    WHERE annee = '{most_recent_year(nature)}';")
   
   period <- NULL
   period <- db_query(nature, query)
   
   if(is.null(period)) {return(NULL)}
   period[1, 1]
   
 }
 
#' @export
finess_rs <- function(nature, year = most_recent_year(nature)) {
  
  if (is.null(year)) { return(NULL) }
  
   query <- glue::glue(
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

#' @export
db_update_logs <- function(field, status, type, timestamp) {
  
  box::use(
    
    DBI
    [ dbDisconnect, dbWriteTable, ],
    
    dplyr
    [ collect, rename, rows_upsert, tbl, ],
    
    tibble
    [ tibble, ],
  )
  
  (
    tibble(champ = field, statut = status, col = timestamp)
    |> rename( !! type := col)
  ) -> new_line
  
  (
    upd_log()
    |> tbl("logs")
    |> collect()
    |> rows_upsert(new_line, by = c("champ", "statut"))
  ) -> new_logs
  
  dbWriteTable(upd_log(), "logs", new_logs, overwrite = TRUE)
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