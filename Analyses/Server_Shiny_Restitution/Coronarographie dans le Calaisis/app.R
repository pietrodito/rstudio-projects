library(hdfmaps)
library(readxl)
library(shiny)
library(purrr)
library(DT)
library(bslib)
library(shinyjs)

## CONFIG ------------
ALL_YEARS <- 2018:2023
SELECTED_YEAR <- 2023
NB_YEARS <- ALL_YEARS[length(ALL_YEARS)] - ALL_YEARS[1] + 1
# ZOOM
X_MIN <- 1.4
X_MAX <- 3.5
Y_MIN <- 50.5
Y_MAX <- 51.05
## -------------------


(df <- read_excel("data/Coronarographie_Calaisis_Hors_PIE_seuil_20231412.xlsx",
                 col_types = c("guess", "guess", "text", "guess",
                               "guess", "guess", "guess", "guess")))


ui <- fluidPage(
  useShinyjs(),
  theme = bs_theme(version = 5),
  wellPanel(
  fluidRow(
    column(11, tags$h1("Consommation de coronarographie pour les habitants du Calaisis")),
    column(1, tags$img(src='./logo_ars.svg', align = "right", width = "100px"))
  )),
  wellPanel(
    fluidRow(
      column(2, wellPanel(radioButtons("seuil", "Type actes",
                                       choices = c("Soumis à seuil",
                                                   "Non soumis",
                                                   "Tous types"),
                                       selected = "Soumis à seuil"))
      ),
      column(2,  wellPanel(
        fluidRow(
          checkboxGroupInput(
            inputId = paste0("year"),
            label   = paste0("Année"), choices = ALL_YEARS,
            selected = SELECTED_YEAR
          ) 
        ),
        fluidRow(actionButton("last_year", "📅 ⟵ Année précédente"),
                 actionButton("next_year", "📅 ⟶ Année suivante"),
                 actionButton("all_years", "Toutes les années"),
                 actionButton("one_year", "Année 2023"),
                 actionButton("advanced_config", "Sélection manuelle") )
      ),
      ),
      column(8,  plotOutput("map", height = "500px")),
    )),
  wellPanel(
    fluidRow(
      column(4, DTOutput("table")),
      column(8, plotOutput("hospit_trend")),
    )
  ),
  textOutput("debug")
)
server <- function(input, output, session) {
  
  selected_rs <- reactiveVal(c())
  
  disable("year")
  
  coro <- reactiveVal(NULL)
  coro_without_outside <- reactiveVal(NULL) ## needed to hide ggrepel outside
  out <- reactiveVal()
  pre_out <- reactiveVal()
  
  years <- reactiveVal()
  
  observeEvent(input$last_year, {
    updateCheckboxGroupInput(
      session,
      "year",
      selected = ((input$year |> as.integer() - ALL_YEARS[1]) - 1) %%
        NB_YEARS + ALL_YEARS[1]
    )
  })
  
  observeEvent(input$next_year, {
    updateCheckboxGroupInput(
      session,
      "year",
      selected = ((input$year |> as.integer() - ALL_YEARS[1]) + 1) %%
       NB_YEARS + ALL_YEARS[1]
    )
  })

  observe({
    req(input$seuil)
    
    if(input$seuil == "Soumis à seuil") {
      pre_out(df |> filter(Seuil == "non soumis à seuil"))
    }
    
    if(input$seuil == "Non soumis") {
      pre_out(df |> filter(Seuil == "soumis à seuil"))
    }
    
   if(input$seuil == "Tous types"){
     pre_out(df)
   }
    
    out(
      pre_out()
      |> filter(Année %in% input$year)
      |> select(3, 5)
      |> group_by(Finess)
      |> summarise(`Nbr. d'actes` = sum(`Nb d'actes`))
      |> mutate(`Nbr. d'actes` = `Nbr. d'actes` |> as.integer())
      |> arrange(desc(`Nbr. d'actes`), Finess)
      |> left_join(finess |> as.data.frame() |> select("nofinesset", "rs"),
                   by = c("Finess" = "nofinesset"))
    ) 
    
    coro(
      finess
      |> filter(nofinesset %in% out()$Finess)
      |> select(1, 2, 5, 6)
      |> left_join(out() |> select(-rs), by = c("nofinesset" = "Finess"))
      |> arrange(desc(`Nbr. d'actes`), nofinesset)
    )
    coro_without_outside(
      coro()
      |> mutate(rs =
                  ifelse((X >= X_MIN & X <= X_MAX) & (Y >= Y_MIN & Y <= Y_MAX),
                         rs,
                         ""))
    )
  })
  
  max_nb_actes <- reactiveVal()
  max_nb_actes_pour_une_annee <- reactiveVal()
  
  observe({
    max_nb_actes(
      out()
      |> pull(`Nbr. d'actes`)
      |> max()
    )
    
    max_nb_actes_pour_une_annee(
      pre_out()
      |> group_by(Finess, Année)
      |> summarise(N = sum(`Nb d'actes`))
      |> pull(N)
      |> max()
    )
  })
  
  selected_finess <- reactiveVal(NULL)
  
  
  output$table <- renderDT(
    {
      out() |> select(rs, `Nbr. d'actes`, Finess)
    },
    options = list(dom = 't', pageLength = 10000, ordering = FALSE),
    selection = list(mode = "multiple",
                     selected = ( out()
                                  |> pull(Finess)
                                  |> (\(x) which(x %in% selected_finess()))()
                     ),
                     caption = "Source : ATIH - Pour 2023: cumul M9."
    )
  )
  
  Aesthetics <- reactive({
    clrs <- rep("orange", nrow(coro()))
    a <- rep(.3, nrow(coro()))
    selectedRow <- input$table_rows_selected
    clrs[selectedRow] <- "red"
    a[selectedRow] <- 1
    list("color" = clrs, "alpha" = a)
  })
  
  output$map <- renderPlot({
    aesth <- Aesthetics()
    (
      ggplot()
      + carte_4236(fill = "aliceblue", col = "aliceblue")
      + geom_sf(data = nord, fill = land_color)
      + geom_sf(data = pas_de_calais, fill = land_color)
      + geom_sf(data = aisne, fill = land_color)
      + geom_sf(data = somme, fill = land_color)
      + geom_sf(data = oise, fill = land_color)
      + geom_sf(data = calaisis, fill = "#00AA00", alpha = .1, lty = 1)
      + geom_sf(data = autres_regions, fill = "#EEEEFF")
      # + geom_sf(data = pays_limitrophes, fill = "#EEEEFF")
      + geom_sf(data = coro(), aes(size = `Nbr. d'actes`), color = "#000000", alpha = 0.3)
      + geom_sf(data = coro(), aes(size = `Nbr. d'actes` / 3 * 2), color = aesth$color, alpha = aesth$alpha)
      + geom_text_repel(data = coro_without_outside(), aes(x = X, y = Y, label = rs), size = 3.3, min.segment.length = 0, position = position_nudge_repel(c(x = .14, y = .14)), seed = 0)
      + scale_size_continuous(range = c(1, 30), limits = c(1, max_nb_actes()))
      + theme_alice()
      + coord_sf(xlim = c(X_MIN, X_MAX), ylim = c(Y_MIN, Y_MAX))
    )
  })
  
  observeEvent(input$table_rows_selected,
    selected_finess(out()[input$table_rows_selected, "Finess"] |> pull())
               )
  
  output$hospit_trend <- renderPlot({
    (
      pre_out()
      |> filter(Finess %in% selected_finess())
      |> group_by(Rs, Année)
      |> summarize(`Nb d'actes` = sum(`Nb d'actes`))
      |> mutate(Année = as.integer(Année))
      |> mutate(`Nb d'actes` = ifelse(Année == 2023, (4/3 * `Nb d'actes`), `Nb d'actes`))
      |> ggplot(aes(Année, `Nb d'actes`, col = Rs))
      +  geom_line()
      +  ylim(0, max_nb_actes_pour_une_annee())
      +  ggtitle("Selectionnez des ES dans la table de gauche. Evolution des ES sur la période (2023 extrapolée)")
      + theme(plot.title = element_text(size = 20))
    )
  })
  
  observeEvent(input$one_year, {
    disable("year")
    updateCheckboxGroupInput(
      session,
      "year",
      selected = 2023 )
  })
  
  observeEvent(input$advanced_config, {
    enable("year")
  })
  
  observeEvent(input$all_years, {
    updateCheckboxGroupInput(
      session,
      "year",
      selected = ALL_YEARS
    )
    
  })
  }

shinyApp(ui, server, options = list(
  launch.browser = TRUE
))
