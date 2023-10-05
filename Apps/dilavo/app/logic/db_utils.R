# app/logic/db_utils.R

box::use(
  RPostgres[Postgres],
  DBI[dbConnect],
)

#' @export
db_connect <- function() {
  
  tryCatch(
    {
      dbConnect(Postgres(),
                host     = Sys.getenv("DB_HOST"    ),
                port     = Sys.getenv("DB_PORT"    ),
                user     = Sys.getenv("DB_USER"    ),
                password = Sys.getenv("DB_PASSWORD"))
    },
    error = function(cond) {
      message("Unable to connect to db:")
      message(cond |> conditionMessage())
      return(NULL)
    }
  )
}