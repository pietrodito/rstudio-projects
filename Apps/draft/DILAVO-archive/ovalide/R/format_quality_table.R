## Deprecated

#' @export
format_quality_table <-  function(nature, finess) {

    ovalide_tables <- ovalide_tables(nature)

    if (is.null(ovalide_tables)) {
      warning(no_ovalide_data(nature))
      return(invisible())
    }

    quality_mco_table_name <- "T1Q0QSYNTH_1"
    quality_table_name <- get(quality_table_name(nature))

    (
      ovalide_tables[[quality_table_name]]
      %>% dplyr::filter(finess_comp == finess)
      %>% dplyr::arrange(dplyr::desc(nb))
    )
}
