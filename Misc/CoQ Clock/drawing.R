library(showtext)
font_add_google('Source Code Pro')


svglite::svglite("coq_clock.svg")
showtext_begin()

init_plot <- function() {
  plot(
    x = c(-1.4, 1.4),
    y = c(-1.6, 1.6),
    asp = 1,
    type = "n",
    axes = FALSE,
    xlab = "",
    ylab = ""
  )
}

nb_of_ticks <- 1200L

period_cols <- c(
  BMZ = "#0F3B3A",
  BM  = "#155352",
  TS  = "#DA5BD6",
  HD  = "#40A4B9",
  WxSS = "#77BFCF",
  HSS = "#CFC041",
  WnSS = "#E99F10",
  HS  = "#F15F22",
  JD  = "#B154CF"
)


draw_clock <- function(circle_precision = 100) {
  period_duration <- 150L
  (nb_of_periods <- nb_of_ticks / period_duration)
  (period_ticks <- period_duration * seq_len(nb_of_periods))
  
  points(0, 0, lwd = 5, pch = 19)
  
  (
    period_ticks
    |> purrr::walk(function(tick) {
      lines(c(cos(2*pi*tick/nb_of_ticks), cos(2*pi*tick/nb_of_ticks)*0.9)
            ,c(sin(2*pi*tick/nb_of_ticks), sin(2*pi*tick/nb_of_ticks)*0.9),
            lwd = 5,
            col = "white")
    })
  )
  
  radius = 1
  center_x = 0
  center_y = 0
  theta = seq(0, 2*pi, length = circle_precision)
  
  lines(
    center_x + radius*cos(theta),
    center_y + radius*sin(theta),
    lwd = 5
  )
  
  invisible()
}

draw_pizza_slice <- function(start_tick, end_tick, color, circle_precision = 10) {
  start_tick <- - start_tick + 300
  end_tick <- - end_tick + 300
  theta <- seq(2*pi*start_tick/nb_of_ticks,
               2*pi*end_tick/nb_of_ticks, length = circle_precision)
  point_xs <- c(0, cos(theta), 0)
  point_ys <- c(0, sin(theta), 0)
  polygon(point_xs, point_ys, col = color, border = color)
}

draw_pizza_gradient <- function(start_tick, end_tick, start_color, end_color,
                                gradient_precision = 80) {
  colors <- colorRampPalette(c(start_color, end_color))(gradient_precision)
  gradients <- seq(start_tick, end_tick, length = gradient_precision + 1)
  start_ticks <- head(gradients, -1)
  end_ticks <- tail(gradients, -1)
  purrr::pwalk(list(start_ticks, end_ticks, colors), draw_pizza_slice)
}

draw_labels <- function() {
  plotrix::textbox(c(-0.5, 0.5), 1.4,  "Beetle Moon Zenith",
                   col = "white", margin = 0.05,
                   justify = "c",  fill = period_cols["BMZ"])
  
  plotrix::textbox(c(-1.2, -0.55), 1.1, "Waxing",
                   col = "white", margin = 0.05,
                   justify = "c",  fill = period_cols["BM"])
  
  plotrix::textbox(c(0.55, 1.2), 1.1, "Waning",
                   col = "white", margin = 0.05,
                   justify = "c",  fill = period_cols["BM"])
  
  plotrix::textbox(c(1.1, 1.7), 0.65, "The Shallows",
                   col = "white", margin = 0.05,
                   justify = "c",  fill = period_cols["TS"])
  
  plotrix::textbox(c(1.1, 1.7), -0.3, "Harvest Dawn",
                   col = "black", margin = 0.05,
                   justify = "c",  fill = period_cols["HD"])
  
  plotrix::textbox(c(0.5, 1.1), -0.95, "Waxing",
                   col = "black", margin = 0.05,
                   justify = "c",  fill = period_cols["WxSS"])
  
  plotrix::textbox(c(-0.4, 0.4), -1.2, "High Salt Sun",
                   col = "black", margin = 0.05,
                   justify = "c",  fill = period_cols["HSS"])
  
  plotrix::textbox(c(-1.1, -0.5), -0.95, "Waning",
                   col = "black", margin = 0.05,
                   justify = "c",  fill = period_cols["WnSS"])
  
  plotrix::textbox(c(-1.7, -1.1), -0.3, "Hindsun",
                   col = "black", margin = 0.05,
                   justify = "c",  fill = period_cols["HS"])
  
  plotrix::textbox(c(-1.7, -1.1), 0.65, "Jeweled Dusk",
                   col = "white", margin = 0.05,
                   justify = "c",  fill = period_cols["JD"])
}

draw_colors <- function() {
  
  draw_pizza_gradient(975, 1125, period_cols["JD"], period_cols["BM"])
  draw_pizza_gradient(1125, 1200, period_cols["BM"], period_cols["BMZ"])
  draw_pizza_gradient(0, 75, period_cols["BMZ"], period_cols["BM"])
  draw_pizza_gradient(75, 225, period_cols["BM"], period_cols["TS"])
  draw_pizza_gradient(225, 375, period_cols["TS"], period_cols["HD"])
  draw_pizza_gradient(375, 525, period_cols["HD"], period_cols["WxSS"])
  draw_pizza_gradient(525, 600, period_cols["WxSS"], period_cols["HSS"])
  draw_pizza_gradient(600, 675, period_cols["HSS"], period_cols["WnSS"])
  draw_pizza_gradient(675, 825, period_cols["WnSS"], period_cols["HS"])
  draw_pizza_gradient(825, 975, period_cols["HS"], period_cols["JD"])
}

init_plot()

draw_colors()

draw_clock()

draw_labels()

lines(x = c(cos(25/1200*2*pi), 0),
      y = c(sin(25/1200*2*pi), 0))

lines(x = c(cos(700/1200*2*pi), 0),
      y = c(sin(700/1200*2*pi), 0))

rad2deg <- function(rad) {(rad * 180) / (pi)}
rad2deg(700/1200*2*pi) #210
rad2deg(25/1200*2*pi) #7.5

text(-0.5, -0.23, "Night", srt = 210 + 180)
text(-0.45, -0.34, "Day", srt = 210 + 180)
text(0.4, 0.105, "Night", srt = 7.5 )
text(0.4, -0.02, "Day", srt = 7.5 )
text(0, -0.6, "Caves of Qud day segments", cex = 1.5)
text(0, -1.6, "Caves of Qud day segments", cex = 1.5,
     family = "Source Code Pro")

showtext_end()
dev.off()
