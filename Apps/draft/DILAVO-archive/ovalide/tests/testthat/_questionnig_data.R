library(ovalide)
library(purrr)

## which columns are in all table?
all_colnames <- map(names(the), function(.cs) {
  map(names(the[[.cs]]), function(.tb) {
    names(the[[.cs]][[.tb]])
  })
}) %>% flatten()

(
  all_colnames
  %>% discard(~ length(.x) == 0)
  %>% reduce(intersect)
)

# which tables has finess_comp starting with X

has_column_finess_comp_starting_with_X <- function(df) {
  if("finess_comp" %in% names(df)) {
    stringr::str_starts(df$finess_comp[1], "X")
  } else {
    TRUE
  }
}


map(names(the), function(.cs) {
  map(names(the[[.cs]]), function(.tb) {
    (
      the[[.cs]][[.tb]]
      %>% has_column_finess_comp_starting_with_X()
    )
  })
}) |> unlist() |> all()
