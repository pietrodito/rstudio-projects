#' @export
check_uploads <- function(nature, verbose = TRUE) {
  
box::use(
  
  dplyr
  [ across, arrange, collect, distinct, everything,
    filter, lag, lead, mutate, pull, select, tbl, ],
  
  glue
  [ glue, ],
  
)
  
  helper_extract_years_and_periods <- function(table) {
    (
      db(nature)
      |> tbl(table)
      |> select(annee, periode)
      |> distinct()
      |> collect()
      |> mutate(across(everything(), as.integer))
    ) 
  }
  
  helper_missing_month <- function(temp_year_period) {
    
    (
      temp_year_period
      |> mutate(min_annee = min(annee))
      |> mutate(annee = (annee - min(annee)) * 12)
      |> mutate(check = annee + periode)
      |> arrange(annee, periode)
      |> mutate(check = lead(check - lag(check)))
      |> filter(check != 1)
      |> mutate(annee = annee / 12 + min_annee)
      |> select(-min_annee, -check)
    ) -> result
    
    start_year <- min(temp_year_period$annee)
    end_year <- max(temp_year_period$annee)
    start_period <-
      min(temp_year_period |> filter(annee == start_year) |> pull(periode))
    end_period <-
      max(temp_year_period |> filter(annee == end_year) |> pull(periode))
    
    if (nrow(result) == 0) {
      if(verbose) {
        cli::cli_alert_success(
          glue(
            "Aucun mois manquant entre M{start_period} {start_year} et M{end_period} {end_year}")
        )
      }
    } else {
      if(verbose) {
        cli::cli_h2("Mois manquant(s) après ceux-ci :")
        print(result, n = Inf)
      }
    }
    
    list(
      start_year = start_year,
      start_period = start_period,
      end_year = end_year,
      end_period = end_period,
      pre_missing_months = result
    )
  }
  
  
  if(verbose) {
    cli::cli_h1(glue("************ {db_name(nature)} ************"))
    cli::cli_h2("Vérification CSV")
  }
  
  
  (
    "t1d1cdem_1"
    |> helper_extract_years_and_periods()
    |> helper_missing_month()
  ) -> csv_result
  
  if(verbose) {
    cli::cli_h2("Vérification clé-valeur")
  }
  
  (
    "key_value"
    |> helper_extract_years_and_periods()
    |> helper_missing_month()
  ) -> kv_result
  
  if(verbose) { cli::cli_h2("Vérification TDB")
  }
  
  (
    "tdb"
    |> helper_extract_years_and_periods()
    |> helper_missing_month()
  ) -> tdb_result
  
  list(
    db = db_name(nature), csv = csv_result,
    kv  = kv_result,
    tdb = tdb_result
    ) |> invisible()
}


#' @export
check_all_uploads <- function(verbose = TRUE) {
  box::use(
    dplyr [ bind_rows, contains, ],
    
    glue [ glue, ], 
    
    gt [ cols_label_with, gt, tab_header, tab_spanner, ], 
    
    purrr [ map, ],
    
    tibble [ tibble, ],
  )
  
  
  
  helper_result_line <- function(result) {
    
    missing_csv <- ifelse(nrow(result$csv$pre_missing_months) > 0, "*", "")
    missing_kv  <- ifelse(nrow(result$kv$pre_missing_months)  > 0, "*", "")
    missing_tdb <- ifelse(nrow(result$tdb$pre_missing_months) > 0, "*", "")
    
    tibble(
      DB = result$db,
      `Début TDB` = glue("M{result$tdb$start_period} {result$tdb$start_year}"),
      `Fin TDB`   = glue("M{result$tdb$end_period} {result$tdb$end_year}"),
      `Manquants TDB` = missing_tdb,
      `Début CSV` = glue("M{result$csv$start_period} {result$csv$start_year}"),
      `Fin CSV`   = glue("M{result$csv$end_period} {result$csv$end_year}"),
      `Manquants CSV` = missing_csv,
      `Début KV`  = glue("M{result$kv$start_period} {result$kv$start_year}"),
      `Fin KV`    = glue("M{result$kv$end_period} {result$kv$end_year}"),
      `Manquants KV` = missing_kv,
    )
  }
  
  remove_last_word <- function(text) { gsub("\\s+\\w*$", "", text) }
  
  (
    all_natures
    |> map(~ check_uploads(.x , verbose))
    |> map(helper_result_line)
    |> (\(x) do.call(bind_rows, x))()
    |> gt()
    |> tab_header(title = "Bilan des téléversements")
    |> tab_spanner(label = "Ovalide CSV", columns = contains("CSV"))
    |> tab_spanner(label = "Clé - Valeur", columns = contains("KV"))
    |> tab_spanner(label = "Tableau de bord", columns = contains("TDB"))
    |> cols_label_with(columns = everything(), fn = remove_last_word)
  ) 
  
}