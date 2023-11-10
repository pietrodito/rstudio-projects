# app/logic/db_utils.R

box::use( ./log_utils [ log, ], )

#' @export
db_get_connection <- function(nature) {
  
  box::use(
    
    ./nature_utils
    [ db_name, ],
    
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
                dbname  = db_name(nature))
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

most_recent_year <- function(nature) {
  
  box::use(
    
    DBI
    [ dbExistsTable, dbGetQuery, ],
  )
  
  if(dbExistsTable(db_instant_connect(nature), "tdb")) {
    
    query <- "SELECT max(annee) AS year FROM tdb;"
    
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
save_build_table <- function(nature, table_name) {
  
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