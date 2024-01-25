library(hdfmaps)
library(tidyverse)

(
  ggplot()
  + carte_4236(fill = "aliceblue", col = "aliceblue")
  + geom_sf(data = TAS_AISNE_HAUTE_SOMME, fill = land_color)
  + geom_sf(data = TAS_ARTOIS_DOUAISIS, fill = "red")
  + geom_sf(data = TAS_HAINAUT, fill = "blue")
  + geom_sf(data = TAS_LITTORAL_NORD, fill = "yellow")
  + geom_sf(data = TAS_METROPOLE, fill = "green")
  + geom_sf(data = TAS_OISE, fill = "orange")
  + geom_sf(data = TAS_SOMME_LITTORAL_SUD, fill = "black")
  + zoom_hdf()
)


