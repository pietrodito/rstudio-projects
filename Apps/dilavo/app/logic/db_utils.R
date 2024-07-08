# app/logic/db_utils.R

box::use( ./log_utils [ log, ], )

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
  
  box::use(
    ./nature_utils
    [ db_name, ],
  )
  
  db_get_connection_by_name(db_name(nature))
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
  
 db <- db_get_connection_by_name("UPD_LOG") 
 
 
 (
   tbl(db, "logs")
   |> collect()
   |> rows_upsert(new_line, by = c("champ", "statut"))
 ) -> new_logs
   
 dbWriteTable(db, "logs", new_logs, overwrite = TRUE)
 dbDisconnect(db)
}

#' @export
db_update_logs_table <- function() {
  
  box::use(
    DBI
    [ dbDisconnect ],
    
    dplyr
    [ arrange, collect, mutate_at, rename_all, tbl, vars, ],
    
    lubridate
    [ day, hour, minute, month, second, year, ymd_hms, ],
    
    stringr
    [ str_sub, ],
    
    withr
    [ defer, ],
  )
  
  db <- db_get_connection_by_name("UPD_LOG") 
  if (! is.null(db)) {
    defer(dbDisconnect(db))
  }
  
  readable_date <- function(x) {
    d <- ymd_hms(x)
    ifelse(is.na(x),
           "", 
           paste0(
             "Le ", day(d), "/", month(d), "/", year(d),
             " à ", hour(d), "h", minute(d)
           )
    )
  }
  
  # 2024-01-05T07:57:31Z
  
  (
    
    tbl(db, "logs") 
    |> collect()
    |> arrange(champ, statut)
    |> rename_all(function(x) {
      c("Champ", "Statut",
        "MàJ fichiers CSV", "MàJ tableau de bord", "MàJ Clé / Valeur")
    })
    |> mutate_at(vars(starts_with("MàJ")), readable_date)
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
db_query <- function(nature, query, params = NULL) {
  
  box::use(
    app/logic/nature_utils
    [ db_name, ],
    
    DBI
    [ dbGetQuery, ],
  )
  
  dbGetQuery(db_instant_connect(nature),
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
  
  dbExecute(db_instant_connect(nature),
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
  
  dbExistsTable(db_instant_connect(nature), table)
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

#' @export
most_recent_period <- function(nature) {
  
  box::use(
    DBI
    [ dbExistsTable, dbGetQuery, ],
    
    glue
    [ glue, ],
  )
  
  if(dbExistsTable(db_instant_connect(nature), "tdb")) {
    
    query <- glue("SELECT max(periode) AS period FROM tdb
                    WHERE annee = '{most_recent_year(nature)}';")
    
    year <- db_query(nature, query)
    
    year[1, 1]
  } else {
    NULL
  }
}

#' @export
hospitals <- function(nature, year = most_recent_year(nature)) {
  
  box::use(
    dplyr
    [ collect, distinct, filter, mutate, pull, select, tbl, ],
    
    glue
    [ glue, ],
  )
  
  if (! is.null(year)) {
    
    tdb <- tbl(db_instant_connect(nature), "tdb")
    
    (
      tdb
      |> filter(annee == year)
      |> select(ipe, `raison sociale`)
      |> distinct()
      |> collect()
      |> mutate(Étabissement = paste0( ipe, " - ", `raison sociale`))
      |> pull(Étabissement)
      |> sort()
    ) 
    
  } else {
    NULL
  }
}

#' @export
build_tables <- function(nature) {
  
  box::use(
    dplyr
    [ collect, distinct, filter, mutate, pull, select, tbl, ],
    
    glue
    [ glue, ],
  )
  
  build_tables <- tbl(db_instant_connect(nature), "build_tables")
  
  (
    build_tables
    |> select(name)
    |> collect()
    |> pull(name)
    |> sort()
  ) 
}

#' @export
save_build_table_details <- function(nature, table_name, details) {
  
  box::use(
    dbplyr
    [ copy_inline, ],
    
    dplyr
    [ rows_upsert, tbl, ],
    
    glue
    [ glue, ],
    
    jsonlite
    [ serializeJSON, ],
  )
  
  db <- db_instant_connect(nature)
  
  build_tables <- tbl(db, "build_tables")
  
  new_row <- copy_inline(db, data.frame(
    name = table_name,
    details = serializeJSON(details) |> as.character()
  ))
  
  rows_upsert(
    build_tables,
    new_row,
    by = c("name"),
    in_place = TRUE
  ) 
  
}

#' @export
load_build_table_details <- function(nature, table_name) {
  
  box::use(
    glue
    [ glue, ],
    
    jsonlite
    [ unserializeJSON, ],
  )
  
  query_result <-
    db_query(
      nature,
      glue(
        "SELECT details FROM build_tables WHERE name = '{table_name}';"
      )
    )
  
  if(nrow(query_result) == 1) {
    unserializeJSON(query_result[1, 1])
  } else {
    NULL
  }
}

#' @export
del_build_table_details <- function(nature, table_name) {
  
  box::use(
    DBI
    [ dbRemoveTable, ],
    
    glue
    [ glue, ],
  )
  
  query <- glue("DELETE FROM build_tables WHERE name = '{table_name}' ")
  
  db_execute(nature, query)
}

#' @export
db_reset <- function(nature) {
  
  box::use(
    DBI
    [ dbListTables, dbRemoveTable, ],
    
    purrr
    [ walk, ],
  )
  
  tables <- dbListTables(db_instant_connect(nature))
  tables <- base::setdiff(tables, "build_tables")
  walk(tables, ~ dbRemoveTable(db_instant_connect(nature), .x))
}

#' @export
db_reset_all <- function() {
 box::use(
   app/logic/nature_utils
   [ all_natures, ],
 ) 
  
 lapply(all_natures, db_reset)
}