box::use(
  shiny[testServer],
  testthat[...],
)
box::use(
  app/main[...],
)

test_that("main server works", {
  testServer(server, {
    ## TODO write tests
    ## this one fails coz main.R has been modified
    expect_true(grepl(x = output$message$html, pattern = "Check out Rhino docs!"))
  })
})
