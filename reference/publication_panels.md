# Create Multi-Panel Publication Figure

Combines multiple plots into a publication-ready multi-panel figure with
automatic panel labeling and consistent formatting.

## Usage

``` r
publication_panels(
  plots,
  labels = NULL,
  layout = "horizontal",
  ncol = NULL,
  nrow = NULL,
  shared_legend = FALSE,
  legend_position = "bottom",
  label_size = 12,
  label_face = "bold",
  spacing = 0.02
)
```

## Arguments

- plots:

  List of ggplot objects to combine.

- labels:

  Character vector of panel labels (e.g., c("A", "B", "C")).

- layout:

  Character string specifying layout: "horizontal", "vertical", or
  "grid".

- ncol:

  Integer. Number of columns for grid layout.

- nrow:

  Integer. Number of rows for grid layout.

- shared_legend:

  Logical. Whether to use a shared legend.

- legend_position:

  Character string specifying shared legend position.

- label_size:

  Numeric. Size of panel labels.

- label_face:

  Character string. Font face for panel labels ("bold", "italic", etc.).

- spacing:

  Numeric. Margin added around each panel, in `npc` units (fraction of
  the panel region). Default `0.02`.

## Value

A `patchwork` object combining `plots`, with class
`c("patchwork", "gg", "ggplot")`. It prints like a ggplot and can be
passed to
[`save_publication()`](https://rgt47.github.io/zzlongplot/reference/save_publication.md)
or
[`ggplot2::ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html).

## See also

[`save_publication()`](https://rgt47.github.io/zzlongplot/reference/save_publication.md)
to write the result to a journal-specified file;
[`get_publication_theme()`](https://rgt47.github.io/zzlongplot/reference/get_publication_theme.md)
and the `theme_*()` family for styling the individual panels.

Other publication export:
[`get_journal_specs()`](https://rgt47.github.io/zzlongplot/reference/get_journal_specs.md),
[`list_journals()`](https://rgt47.github.io/zzlongplot/reference/list_journals.md),
[`save_publication()`](https://rgt47.github.io/zzlongplot/reference/save_publication.md)

## Examples

``` r
library(ggplot2)

# Create individual plots
p1 <- ggplot(mtcars, aes(wt, mpg)) + geom_point() + theme_nature()
p2 <- ggplot(mtcars, aes(hp, mpg)) + geom_point() + theme_nature()

# Combine into publication figure
fig <- publication_panels(
  plots = list(p1, p2),
  labels = c("A", "B"),
  layout = "horizontal"
)

# Save the combined figure to a temporary location
out <- file.path(tempdir(), "figure1.pdf")
save_publication(fig, out, journal = "nature", column_type = "double")
#> Plot saved for Nature:
#>   File: /tmp/Rtmpv9jNvj/figure1.pdf
#>   Dimensions: 183 x 113 mm
#>   Resolution: 600 DPI
#>   Format: PDF
```
