library(jsonlite)
library(RPostgres)
library(DBI)
library(dplyr)
library(purrr)


host     <- "localhost"
port     <- "5432"
user     <- "postgres"
password <- "postgres"
  
tryCatch(
  {
    dbConnect(Postgres(),
              host     = host    ,
              port     = port    ,
              user     = user    ,
              password = password,
              dbname  = "MCO_DGF")
  },
  error = function(cond) {
    message("Unable to connect to db:")
    message(cond |> conditionMessage())
    NULL
  }
) -> db

(bt <- tbl(db, "build_tables"))

# (l <- map(letters, identity))
# 
# row <- data.frame(
#   name = "x",
#   details = serializeJSON(l)
# )
# 
# rows_upsert(
#   bt,
#   row,
#   by = "name",
#   in_place = TRUE,
#   copy = TRUE
# )

q <- dbGetQuery(db, "SELECT * FROM build_tables;")

q
unserializeJSON(q[1, 2])
