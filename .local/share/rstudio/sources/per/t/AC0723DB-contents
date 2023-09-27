library(plotly)
library(tidyverse)

HIGH_DETAILS <- F

(df_high <- read_csv("data/bariatric_sankey.csv"))


link_step_gt_two <- function(link_to) {
  gt_two <- function(x) { x > 2}
  
  (
    link_to
    |> str_sub(1, 1) 
    |> gt_two()
  )
}

(
  df_high
  |> mutate(link_to = ifelse(link_step_gt_two(link_to),
                             "More than two surg.",
                             link_to),
            link_to = ifelse(str_detect(link_to, "No more"),
                             "No more surg.",
                             link_to))
  |> filter( ! link_step_gt_two(link_from))
) -> df_low

if (HIGH_DETAILS) {
  df <- df_high
} else {
  df <- df_low
}


simplify_labels <- function(col) {
  (
    col
    |> str_remove("Adjustable gastric ")
    |> str_remove("Gastric ")
    |> str_remove(" gastrectomy")
    |> str_replace("bypass", "Bypass")
    |> str_replace("banding", "Banding")
  )
}

(df$link_from <- simplify_labels(df$link_from))
(df$link_to   <- simplify_labels(df$link_to  ))

(nodes <- c(df$link_from, df$link_to) |> unique())

make_fct_then_int <- function(col) {
 factor(col, levels = nodes) |> as.integer() - 1
}

lightgrey <- rgb(.75, .75, .75, .25)
red       <- rgb(  1,   0,   0, .25)
green     <- rgb(  0,   1,   0, .25)
blue      <- rgb(  0,   0,   1, .25)

((
  tibble(
    target = df$link_to,
    source = make_fct_then_int(df$link_from),
    value = df$N
  )
  |> mutate(color = ifelse(str_detect(target, "No"), lightgrey,
                    ifelse(str_detect(target, "Bypass"), red,
                    ifelse(str_detect(target, "Sleeve"), green,
                    ifelse(str_detect(target, "Banding"), blue,
                                      lightgrey)))),
            target = make_fct_then_int(df$link_to))
) -> int_df)

(colors <- rep("white", 26))

update_node_colors <- function(pattern, color) {
  colors[str_detect(nodes, pattern)] <<- color
}

update_node_colors("Banding", blue)
update_node_colors("Bypass", red)
update_node_colors("Sleeve", green)
update_node_colors("More", lightgrey)
update_node_colors("No", lightgrey)


fig <- plot_ly(
  type = "sankey",
  orientation = "h",
  
  node = list(
    label = nodes,
    color = colors,
    pad = 15,
    thickness = 20,
    line = list(
      color = "black",
      width = 0.5
    )
  ),
  
  link = int_df
)
fig <- fig %>% layout(
  title = "Bariatric surgery pathway for patients between 2006-2021\n
  Patients are selected if they had at least one surgery between 2010-2016",
  font = list(
    size = 10
  )
)

fig
