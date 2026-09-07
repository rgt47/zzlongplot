## Regression tests for the 0.5.0 additions:
##   * facet_labeller renames panel strips without touching the data
##   * facet_type selects facet_wrap as well as facet_grid
##   * point_size and line_width are settable, and default to ggplot2's

library(tinytest)
library(zzlongplot)
suppressPackageStartupMessages(library(ggplot2))

set.seed(31)
d <- data.frame(
  rid = rep(1:24, each = 3),
  wk = rep(c(0, 6, 10), times = 24),
  y = rnorm(72),
  arm = rep(c("P", "Q"), times = 36),
  fac = rep(c("a", "b", "c"), each = 24)
)

mk <- function(...) lplot(d, y ~ wk | arm, facet_form = ~ fac,
                          cluster_var = "rid", baseline_value = 0,
                          plot_type = "obs", show_sample_sizes = FALSE,
                          ...)

# Strip text as actually rendered, which is where a labeller acts.
strip_text <- function(p) {
  g <- ggplot2::ggplotGrob(p)
  out <- character(0)
  for (gr in g$grobs) {
    nm <- if (is.null(gr$name)) "" else gr$name
    if (grepl("^strip", nm)) {
      for (k in gr$grobs) {
        for (kk in k$children) {
          lb <- if (!is.null(kk$children) && !is.null(kk$children[[1]]$label)) {
            kk$children[[1]]$label
          } else {
            kk$label
          }
          if (!is.null(lb)) out <- c(out, lb)
        }
      }
    }
  }
  unique(unlist(out))
}

## ---- facet_labeller -------------------------------------------------

lab <- ggplot2::labeller(fac = c(a = "Alpha", b = "Beta", c = "Gamma"))

expect_equal(sort(strip_text(mk())), c("a", "b", "c"),
             info = "without a labeller the strips print the stored level")
expect_equal(sort(strip_text(mk(facet_labeller = lab))),
             c("Alpha", "Beta", "Gamma"),
             info = "facet_labeller renames the strips under facet_grid")
expect_equal(sort(strip_text(mk(facet_type = "wrap", facet_labeller = lab))),
             c("Alpha", "Beta", "Gamma"),
             info = "and under facet_wrap")
# The point of a labeller is that the data is left alone.
expect_equal(sort(unique(d$fac)), c("a", "b", "c"),
             info = "the caller's factor levels are untouched")

## ---- facet_type -----------------------------------------------------

expect_true(inherits(mk()$facet, "FacetGrid"),
            info = "facet_grid remains the default")
expect_true(inherits(mk(facet_type = "wrap")$facet, "FacetWrap"),
            info = "facet_type = 'wrap' selects facet_wrap")
expect_error(mk(facet_type = "nonesuch"),
             info = "an unknown facet_type is rejected")

# A two-sided facet formula collapses to one ribbon under wrap.
d2 <- transform(d, fac2 = rep(c("x", "y"), each = 36))
p_wrap2 <- lplot(d2, y ~ wk | arm, facet_form = fac ~ fac2,
                 cluster_var = "rid", baseline_value = 0,
                 plot_type = "obs", show_sample_sizes = FALSE,
                 facet_type = "wrap")
expect_true(inherits(p_wrap2$facet, "FacetWrap"),
            info = "a two-sided facet formula still wraps")
expect_equal(length(p_wrap2$facet$params$facets), 2L,
             info = "both facet terms are carried into the wrap")

## ---- point_size and line_width --------------------------------------

lyr <- function(p, geom) {
  b <- ggplot2::ggplot_build(p)
  i <- which(vapply(p$layers, function(l) inherits(l$geom, geom), logical(1)))
  b$data[[i[1]]]
}

p_def <- mk()
p_big <- mk(point_size = 3, line_width = 1.2)

expect_equal(unique(lyr(p_big, "GeomPoint")$size), 3,
             info = "point_size is applied")
expect_equal(unique(lyr(p_big, "GeomLine")$linewidth), 1.2,
             info = "line_width is applied")
# ggplot2 4.x resolves unset geom defaults from the theme at build
# time, so the check that nothing was overridden is that the layer
# carries no fixed aesthetic, not that it equals some literal.
param_of <- function(p, geom, nm) {
  i <- which(vapply(p$layers, function(l) inherits(l$geom, geom), logical(1)))
  p$layers[[i[1]]]$aes_params[[nm]]
}
expect_null(param_of(p_def, "GeomPoint", "size"),
            info = "NULL point_size sets no fixed size on the layer")
expect_null(param_of(p_def, "GeomLine", "linewidth"),
            info = "NULL line_width sets no fixed linewidth on the layer")
expect_equal(param_of(p_big, "GeomPoint", "size"), 3,
             info = "point_size is recorded as a fixed layer aesthetic")
expect_equal(param_of(p_big, "GeomLine", "linewidth"), 1.2,
             info = "line_width is recorded as a fixed layer aesthetic")
