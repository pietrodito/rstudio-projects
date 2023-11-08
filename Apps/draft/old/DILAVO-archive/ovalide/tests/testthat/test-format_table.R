load_ovalide_tables(nature())

(table <- ovalide_tables(nature())[["T1D2RTP_1"]])

(finess <- "590780193")

formatting <- list(
  selected_columns = c(
    "_NAME_", "COL1", "COL2", "COL4", "COL5", "COL6"
  ),
  
  translated_columns = c(
    "Var", "COL1", "COL2", "COL4", "COL5", "COL6"
  ),
  filters            = list(list(
    select_name = paste("COL1", "<>", 0),
    select_choice = paste0("COL1", "_", 0),
    column = "COL1",
    value = 0
  )),
  row_names          =
    c("per"    ,  "nbrsa" ,  "cmd90"     , "hper",  "nbrsa0",
      "typsejb", "ghs9999", "nbrsah0"    , "nbjh0", "nbjJT0",
      "nbuhcd" , "nbabott", "nbrsaseance", "nbseances"),
  rows_translated    =
    c("per"    ,  "nbrsa" ,  "cmd 90"     , "hper",  "nbrsa0",
      "typsejb", "ghs9999", "nbrsah0"    , "nbjh0", "nbjJT0",
      "nbuhcd" , "nbabott", "nb rsa seance", "nbseances"),
  proper_left_col    = TRUE,
  undo_list = NULL
)


output <- format_table(table, finess, formatting)

test_that("format table works",{
  
  expect_equal(ncol(output), 6)
  expect_equal(nrow(output), 12)
  expect_equal(output$Var[6], "nb rsa seance")
  
})
