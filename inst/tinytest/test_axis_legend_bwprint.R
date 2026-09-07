## Regression tests for the 0.4.0 additions:
##   * x_breaks sets axis breaks without post-composition
##   * the legend is titled from the formula, not "group"
##   * bw_print is settable independently of the theme

library(tinytest)
library(zzlongplot)
suppressPackageStartupMessages(library(ggplot2))

set.seed(21)
d <- data.frame(
  rid = rep(1:30, each = 3),
  wk = rep(c(0, 6, 10), times = 30),
  y = rnorm(90),
  arm = rep(c("P", "Q"), each = 45)
)
pal <- c("#E69F00", "#0072B2")

mk <- function(...) lplot(d, y ~ wk | arm, cluster_var = "rid",
                         baseline_value = 0, plot_type = "obs",
                         color_palette = pal, show_sample_sizes = FALSE,
                         ...)

## ---- x_breaks -------------------------------------------------------

p_br <- mk(x_breaks = c(0, 6, 10))
drawn <- ggplot2::ggplot_build(p_br)$layout$panel_params[[1]]$x$breaks
expect_equal(drawn[!is.na(drawn)], c(0, 6, 10),
             info = "x_breaks sets the axis breaks")

p_nobr <- mk()
expect_true(!is.null(ggplot2::ggplot_build(p_nobr)),
            info = "x_breaks = NULL leaves the default scale alone")

## ---- legend title ---------------------------------------------------

p_def <- mk()
expect_equal(p_def$labels$colour, "arm",
             info = paste("the legend takes the grouping variable's own",
                          "name, not the internal column name 'group'"))

p_ttl <- mk(legend_title = "Treatment arm")
expect_equal(p_ttl$labels$colour, "Treatment arm",
             info = "legend_title overrides the default")
# Under bw_print all four aesthetics are mapped; retitling only colour
# would split one key into two.
for (aes_name in c("fill", "linetype", "shape")) {
  expect_equal(p_ttl$labels[[aes_name]], "Treatment arm",
               info = sprintf("legend_title also titles %s", aes_name))
}

## ---- bw_print is independent of the theme ---------------------------

lt_of <- function(p) {
  unique(ggplot2::ggplot_build(p)$data[[1]]$linetype)
}

expect_true(length(lt_of(mk(theme = "bw"))) > 1,
            info = "theme = 'bw' still maps linetype to group by default")
expect_equal(length(lt_of(mk(theme = "nejm"))), 1L,
             info = "a journal theme still defaults to colour only")
expect_true(length(lt_of(mk(theme = "nejm", bw_print = TRUE))) > 1,
            info = paste("bw_print = TRUE keeps redundant encoding under",
                         "a journal theme, which the theme coupling",
                         "previously made unreachable"))
expect_equal(length(lt_of(mk(theme = "bw", bw_print = FALSE))), 1L,
             info = "bw_print = FALSE drops it under 'bw'")

## shape is mapped alongside linetype, and both follow bw_print
p_bw <- mk(theme = "nejm", bw_print = TRUE)
expect_true(length(unique(ggplot2::ggplot_build(p_bw)$data[[2]]$shape)) > 1,
            info = "bw_print maps shape as well as linetype")
