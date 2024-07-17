.onLoad <- function(libname, pkgname) {
  
  host     <- Sys.getenv("DB_HOST"    , "localhost")
  port     <- Sys.getenv("DB_PORT"    , "5432")
  user     <- Sys.getenv("DB_USER"    , "postgres")
  password <- Sys.getenv("DB_PASSWORD", "postgres")
  
  box::use(
   ../../app/logic/nature_utils
    [ all_natures, suffixe,],
    
    purrr
    [ walk, ],
  )
  
  setup_connection <- function(nature) {
    
    the[[suffixe(nature)]] <- pool::dbPool(
      drv = RPostgres::Postgres(),
      dbname = suffixe(nature) |> toupper(),
      host = host,
      port = port,
      user = user,
      password = password
    )
    
  }
  
  walk(all_natures, setup_connection)
  
}