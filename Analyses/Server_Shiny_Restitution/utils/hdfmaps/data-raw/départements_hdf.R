library(hdfmaps)

dpts_hdf <- c(
  nord          = "59",
  pas_de_calais = "62",
  aisne         = "02",
  somme         = "80",
  oise          = "60"
)

walk2(names(dpts_hdf),
     dpts_hdf, function(.x, .y) {
       
  assign(.x, (
    codes_postaux
    |> filter(ID |> str_starts(.y))
    |> st_union()
  ))
       
  eval(parse(text = paste0(
    "usethis::use_data(", .x, ", overwrite = TRUE)"
  )))
})

