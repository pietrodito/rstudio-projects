box::use(
  app/logic/db_utils
  [ db_connect, ],
  
  DBI
  [ dbExecute, dbGetQuery, ],
  
  glue
  [ glue, ],
  
  purrr
  [ pmap_chr, ],
)


db <- db_connect(db_name = "MCO_DGF")

tablename <- "t1d2covid_1"

answer <- dbGetQuery(db, glue(
  "SELECT EXISTS (
   SELECT 1
   FROM information_schema.tables
   WHERE table_name = '{tablename}'
 ) AS table_existence;" )
)



add_col <- function(col, postgres_type) {
  statement <- paste0(
    "ALTER TABLE ", tablename,
    " ADD COLUMN ", col, " ", postgres_type, ";"
  )
}
  
  
dbExecute(db, add_col("qwer", "text") )

dbGetQuery(db, glue(
  "SELECT * FROM {tablename};"
))
