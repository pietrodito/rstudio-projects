box::use(
  
  ./db_utils
  [ db_get_connection, ],
  
  ./nature_utils
  [ nature, ],
  
)

assign("conn_mco_dgf", db_get_connection(nature()), envir = .GlobalEnv)
