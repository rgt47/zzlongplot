## Regression tests for the 0.3.0 fixes:
##   * error bars inherit the group colour (they were hard-coded black)
##   * error_type = "line" draws uncapped ranges
##   * the sample-size table reports per-panel counts under faceting
##     (it previously recycled the first panel's counts into all of them)
##   * the group labels on that table are drawn once, and suppressible
##   * compute_stats() no longer overwrites a y variable named 'change'

library(tinytest)
library(zzlongplot)
suppressPackageStartupMessages(library(ggplot2))

## ---- fixtures -------------------------------------------------------

set.seed(11)
# Deliberately unequal facets: 20 subjects per cell in facet A, 3 in
# facet B, so a recycled count is unmistakable.
d_facet <- rbind(
  data.frame(rid = 1:80, wk = rep(c(0, 6), each = 40),
             y = rnorm(80), arm = rep(c("P", "Q"), 40), fac = "A"),
  data.frame(rid = 201:212, wk = rep(c(0, 6), each = 6),
             y = rnorm(12), arm = rep(c("P", "Q"), 6), fac = "B")
)

pal <- c("#E69F00", "#0072B2")

layer_data_for <- function(p, geom) {
  b <- ggplot2::ggplot_build(p)
  idx <- which(vapply(p$layers,
                      function(l) inherits(l$geom, geom), logical(1)))
  if (length(idx) == 0) return(NULL)
  b$data[[idx[1]]]
}

## ---- error bars take the group colour -------------------------------

p_bar <- lplot(d_facet, y ~ wk | arm, cluster_var = "rid",
               baseline_value = 0, plot_type = "obs",
               error_type = "bar", color_palette = pal,
               show_sample_sizes = FALSE)
eb <- layer_data_for(p_bar, "GeomErrorbar")

expect_false(is.null(eb),
             info = "error_type = 'bar' produces a GeomErrorbar layer")
expect_equal(sort(unique(eb$colour)), sort(pal),
             info = "error bars use the supplied palette, not black")
expect_equal(unique(eb$alpha), 1,
             info = "error bars are opaque by default")
expect_true(all(eb$linetype == 1),
            info = "error bars stay solid even when linetype is mapped")

## ---- and can be put back the way they were --------------------------

p_legacy <- lplot(d_facet, y ~ wk | arm, cluster_var = "rid",
                  baseline_value = 0, plot_type = "obs",
                  error_type = "bar", color_palette = pal,
                  error_opts = list(colour = "black", alpha = 0.3),
                  show_sample_sizes = FALSE)
eb_legacy <- layer_data_for(p_legacy, "GeomErrorbar")
expect_equal(unique(eb_legacy$colour), "black",
             info = "error_opts$colour overrides the inherited colour")
expect_equal(unique(eb_legacy$alpha), 0.3,
             info = "error_opts$alpha is honored")

## ---- error_type = 'line' is uncapped --------------------------------

p_line <- lplot(d_facet, y ~ wk | arm, cluster_var = "rid",
                baseline_value = 0, plot_type = "obs",
                error_type = "line", color_palette = pal,
                show_sample_sizes = FALSE)
expect_true(is.null(layer_data_for(p_line, "GeomErrorbar")),
            info = "error_type = 'line' draws no capped bars")
lr <- layer_data_for(p_line, "GeomLinerange")
expect_false(is.null(lr),
             info = "error_type = 'line' produces a GeomLinerange layer")
expect_equal(sort(unique(lr$colour)), sort(pal),
             info = "error lines also take the group colour")

## ---- sample-size table: per-panel counts ----------------------------

truth <- aggregate(rid ~ fac + arm + wk, d_facet, length)
names(truth)[names(truth) == "rid"] <- "n"

p_tab <- lplot(d_facet, y ~ wk | arm, facet_form = ~ fac,
               cluster_var = "rid", baseline_value = 0,
               plot_type = "obs", color_palette = pal,
               show_sample_sizes = TRUE,
               sample_size_opts = list(position = "table"))
b_tab <- ggplot2::ggplot_build(p_tab)

# The count layer is the text layer carrying one row per group x
# timepoint x panel; the label layer carries one row per group.
text_idx <- which(vapply(p_tab$layers,
                         function(l) inherits(l$geom, "GeomText"),
                         logical(1)))
counts <- b_tab$data[[text_idx[1]]]

expect_equal(nrow(counts), nrow(truth),
             info = "one count label per group x timepoint x panel")
expect_equal(sort(as.integer(counts$label)), sort(truth$n),
             info = "labels are the per-panel counts, not panel 1's")
# Panel 2 is facet B, whose true cell size is 3 everywhere.
expect_true(all(as.integer(counts$label[counts$PANEL == 2]) == 3),
            info = "the small facet reports its own n, not the large one")
expect_true(all(as.integer(counts$label[counts$PANEL == 1]) == 20),
            info = "the large facet reports its own n")

## ---- group labels are drawn once, and can be suppressed -------------

labels <- b_tab$data[[text_idx[2]]]
expect_equal(nrow(labels), 2L,
             info = "one row label per group, not one per group per panel")
expect_true(all(labels$PANEL == 1),
            info = "row labels are confined to the first panel")

p_nolab <- lplot(d_facet, y ~ wk | arm, facet_form = ~ fac,
                 cluster_var = "rid", baseline_value = 0,
                 plot_type = "obs", color_palette = pal,
                 show_sample_sizes = TRUE,
                 sample_size_opts = list(position = "table",
                                         show_group_labels = FALSE,
                                         legend = "keep"))
text_idx2 <- which(vapply(p_nolab$layers,
                          function(l) inherits(l$geom, "GeomText"),
                          logical(1)))
expect_equal(length(text_idx2), 1L,
             info = "show_group_labels = FALSE drops the row-label layer")
expect_true(!identical(p_nolab$theme$legend.position, "none"),
            info = "legend = 'keep' leaves the legend in place")
expect_identical(p_tab$theme$legend.position, "none",
                 info = "the default still hides the legend")

## ---- compute_stats() does not clobber a y variable named 'change' ---

set.seed(12)
d_chg <- data.frame(
  rid = rep(1:40, each = 4),
  wk = rep(c(0, 6, 10, 26), times = 40),
  change = rnorm(160),
  arm = rep(c("P", "Q"), each = 80)
)
st <- compute_stats(d_chg, x_var = "wk", y_var = "change",
                    group_var = "arm", cluster_var = "rid",
                    baseline_value = 0)
truth_chg <- aggregate(change ~ arm + wk, d_chg, mean)
got <- merge(st[, c("arm", "wk", "mean_value")], truth_chg,
             by = c("arm", "wk"))
expect_equal(got$mean_value, got$change,
             info = paste("mean_value is the mean of the caller's",
                          "'change' column, not of an internally",
                          "overwritten one"))
expect_true(all(st$standard_deviation[st$wk == 0] > 0),
            info = "the baseline visit keeps its real dispersion")

## ---- base_size reaches the theme ------------------------------------

p_small <- lplot(d_facet, y ~ wk | arm, cluster_var = "rid",
                 baseline_value = 0, plot_type = "obs",
                 base_size = 9, show_sample_sizes = FALSE)
expect_equal(p_small$theme$text$size, 9,
             info = "base_size is forwarded to the publication theme")

## ---- table region: margin vs panel ----------------------------------

p_margin <- lplot(d_facet, y ~ wk | arm, facet_form = ~ fac,
                  cluster_var = "rid", baseline_value = 0,
                  plot_type = "obs", color_palette = pal,
                  show_sample_sizes = TRUE,
                  sample_size_opts = list(position = "table",
                                          region = "margin"))
p_panel <- lplot(d_facet, y ~ wk | arm, facet_form = ~ fac,
                 cluster_var = "rid", baseline_value = 0,
                 plot_type = "obs", color_palette = pal,
                 show_sample_sizes = TRUE,
                 sample_size_opts = list(position = "table",
                                         region = "panel"))

y_range_of <- function(p) {
  b <- ggplot2::ggplot_build(p)
  b$layout$panel_params[[1]]$y.range
}

expect_true(diff(y_range_of(p_panel)) > diff(y_range_of(p_margin)),
            info = paste("region = 'panel' expands the y scale to take",
                         "in the count rows; 'margin' holds the panel",
                         "to the data range"))
expect_equal(as.numeric(p_margin$theme$plot.margin[3]), 66,
             info = "region = 'margin' reserves bottom margin for the rows")
expect_true(as.numeric(p_panel$theme$plot.margin[3]) < 66,
            info = "region = 'panel' reserves no extra bottom margin")
