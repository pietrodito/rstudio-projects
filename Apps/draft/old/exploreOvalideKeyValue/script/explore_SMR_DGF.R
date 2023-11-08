library(tidyverse)

(
  "data/"
  |> dir_ls(regexp = "*.csv")
  |> map(read_csv2)
) -> dfs


only_one_period <- function(df) {
  length(unique(df$periode)) == 1
}

has_period_column <- function(df) {
  "periode" %in% names(df)
}

(
  dfs
  |> keep(function(df) nrow(df) > 0)
  |> map_lgl(only_one_period)
)

(
  dfs
  |> keep(function(df) nrow(df) > 0)
  |> discard(has_period_column)
)


df <- read_csv("dup_col.csv", name_repair = "minimal")

df$asdf
