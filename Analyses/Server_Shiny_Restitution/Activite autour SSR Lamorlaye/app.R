library(hdfmaps)
library(readxl)
library(shiny)
library(purrr)
library(DT)
library(bslib)
library(shinyjs)

## CONFIG ------------
# ZOOM
X_MIN <- 1.4
X_MAX <- 3.5
Y_MIN <- 50.5
Y_MAX <- 51.05
## -------------------

# (df <- read_excel("data/Patients_Lamorlaye_Activité_2022_2023_20231213_formatcsv.xlsx"))
# (top <- read_excel("data/Patients_Lamorlaye_Activité_2022_2023_20231213_formatcsv.xlsx",
#                    sheet = 6))
# 
# (
#  tribble(~ finess, ~ rs, ~ nb_jour_tot, ~nb_jour_hp, nb_jour_hc,
#          "600100309", "UN", 1000, 
#          ) 
# )
# 
# (
#   df
#   |> pivot_longer(cols = 3:24, names_to = "date", values_to = "Nbr. séjours")
#   |> mutate(date = ym(date))
#   |> ggplot(aes(x = date, y = `Nbr. séjours`, col = finess))
# )


ui <- fluidPage(
  useShinyjs(),
  theme = bs_theme(version = 5),
  wellPanel(
  fluidRow(
    column(11, tags$h1("SSR pédiatriques utilisés par patients de Lamorlaye")),
    column(1, tags$img(src='./logo_ars.svg', align = "right", width = "100px"))
  )),
  wellPanel(
  fluidRow(
    h1("Work in progress...")
    # column(12,  plotOutput("map", height = "500px")),
  )),
  wellPanel(
    fluidRow(
      column(4, DTOutput("table")),
      column(8, plotOutput("hospit_trend")),
    )
  )
)

server <- function(input, output, session) {
  
  # output$table <- renderDT(
  #   places_libres,
  #   options = list(dom = 't', pageLength = 10000, ordering = FALSE),
  #   selection = "multiple",
  #   caption = "Source : ATIH "
  # )
  # 
  # output$map <- renderPlot({
  #   (
  #     ggplot()
  #     + carte_4236(fill = "aliceblue", col = "aliceblue")
  #     + geom_sf(data = nord, fill = land_color)
  #     + geom_sf(data = pas_de_calais, fill = land_color)
  #     + geom_sf(data = aisne, fill = land_color)
  #     + geom_sf(data = somme, fill = land_color)
  #     + geom_sf(data = oise, fill = land_color)
  #     + geom_sf(data = calaisis, fill = "#00AA00", alpha = .1, lty = 1)
  #     + geom_sf(data = autres_regions, fill = "#EEEEFF")
  #     # + geom_sf(data = pays_limitrophes, fill = "#EEEEFF")
  #     + scale_size_continuous(range = c(1, 30), limits = c(1, max_nb_actes))
  #     + theme_alice()
  #     + coord_sf(xlim = c(X_MIN, X_MAX), ylim = c(Y_MIN, Y_MAX))
  #   )
  # })
  # 
  # output$hospit_trend <- renderPlot({
  #   plot(letters)
  # })
}
    
shinyApp(ui, server, options = list(
  launch.browser = TRUE
))
