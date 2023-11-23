library(hdfmaps)

(
  ggplot()
   +  carte_4236()
   +  geom_sf(data = pays_limitrophes, fill = "#EEEEEE", alpha = 1, lty = 1)
   +  geom_sf(data = calaisis, fill = "#00AA00", alpha = .1, lty = 1)
   +  zoom_hdf()
   +  theme_alice()
)
