#' Format report table
#' @export
format_report_table <- function(nature, finess) {
  ovalide_tables <- ovalide_tables(nature)

  if (is.null(ovalide_tables)) {
    warning(no_ovalide_data(nature))
    return(invisible())
  }


  rename_proper <- function(df) {
    names(df) <- report_proper_column_names(nature)
    df
  }

  proper_variable <- function(df) {
    if (nature$champ == "psy") {
      df
    } else
      {
      (
        df
        %>% dplyr::left_join(mapping_nom_colonnes)
        %>% dplyr::mutate(Variable = ifelse(
          is.na(Variable), short_name, Variable
        ))
        %>% dplyr::select(ncol(.), 2:(ncol(.) - 1))
      )
    }
  }

  arrange_if_exists <- function(df, col_name) {
    s_col_name <- as.character(substitute(col_name))
    q_col_name <- rlang::enquo(col_name)

    if (s_col_name %in% names(df)) {
      dplyr::arrange(df, dplyr::desc(!!q_col_name))
    } else {
      df
    }
  }

  remove_first_row_if_mco <- function(df) {
    if (nature$champ == "mco") {
      dplyr::filter(df, dplyr::row_number() != 1)
    } else {
      df
    }
  }

  traduit_mois <- function(df) {
    if ("Mois" %in% names(df)) {
      correspondance <- tibble::tibble(
        mot = c(
          "janv.",
          "févr.",
          "mars" ,
          "avr.",
          "mai" ,
          "juin",
          "juil.",
          "août",
          "sept.",
          "oct.",
          "nov.",
          "déc."
        ),
        Mois = 1:12
      )
      (
        df
        %>% dplyr::left_join(correspondance)
        %>% dplyr::mutate(
          mot = stringr::str_c(stringr::str_pad(mot, 5, side = "right"),
                               "(M", Mois, ")"),
          Mois = mot,
          Mois = ifelse(is.na(Mois), "Total", Mois)
        )
        %>% dplyr::select(-mot)
      )
    } else {
      df
    }
  }

  formate_pourcentage <- function(df) {
    dplyr::mutate(df,
                  dplyr::across(
                    dplyr::contains("%"),
                    ~ scales::percent(as.numeric(.) / 100)
                    %>% stringr::str_pad(7, "left")
                  ))
  }

  report_mco_table_name <- "T1D2RTP_1"
  report_had_table_name <- "T1D2RTP_1"
  report_ssr_table_name <- "T1D0RTP_2"
  report_psy_table_name <- "T1D2SYNTHM_1"

  report_table_name <-
    get(glue::glue("report_{nature$champ}_table_name"))

  (
    ovalide_tables[[report_table_name]]
    %>% dplyr::filter(stringr::str_detect(finess_comp, finess))
    %>% remove_first_row_if_mco()
    %>% dplyr::select(all_of(report_columns_to_select(nature)))
    %>% rename_proper()
    %>% proper_variable()
    %>% traduit_mois()
    %>% formate_pourcentage()
  )
}


# mapping_nom_colonnes ####
mapping_nom_colonnes <- tibble::tribble(
  ~ short_name,
  ~ Variable,
  "nbrsa"      ,
  "Nb de RSA transmis"                             ,
  "cmd90"      ,
  "Nb de RSA en CMD"                               ,
  "hper"       ,
  "Dt Nb de RSA hors période"                      ,
  "hpern1"     ,
  "Dt Nb de RSA hors période année n-1"            ,
  "hperhn1"    ,
  "Dt Nb de RSA hors période année n-1"            ,
  "typsejb"    ,
  "Nb de RSA prestation inter-établissement"       ,
  "ghs9999"    ,
  "Nb de RSA en GHS"                               ,
  "nbrsaseance",
  "Nb de RSA séances"                              ,
  "nbseances"  ,
  "Nb de séances"                                  ,
  "nbrsa0"     ,
  "Nb de RSA DS=0"                                 ,
  "nbjJT0"     ,
  "dont Nb de J ou T0"                             ,
  "nbrsah0"    ,
  "Nb de RSA hors séjour sans nuitée"              ,
  "nbjh0"      ,
  "Nb de journées hors séjour sans nuitée"         ,
  "nbuhcd"     ,
  "Nb de RSA en UHCD réaffecté"                    ,
  "nbabott"    ,
  "Nb de RSA avec diag d explantation du DM Abbott"
)


# colonnes_mco_select ####
colonnes_mco_select <- c("_NAME_",
                         "COL1", "COL2", "COL3",
                         "COL4", "COL5", "COL6")

# colonnes_had_select ####
colonnes_had_select <- c("libel",
                         "mois",
                         "COUNT",
                         "count1",
                         "evol")

# colonnes_ssr_select ####
colonnes_ssr_select <- c("col",
                         "eff",
                         "pct",
                         "eff_1",
                         "pct_1")

# colonnes_psy_select ####
colonnes_psy_select <- c(
  "mois",
  "nbj_hospcomp",
  "nbpat_hospcomp",
  "nb_err_per_hc",
  "nbj_hosppart",
  "nbpat_hosppart",
  "nb_err_per_hp",
  "nbacte",
  "nbpat_acte",
  "nb_pat"
)

# proper_mco_colonnes ####
proper_mco_colonnes <- c(
  "short_name",
  "Année n",
  "Année n-1",
  "Évolution %",
  "Année n (Mars)",
  "Année n-1 (Mars)",
  "Évolution % (Mars)"
)

# proper_had_colonnes ####
proper_had_colonnes <- c("short_name",
                         "Mois",
                         "Année n",
                         "Année n-1",
                         "Évolution %")


# proper_ssr_colonnes ####
proper_ssr_colonnes <- c("short_name",
                         "Effectifs Année n",
                         "% Année n",
                         "Effectifs Année n-1",
                         "% Année n-1")

# proper_psy_colonnes ####
proper_psy_colonnes <- c(
  "Mois",
  "Nb journées prises en charge à tps complet (*)",
  "Nb patients pris en charge à tps complet",
  "Nb de RPS ne respectant pas la mensualisation HC",
  "Nb journées prises en charge à tps partiel",
  "Nb patients pris en charge à tps partiel",
  "Nb de RPS ne respectant pas la mensualisation HP",
  "Nb actes ambulatoires",
  "Nb patients en ambulatoire",
  "Nb patients (hospit+ambul)"
)

