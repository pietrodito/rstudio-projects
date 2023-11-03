test_that("add elt to selection",{
  
  (s1 <- selection())
  expect_equal(class(s1), "selection")
  
  (s1 <- add_table(s1, "qwer"))
  expect_equal(class(s1), "selection")
  expect_equal(length(s1), 1)
  
  (s1 <- add_table(s1, "asdf"))
  expect_equal(class(s1), "selection")
  expect_equal(length(s1), 2)
  
  (s1 <- add_table(s1, "qwer"))
  expect_equal(class(s1), "selection")
  expect_equal(length(s1), 2)

  (s1 <- rm_table(s1, "asdf"))
  expect_equal(class(s1), "selection")
  expect_equal(length(s1), 1)
  
  (s1 <- add_table(s1, "asdf"))
  expect_equal(class(s1), "selection")
  expect_equal(length(s1), 2)

  
  expected_file <- "ovalide_data/mco_dgf/column A.selection"
  if (fs::file_exists(expected_file)) fs::file_delete(expected_file)
  write_selection(s1, ovalide::nature(), "column A")
  expect_true(fs::file_exists(expected_file))
  expect_equal(112, fs::file_size(expected_file) |> as.numeric())
})

