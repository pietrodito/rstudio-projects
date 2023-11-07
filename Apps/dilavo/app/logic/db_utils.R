# app/logic/db_utils.R

box::use( ./log_utils [ log, ], )

#' @export
db_connect <- function(nature) {
  
  box::use(
    
    ./nature_utils
    [ db_name, ],
    
    RPostgres
    [ Postgres ],
    
    DBI
    [ dbConnect ],
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
  
  db <- db_connect(nature)
  
  dbGetQuery(db, query, params = params)
}

## TODO get most recent year exploring the table key_value
most_recent_year <- function(nature) {
  
  box::use(
    
    DBI
    [ dbExistsTable, dbGetQuery, ],
  )
  
  db <- db_connect(nature)
  
  if(dbExistsTable(db, "tdb")) {
    
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
    DBI
    [ dbDisconnect, ],
    
    dplyr
    [ collect, distinct, filter, select, tbl, ],
    
    glue
    [ glue, ],
  )
  
  if (! is.null(year)) {
    
    db <- db_connect(nature)
    tdb <- tbl(db, "tdb")
    
    (
      tdb
      |> filter(annee == year)
      |> select(ipe, `raison sociale`)
      |> distinct()
      |> collect()
    ) -> result
    
    dbDisconnect(db)
    
    result
  } else {
    NULL
  }
}