{
  library(ovaliDB)
  library(RPostgres)
  library(DBI)
  library(tidyverse)
  library(microbenchmark)
  library(glue)
  library(tidyverse)
}


microbenchmark(hospitals(nature()), finess_rs(nature()))

draft <-  pool::dbPool(
  drv = RPostgres::Postgres(),
  dbname = 'draft',
  host     = "localhost",
  port     = "5432",
  user     = "postgres",
  password = "postgres"
) 


{
  tdb <- mco_dgf() |> tbl("tdb") |> collect() 
  dbWriteTable(draft, "tdb", tdb, overwrite = TRUE)
}

other_year <- function() {
  
  query <- "SELECT max(annee) AS year FROM tdb;"
  year <- NULL
  
  tryCatch(
    {
      year <- dbGetQuery(mco_dgf(), query)
    },
    error = function(cond) {}
  )
  
  if(is.null(year)) {return(NULL)}
  year[1, 1]
}

other_year()
most_recent_year(nature())

microbenchmark(other_year(), most_recent_year(nature()), times = 100)


microbenchmark(db(nature()),
               mco_dgf()   )

my_hospitals <- function() {
  
   query <- glue(
     '
     SELECT hosp FROM(
       SELECT DISTINCT ipe || \' - \' || "raison sociale" AS hosp
       ,                ipe
       FROM tdb
       WHERE annee = \'{other_year()}\'
       ORDER BY ipe
     )
     ;'
   )
   dbGetQuery(draft, query)
}

my_hospitals()

microbenchmark(my_hospitals(), ovaliDB::hospitals(nature()), times = 10)



exists_perf <- function() { mco_dgf() |> dbExistsTable("tdb") }
collect_perf <- function() { mco_dgf() |> tbl("tdb") |> collect() }

year_perf <- function() {
  (
    mco_dgf()
    |> tbl("tdb")
    |> summarise(max = max(annee))
    |> pull(max)
  )
}

year_perf()

mco_dgf |> tbl("asdf")

microbenchmark(year_perf(), most_recent_year(nature()),times = 10)
