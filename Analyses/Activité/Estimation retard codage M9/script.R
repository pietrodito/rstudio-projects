library(tidyverse)
library(readr)

(df <- read_delim("mco.dgf.2022.12.t1v5emm_1.csv", 
                  delim = ";", escape_double = FALSE, locale = locale(), 
                  trim_ws = TRUE))

prest_perimetre <- c(
  11,
  20,
  30,
  40,
  80,
  100,
  110
)

((
  df
  |> filter(type %in% prest_perimetre)
) -> df)

((
  ((
    df
    |> filter(moist <= 9)
    |> pull(mnt3)
    |> sum(na.rm = T)
  ) -> valo_M9_a_M9)
  
  /
    
  ((
    df
    |> filter(moiss <= 9)
    |> pull(mnt3)
    |> sum(na.rm = T)
  ) -> valo_M9_a_M12)
  
) -> ratio_valo_a_M9_sur_M12)

(coef_mult <- 1 / ratio_valo_a_M9_sur_M12)



