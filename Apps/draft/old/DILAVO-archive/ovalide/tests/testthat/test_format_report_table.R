# library(ovalide)

load_ovalide_tables(nature("mco", "dgf"))
ch_guise   <- "020000022"
roseraie   <- "020000386"
st_quentin <- "020000063"
had_chauny <- "020010898"
lespoir    <- "590797387"

format_report_table <- purrr::quietly(format_report_table)

test_that("MCO report works", {
  quiet_output <- format_report_table(nature("mco", "dgf"),
                                     finess = ch_guise)
  report <- quiet_output$result

  expect_equal(ncol(report), 7)
  expect_equal(nrow(report), 13)
})

check_all_report_variables_are_treated <- function() {
  (
    the$mco_dgf_scores$Finess
    %>% purrr::map(~ format_report_table(nature("mco", "dgf"),
                                        .x))
    %>% purrr::map(~ dplyr::filter(.x, is.na(Variable)))
    %>% purrr::keep(~ nrow(.x) > 0)
  ) -> result

  expect_equal(length(result), 0)


  load_ovalide_tables(nature("mco", "oqn"))
  (
    the$mco_oqn_scores$Finess
    %>% purrr::map(~ format_report_table(nature("mco", "oqn"),
                                        .x))
    %>% purrr::map(~ dplyr::filter(.x, is.na(Variable)))
    %>% purrr::keep(~ nrow(.x) > 0)
  ) -> result

  expect_equal(length(result), 0)
  ### Il n'existe pas de noms courts de variable non mapped to label
}

test_that("MCO report variable works", {
  silence <- purrr::quietly(check_all_report_variables_are_treated)()
})


test_that("HAD report works", {
  load_ovalide_tables(nature("had", "dgf"))

  quiet_output <-
    format_report_table(nature("had", "dgf"),
                       finess = ch_guise)
  report <- quiet_output$result

  expect_equal(ncol(report), 5)
  expect_equal(nrow(report), 8)
})


test_that("SSR report works", {
  load_ovalide_tables(nature("ssr", "dgf"))

  quiet_output <-
    format_report_table(nature("ssr", "dgf"),
                       finess = ch_guise)
  report <- quiet_output$result

  expect_equal(ncol(report), 5)
  expect_equal(nrow(report), 5)
})

test_that("PSY report works", {
  load_ovalide_tables(nature("psy", "dgf"))

  quiet_output <-
    format_report_table(nature("psy", "dgf"),
                       finess = st_quentin)
  report <- quiet_output$result

  expect_equal(ncol(report), 10)
  expect_equal(nrow(report), 5)
})
