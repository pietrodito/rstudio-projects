library(hdfmaps)
library(readxl)
library(shiny)
library(purrr)

df <- read_excel("data/20231122_Actes_Coronarographies_Calaisis.xlsx",
                 col_types = c("guess", "guess", "text", "guess",
                               "guess", "guess", "guess"),
                 n_max = 245)

(
  df
  |> group_by(Finess)
  |> summarise(N = sum(`Nb d'actes`))
  |> pull(N)
  |> max()
) -> max_nb_actes

ALL_YEARS <- 2018:2022

ui <- fluidPage(
  fluidRow(
      column(2,  wellPanel(
        fluidRow(
            checkboxGroupInput(
              inputId = paste0("year"),
              label   = paste0("Années"),
              choices = ALL_YEARS,
              selected = 2022
            ) 
        ),
        fluidRow(actionButton("last_year", "📅 ⟵"),
                 actionButton("next_year", "📅 ⟶"))
),
      ),
      column(6,  plotOutput("map", height = "1000px", width = "1000px")),
      column(3, tableOutput("table"))
    )
)

server <- function(input, output, session) {
  
  
  coro <- reactiveVal(NULL)
  out <- reactiveVal()
  
  years <- reactiveVal()
  
  observeEvent(input$last_year, {
    updateCheckboxGroupInput(
      session,
      "year",
      selected = ((input$year |> as.integer() - 2018) - 1) %% 5 + 2018
      )
  })
  
  observeEvent(input$next_year, {
    updateCheckboxGroupInput(
      session,
      "year",
      selected = ((input$year |> as.integer() - 2018) + 1) %% 5 + 2018
      )
  })
  
  observe({
    out(
      df
      |> filter(Année %in% input$year)
      |> select(3, 5)
      |> group_by(Finess)
      |> summarise(`Nbr. d'actes` = sum(`Nb d'actes`))
      |> mutate(`Nbr. d'actes` = `Nbr. d'actes` |> as.integer())
      |> arrange(desc(`Nbr. d'actes`))
      |> left_join(finess |> as.data.frame() |> select("nofinesset", "rs"),
                   by = c("Finess" = "nofinesset"))
    ) 
    coro(
      finess
      |> filter(nofinesset %in% out()$Finess)
      |> select(1, 2, 5, 6)
      |> left_join(out() |> select(-rs), by = c("nofinesset" = "Finess"))
    )
  })
  
  output$table <- renderTable({
    out() |> select(rs, `Nbr. d'actes`)
  })
  
  output$map <- renderPlot({
    (
      ggplot()
      +  carte_4236()
      +  geom_sf(data = pays_limitrophes, fill = "#EEEEEE", alpha = 1, lty = 1)
      +  geom_sf(data = calaisis, fill = "#00AA00", alpha = .1, lty = 1)
      +  geom_sf(data = coro(), aes(size = `Nbr. d'actes`), col = "#ff0000")
      +  geom_text_repel(data = coro(), aes(x = X, y = Y, label = rs), size = 1.8)
      +  scale_size_continuous(range = c(1, 30), limits = c(1, max_nb_actes))
      +  zoom_hdf()
      +  theme_alice()
    )
  })
}

shinyApp(ui, server, options = list(
  launch.browser = TRUE
))




