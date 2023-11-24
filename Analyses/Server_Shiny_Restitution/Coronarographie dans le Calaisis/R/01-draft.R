# library(hdfmaps)
# 
# (df <- read_excel("data/20231122_Actes_Coronarographies_Calaisis.xlsx",
#                   col_types = c("guess", "guess", "text", "guess",
#                                 "guess", "guess", "guess")))
# ((
#   df
#   |> filter(Année == 2018)
#   |> select(3, 5)
#   |> group_by(Finess)
#   |> summarise(N = sum(`Nb d'actes`))
# ) -> tmp)
# (
#   finess
#   |> filter(nofinesset %in% df$Finess)
#   |> select(1, 2, 5, 6)
#   |> left_join(tmp, by = c("nofinesset" = "Finess"))
# ) -> coro
#   
#  (
#    ggplot()
#    +  carte_4236()
#    +  geom_sf(data = pays_limitrophes, fill = "#EEEEEE", alpha = 1, lty = 1)
#    +  geom_sf(data = calaisis, fill = "#00AA00", alpha = .1, lty = 1)
#    +  geom_sf(data = coro, aes(size = N), col = "#ff0000")
#    +  geom_text_repel(data = coro, aes(x = X, y = Y, label = rs), size = 1.8)
#    +  zoom_hdf()
#    +  theme_alice()
#  )
# 
# 
