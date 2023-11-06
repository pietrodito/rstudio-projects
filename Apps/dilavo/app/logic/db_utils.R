# app/logic/db_utils.R

box::use(
  ./log_utils
  [ log, ],
)

#' @export
db_connect <- function(db_name) {
  
  box::use(
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
                dbname  = db_name)
    },
    error = function(cond) {
      message("Unable to connect to db:")
      message(cond |> conditionMessage())
      NULL
    }
  ) -> db
  
  if (is.null(db)) {
    log("> Failed to connect to  ", db_name)
  }
  
  db
}

## TODO get most recent year exploring the table key_value
most_recent_year <- function(nature) {
  
  box::use(
    app/logic/nature_utils
    [ db_name, ],
    
    app/logic/db_utils
    [ db_connect, ],
    
    DBI
    [ dbExistsTable, dbGetQuery, ],
  )
  
  db <- db_connect(nature |> db_name())
  
  if(dbExistsTable(db, "key_value")) {
    
    query <- "SELECT max(annee) AS year FROM key_value;"
    
    year <- dbGetQuery(db, query)
    
    year[1, 1]
  } else {
    NULL
  }
  
}

#' @export
list_of_hospitals <- function(nature, year = most_recent_year(nature)) {
  
  if (! is.null(year)) {
    
  } else {
    NULL
  }
}