library(readr)
library(tidyverse)
library(stringr)

old_wd <- setwd("ovalide_data/draft/")
unzip("mco.dgf.2022.12.ovalide-tables-as-csv.zip")

guess_encoding_and_read_file <- function(filepath) {
  
  name_repair <- function(nm) {
    (empty <- nm == "")
    (fill_empty <- paste0("empty_", seq_len(sum(empty))))
    (nm[empty] <- fill_empty)
    nm <- tolower(nm)
    make.unique(nm, sep = "_")
  }
  
  if(file.size(filepath) > 0) {
    (
      filepath
      |> guess_encoding(threshold = 0)
      |> filter(row_number() == 1)
      |> pull(encoding)
    ) -> encoding
    
    data <- read_delim(
      filepath,
      delim = ";",
      locale = locale(encoding = encoding),
      name_repair = name_repair
    )
  }
  
  data
}

m11 <- guess_encoding_and_read_file("had.dgf.2022.11.t1q11cgrcg_1.csv")
m12 <- guess_encoding_and_read_file("had.dgf.2022.12.t1q11cgrcg_1.csv")

bind_rows(m11, m12)

identical(
  names(m11),
  names(m12))

col_types <- function(df) { lapply(df, class) }



(x <- waldo::compare(col_types(m11), col_types(m12)))

(which_cols <- purrr::map_lgl(names(m11), ~ str_detect(x, .)))
names(m11)[which_cols]

setwd(old_wd)
