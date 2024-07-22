.onLoad <- function(libname, pkgname) {
  
  host     <- Sys.getenv("DB_HOST"    , "localhost")
  port     <- Sys.getenv("DB_PORT"    , "5432")
  user     <- Sys.getenv("DB_USER"    , "postgres")
  password <- Sys.getenv("DB_PASSWORD", "postgres")
  
  box::use(
    
    purrr
    [ walk, ],
  )
  
  setup_connection <- function(nature) {
    
    the[[suffixe(nature)]] <- pool::dbPool(
      drv = RPostgres::Postgres(),
      dbname = db_name(nature),
      host = host,
      port = port,
      user = user,
      password = password
    )
    
  }
  
  update_logs_trick <- list(list(field = "upd", status = "log"))
  
  walk(c(all_natures, update_logs_trick), setup_connection)
}