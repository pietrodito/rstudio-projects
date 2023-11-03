fs::dir_create("data/mco_dgf/")
fs::dir_create("data/psy_oqn/")
# withr::defer(fs::dir_delete("data"))

read_score_csv_file <- purrr::quietly(read_score_csv_file)
load_score          <- purrr::quietly(load_score)

test_that("charge fichier score champ mco", {
  nature <- nature("mco", "dgf")
  read_score_csv_file(testthat::test_path("test_data/mco_dgf.csv"),
                      nature)
  load_score(nature)
  expect_equal(ncol(the$mco_dgf_scores), 21)
})

test_that("charge fichier score champ psy", {
  nature <- nature("psy", "oqn")
  read_score_csv_file(testthat::test_path("test_data/psy_oqn.csv"),
                      nature)
  load_score(nature)
  expect_equal(ncol(the$psy_oqn_scores), 27)
})


if (sys.nframe() == 0) {
  
  library(ovalide)
  
  champs <- c("mco", "had", "psy", "ssr")
  statuts <- c("dgf", "oqn")
  
  score_file <- "test_data/{champ}_{statut}.csv"
  zip_file <-
    "test_data/{champ}.{statut}.2023.4.ovalide-tables-as-csv.zip"
  
  read_files <- function(champ, statut) { 
    nat <- nature(champ, statut)
    read_score_csv_file( glue::glue(score_file), nat)
    read_zip_table_file( glue::glue(zip_file), nat)
  }
  
  purrr::map(champs, \(c)
             purrr::map(statuts, \(s)
                       read_files(c, s) 
                                    ))
}