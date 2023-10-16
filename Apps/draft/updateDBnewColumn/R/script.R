### Setup

library(RPostgres)

db <- dbConnect(Postgres(),
          host     = Sys.getenv("DB_HOST"    ),
          port     = Sys.getenv("DB_PORT"    ),
          user     = Sys.getenv("DB_USER"    ),
          password = Sys.getenv("DB_PASSWORD"),
          dbname  = "postgres")


df <- data.frame(
  x = 1
)

dbWriteTable(db, "df", df, overwrite = T)


find_postgres_types <- function(new_cols, data) {
  
  types <- purrr::map(new_cols, function(col) {
    tibble::tibble(
      col = col,
      R_type = class(data[[col]])
    )
  })
  
  types <- do.call(dplyr::bind_rows, types)
  
  R_2_db_types <- tibble::tribble(
    ~R_type    , ~postgres_type,
    "numeric"  , "double precision",
    "character", "text",
    "Date"     , "date"
  )
  
  (
    types
    |> dplyr::left_join(R_2_db_types)
    |> dplyr::select(col, postgres_type)
  )
}

create_new_cols <- function(table, db, types) {
  add_col <- function(col, postgres_type) {
    statement <- paste0(
      "ALTER TABLE ", table,
      " ADD COLUMN ", col, " ", postgres_type, ";"
    )
  }
  
  statements <- purrr::pmap_chr(types, add_col)
  
  purrr::walk(statements, function(s) {
    rs <- dbSendStatement(db, s)
    dbClearResult(rs)
  })
}

### Append data with new and missing cols
append_data <- function(data, table, db) {
  
  old_cols <- dbListFields(db, "df")
  
  new_cols <- setdiff(names(new_df), cols)
  
  types <- find_postgres_types(new_cols, data)
  
  create_new_cols(table, db, types)
  
  dbAppendTable(db, table, new_df)
}


new_df <- data.frame(
  y = 3,
  z = "asdf",
  t = as.Date("2023-03-18")
)

append_data(new_df, "df", db)

print(dbReadTable(db, "df"))


