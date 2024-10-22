source('analyses/activite_au_fil_de_leau/02-valorisation-MX.R')

(colname_YEAR_nb_sej_M <- glue("Nb_sej_{year}_M{month}"))
(colname_LAST_YEAR_nb_sej_M <- glue("Nb_sej_{year - 1}_M{month}"))

((
  volume_sejour_M
  |> rename(!! colname_YEAR_nb_sej_M := YEAR)
  |> rename(!! colname_LAST_YEAR_nb_sej_M := LAST_YEAR)
  |> rename(`Evolution_vol_sej` = evolution)
  |> select(-statut)
) -> volume_sejour_M)

((
  tableau_de_base
  |> left_join(volume_sejour_M)
  |> relocate(last_col(2):last_col(), .before = nb_sej_23_m7)
  |> select(-nb_sej_23_m7, -nb_sej_24_m7, -evo_m7)
  |> left_join(valo_M)
  |> relocate(last_col(2):last_col(), .before = valo23_m7)
  |> select(-valo23_m7, -valo24_m7, -ecart_valo_m7)
  |> mutate(across(starts_with("vide..."), ~ ""))
  |> write_csv2("analyses/activite_au_fil_de_leau/out.csv")
) -> nouveau_tableau)

## system("chmod +x ./analyses/activite_au_fil_de_leau/csv2xlsx_linux_amd64")
## system('./analyses/activite_au_fil_de_leau/csv2xlsx_linux_amd64 \\
##         -overwrite \\
##         -colsep ";" \\
##        -infile analyses/activite_au_fil_de_leau/out.csv \\
##        -outfile analyses/activite_au_fil_de_leau/out.xlsx
##        ')



View(nouveau_tableau)

