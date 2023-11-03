test_that("unzip and save had dgf ", {
  (
    testthat::test_path("test_data/had.dgf.2023.4.ovalide-tables-as-csv.zip")
    %>% read_zip_table_file(nature("had", "dgf"))
  )


  rds_result_path <- rds_filepath(nature("had", "dgf"))
  expected_file_size <- 975350L
  actual_size <- fs::file_size(rds_result_path) %>% as.integer()
  expect_equal(actual_size, expected_file_size)
})


test_that("unzip and save psy oqn ", {
  (
    testthat::test_path("test_data/psy.oqn.2023.4.ovalide-tables-as-csv.zip")
    %>% read_zip_table_file(nature("psy", "oqn"))
  )

  rds_result_path <- rds_filepath(nature("psy", "oqn"))
  expected_file_size <- 1446421L
  actual_size <- fs::file_size(rds_result_path) %>% as.integer()
  expect_equal(actual_size, expected_file_size)
})
