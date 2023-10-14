box::use(
  
  app/logic/df_utils[
    name_repair,
  ],
  
  dplyr[
    rename,
  ],
  
  readr[
    read_csv,
  ],
)


#' @export
prepare_raw_dashboard_4_db <- function(filepath) {
 df <- read_csv(filepath, name_repair = name_repair) 
 (
   df
   |> rename(champ = Champ,
             statut = Statut,
             annee = Annee,
             periode = Period,
             ipe = IPE)
 )
}