library(shiny)
library(sf)
library(purrr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(DT)

nc <- st_read(system.file("shape/nc.shp", package="sf"))

lon <- 0:9 - 84
lat <- 0:2 + 34

raw <- 
  expand_grid(lon, lat) |> 
  mutate(name = c(letters, LETTERS[1:4])) |> 
  mutate(point = map2(lon, lat, ~ st_point(c(.x, .y)))) |> 
  mutate(feature = st_sfc(point, crs = 4236)) |> 
  select(name, feature)

dots <- st_sf(raw[, "name"], geometry = st_sfc(raw$feature))

# turn dots into an ordinary dataframe
df_dots <- as.data.frame(dots)
df_dots[["geometry"]] <- as.character(df_dots[["geometry"]])


ui <- fluidPage(
  fluidRow(
    column(3,  DTOutput("table") ),
    column(9,  plotOutput("map") )
  )
)


server <- function(input, output, session) {
  
  output$table <- renderDT({
    datatable(
      as.data.frame(df_dots),
      selection = "single"
    )  
  })
  
  Aesthetics <- reactive({
    clrs <- rep("black", 30L)
    size <- rep(2, 30L)
    selectedRow <- input[["table_rows_selected"]]
    clrs[selectedRow] <- "red"
    size[selectedRow] <- 5
    list("color" = clrs, "size" = size)
  })
  
  output$map <- renderPlot({
    aesth <- Aesthetics()
    ggplot() + geom_sf(data = nc) + 
      geom_sf(data = dots, colour = aesth[["color"]], size = aesth[["size"]])
  })
}

shinyApp(ui, server)
