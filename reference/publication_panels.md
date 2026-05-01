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

  Numeric. Spacing between panels.

## Value

A combined plot object (patchwork or equivalent).

## Examples

``` r
if (FALSE) { # \dontrun{
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

# Save the combined figure
save_publication(fig, "figure1.pdf", journal = "nature", column_type = "double")
} # }
```
