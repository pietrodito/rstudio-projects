source('analyses/activite_au_fil_de_leau/01-volume-sejour-M.R')

effet_prix_SMA <- function() {
  
  years <- c(year - 1, year)
  
  (
    tc(t1sma_1, "mco", "dgf")
    |> filter(annee %in% years & periode == month & var == '01')
    |> collect()
    |> select(ipe, annee, mnt)
    |> filter(ipe %in% etab_dgf_hors_hprox)
    |> pivot_wider(names_from = annee, values_from = mnt)
    |> mutate(across(2:3, as.numeric))
    |> mutate(effet_prix = (`2024` - `2023`) / `2023`)
    |> select(ipe, effet_prix)
  )
  
}

effet_prix_SMA() |> print(n=Inf)

valorisation_SMA <- function() {
  
  (
    tc(t1sma_1, "mco", "dgf")
    |> filter(annee == year | annee == (year - 1))
    |> mutate(annee = ifelse(annee == year, "YEAR", "LAST_YEAR"))
    |> filter(periode == month)
    |> filter(ipe %in% etab_dgf_hors_hprox)
    |> filter(var %in% c("11", "02"))
    |> mutate(var = ifelse(var == "11", "Ref SMA", "Valo"))
    |> select(champ, statut, annee, periode, ipe, var, mnt)
    |> collect()
    |> pivot_wider(names_from = c(annee, var), values_from = mnt)
    |> mutate(across(5:8, as.numeric))
    # |> mutate(LastYearRatio = (LAST_YEAR_Valo / `LAST_YEAR_Ref SMA`) - 1)
    # |> mutate(YearRatio = (YEAR_Valo / `YEAR_Ref SMA`) - 1)
    # |> select(-champ, -statut, -periode)
    # |> rename(LAST_YEAR_Garantie = `LAST_YEAR_Ref SMA`,
    #           YEAR_Garantie = `YEAR_Ref SMA`
    #           )
    |> mutate(evolution = (YEAR_Valo - LAST_YEAR_Valo) / LAST_YEAR_Valo)
    |> select(ipe, LAST_YEAR_Valo, YEAR_Valo, evolution)
    |> left_join(effet_prix_SMA())
  )
}

valorisation_SMA()

effet_prix_DGF <- function() {
  
  years <- c(year - 1, year)
  
  (
    tc(t1v5hprox_1, "mco", "dgf")
    |> filter(annee %in% years & periode == month)
    |> collect()
    |> select(ipe, annee, mnt_dfg)
    |> filter(ipe %in% etab_dgf_hprox)
    |> pivot_wider(names_from = annee, values_from = mnt_dfg)
    |> mutate(across(2:3, as.numeric))
    |> mutate(effet_prix = (`2024` - `2023`) / `2023`)
    |> select(ipe, effet_prix)
  )
}

effet_prix_DGF()
## 5,88% pour EBNL / HPROX

valorisation_HPROX <- function() {
  (
    tc(t1v5hprox_1, "mco", "dgf")
    |> filter(annee == year | annee == (year - 1))
    |> mutate(annee = ifelse(annee == year, "YEAR", "LAST_YEAR"))
    |> filter(periode == month)
    |> filter(ipe %in% etab_dgf_hprox)
    |> select(ipe, annee, mnt_dfg, mnt_hpr_valo)
    |> collect()
    |> pivot_wider(names_from = c(annee), values_from = c(mnt_dfg, mnt_hpr_valo))
    |> mutate(across(2:5, as.numeric))
    # |> mutate(LastYearRatio = (mnt_hpr_valo_LAST_YEAR / `mnt_dfg_LAST_YEAR`) - 1)
    # |> mutate(YearRatio =     (mnt_hpr_valo_YEAR /      `mnt_dfg_YEAR`) - 1)
    |> rename(LAST_YEAR_Garantie = mnt_dfg_LAST_YEAR,
              YEAR_Garantie = mnt_dfg_YEAR,
              LAST_YEAR_Valo = mnt_hpr_valo_LAST_YEAR,
              YEAR_Valo = mnt_hpr_valo_YEAR
              )
    |> mutate(evolution = (YEAR_Valo - LAST_YEAR_Valo) / LAST_YEAR_Valo)
    # |> select(1:2, 4, 3, 5:7)
    |> select(ipe, LAST_YEAR_Valo, YEAR_Valo, evolution)
    |> left_join(effet_prix_DGF())
  )
}

valorisation_HPROX()




((
  bind_rows(
  valorisation_HPROX(),
  valorisation_SMA())
  |> mutate(evolution = 
              glue("
                {percent_format(.1)(evolution)}({percent_format(.1)(effet_prix)})
                     ")
  )
  |> select(-effet_prix)
  |> rename(finess = ipe)
) -> valo_M)

