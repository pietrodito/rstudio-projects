test_that("contact class works", {
  x <- contacts()
  x <- add_contact(x, "qwer@x.com")
  x <- add_contact(x, "asdf@y.com")
  x <- rm_contact(x, "qwer@x.com")
  expect_equal(as.character(x), "asdf@y.com")
})

## interactive tests
run_interactive <- function() {
  devtools::load_all()
  library(ovalide)
  
  
  x <- contacts()
  x <- add_contact(x, "qwer@x.com")
  x <- add_contact(x, "asdf@y.com")
  x <- rm_contact(x, "qwer@x.com")
  str(x)
  
}; if (sys.nframe() == 0) run_interactive()


