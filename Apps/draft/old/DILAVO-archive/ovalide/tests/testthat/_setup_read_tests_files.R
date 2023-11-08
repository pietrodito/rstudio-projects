#library(ovalide)

test_read_ovalide_zip <- function(champ = "mco", statut = "dgf") {
  n <- nature(champ, statut)
  zip_filepath <- testthat::test_path(glue::glue(
    "test_data/{champ}.{statut}.2023.4.ovalide-tables-as-csv.zip"
  ))

  progressr::with_progress(read_zip_table_file(zip_filepath, n))
}

message("Reading zip mco dgf...")
test_read_ovalide_zip("mco", "dgf")
message("Reading zip mco oqn...")
test_read_ovalide_zip("mco", "oqn")
message("Reading zip had dgf...")
test_read_ovalide_zip("had", "dgf")
message("Reading zip had oqn...")
test_read_ovalide_zip("had", "oqn")
message("Reading zip psy dgf...")
test_read_ovalide_zip("psy", "dgf")
message("Reading zip psy oqn...")
test_read_ovalide_zip("psy", "oqn")
message("Reading zip ssr dgf...")
test_read_ovalide_zip("ssr", "dgf")
message("Reading zip ssr oqn...")
test_read_ovalide_zip("ssr", "oqn")
