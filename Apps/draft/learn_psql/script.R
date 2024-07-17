library(readr)
library(RPostgres)
library(tidyverse)

## - - - - - - - - - - - - - - - ##
## Create connection to draft db ##
## - - - - - - - - - - - - - - - ##
((
  dbConnect(Postgres(),
            host     = "localhost",
            port     = "5432",
            user     = "postgres",
            password = "postgres",
            dbname  = "draft")
) -> conn_draft)

## - - - - - - - - - - - - - ##
## execute sql script helper ##
## - - - - - - - - - - - - - ##
run <- function(file) dbSendQuery(conn_draft, statement = read_file(file))


dbRemoveTable(conn_draft, "sejours", fail_if_missing = FALSE)

((
  tribble(
    ~finess,     ~periode,     ~nombre,
    'A',          1L,            123L,
    'B',          1L,            456L,
    'C',          1L,            789L,
  )
) -> lines_to_insert)

dbCreateTable(conn_draft, "sejours", lines_to_insert)

dbAppendTable(conn_draft, "sejours", lines_to_insert)

((
  tribble(
    ~finess,     ~periode,     ~nombre,
    'A',          2,            124,
    'B',          2,            457,
    'C',          2,            790,
  )
) -> lines_to_insert)

dbAppendTable(conn_draft, "sejours", lines_to_insert)

## TODO create a summary table where all periods are added
## then a trigger to update summary when sejours has changed