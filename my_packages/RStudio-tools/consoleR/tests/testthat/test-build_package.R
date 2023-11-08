package_installed <- function(package_name) {
  all_packages <- installed.packages()[, 1]
  package_name %in% all_packages
}

remove.packages <- purrr::quietly(remove.packages)

setup <- function(package_name) {

  if (package_installed(package_name)) remove.packages(package_name)
  build_package(testthat::test_path(package_name), quiet = T)
}

test_that("package is installed", {
  package_name <-  "somePackageForTest"

  setup(package_name)
  withr::defer(remove.packages(package_name))

  expect_true(package_installed(package_name))
})

