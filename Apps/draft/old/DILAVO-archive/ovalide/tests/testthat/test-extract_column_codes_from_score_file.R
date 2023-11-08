extract_column_codes_from_score_file <-
  purrr::quietly(extract_column_codes_from_score_file)

test_that("extrait codes colonnes fichier score champ mco", {
  quiet_output <-
    extract_column_codes_from_score_file(test_path("test_data/mco_dgf.csv"))
  expect_equal(length(quiet_output$result), 21)
  expect_equal(sum(is.na(quiet_output$result)), 2)
})

test_that("extrait codes colonnes fichier score champ psy", {
  quiet_output <-
    extract_column_codes_from_score_file(test_path("test_data/psy_dgf.csv"))
  expect_equal(length(quiet_output$result), 27)
  expect_equal(sum(is.na(quiet_output$result)), 2)
})


