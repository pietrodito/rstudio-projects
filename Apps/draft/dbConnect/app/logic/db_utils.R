box::use(
  RPostgres[Postgres],
  DBI[dbConnect],
)

#' @export
connect_db <- function(host     = "db",
                       port     = "5432",
                       user     = "postgres",
                       password = "asdf") {
  
  tryCatch(
    {
      dbConnect(Postgres(),
                host = host,
                port = port,
                user = user,
                password = password)
    },
    error = function(cond) {
      message("Unable to connect to db:")
      message(cond |> conditionMessage())
      return(NULL)
    }
  )
}