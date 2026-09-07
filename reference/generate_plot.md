# Generate Custom ggplot2 Visualization for Longitudinal Data

Creates customizable visualizations using `ggplot2` for longitudinal
data. Supports dynamic axis scaling, optional grouping, faceting, and
error visualization with ribbons or error bars.

## Usage

``` r
generate_plot(
  stats,
  x_var,
  y_var,
  group_var = NULL,
  error_type = "bar",
  jitter_width = 0.1,
  xlab = NULL,
  ylab = NULL,
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  facet = NULL,
  color_palette = NULL,
  reference_lines = NULL,
  show_sample_sizes = TRUE,
  statistical_annotations = FALSE,
  use_boxplot = FALSE,
  ribbon_alpha = 0.2,
  ribbon_fill = NULL,
  bw_print = FALSE,
  x_breaks = NULL,
  sample_size_opts = list(),
  error_opts = list(),
  contrast_display = NULL,
  contrast_data = NULL,
  summary_statistic = NULL,
  p_adjust_method = "BH",
  auto_caption = TRUE
)
```

## Arguments

- stats:

  A data frame containing the data to be plotted. Must include the
  columns specified in `x_var`, `y_var`, and optionally `group_var`,
  `bound_lower`, and `bound_upper` for error visualization.

- x_var:

  A string specifying the column name for the x-axis variable.

- y_var:

  A string specifying the column name for the y-axis variable.

- group_var:

  A string specifying the column name for the grouping variable.

- error_type:

  A string specifying the error type. Use `"bar"` for capped error bars,
  `"line"` for uncapped ranges, or `"band"` for ribbons.

- jitter_width:

  Numeric. Width of horizontal jitter for error bars when multiple
  groups are present. Only applies when error_type = "bar" or `"line"`.

- xlab:

  A string for the x-axis label.

- ylab:

  A string for the y-axis label.

- title:

  A string for the plot title.

- subtitle:

  A string for the plot subtitle.

- caption:

  A string for the plot caption.

- facet:

  A list specifying faceting variables. Use `facet_x` for columns and
  `facet_y` for rows. Both are optional.

- color_palette:

  Optional vector of colors to use. If NULL, default ggplot colors are
  used.

- reference_lines:

  List of reference line specifications. Each element should be a list
  with components: value, axis ("x" or "y"), color, linetype, size.

- show_sample_sizes:

  Logical. If TRUE (the default), adds sample size annotations. On by
  default so the number contributing to each point is always visible;
  see [`lplot()`](https://rgt47.github.io/zzlongplot/reference/lplot.md)
  for the rationale.

- statistical_annotations:

  Logical. If TRUE, adds p-values and significance.

- use_boxplot:

  Logical. If TRUE, renders actual boxplots instead of line graphs.

- ribbon_alpha:

  Numeric. Transparency level for ribbon/band error representations.
  Values from 0 (fully transparent) to 1 (fully opaque). Default is 0.2.

- ribbon_fill:

  Character. Custom fill color for ribbons. If NULL, uses group colors.

- bw_print:

  Logical. If TRUE, maps linetype and shape to group variable for
  black-and-white print compatibility. Default is FALSE.

- x_breaks:

  Optional vector of x-axis break positions, passed to
  [`ggplot2::scale_x_continuous()`](https://ggplot2.tidyverse.org/reference/scale_continuous.html)
  or
  [`ggplot2::scale_x_discrete()`](https://ggplot2.tidyverse.org/reference/scale_discrete.html)
  according to whether the x variable is continuous. `NULL` (the
  default) leaves the scale's own breaks in place.

- sample_size_opts:

  List. Options controlling the appearance and placement of sample size
  labels. Elements (all optional):

  position

  :   Placement style: "point" (next to each data point, the default) or
      "table" (color-coded table below x-axis with one row per group).

  size

  :   Font size in mm. Default 2.8.

  color

  :   Label color (only for position = "point"). Default "grey40". Table
      mode uses group colors.

  alpha

  :   Transparency, 0-1. Default 1.

  nudge_x

  :   Horizontal offset from the point (only for position = "point").
      Default is auto-calculated.

  nudge_y

  :   Vertical offset from the point (only for position = "point").
      Default 0.

  gap

  :   Fraction of y-range between plot area and first table row (only
      for position = "table"). Default 0.18.

  row_height

  :   Fraction of y-range between table rows (only for position =
      "table"). Default 0.06.

  label_size

  :   Font size for group labels in the table (only for position =
      "table"). Defaults to size.

  label_offset

  :   Horizontal offset for group labels (only for position = "table").
      Default 0.08 for continuous x, 0.35 for categorical.

  show_group_labels

  :   Logical, `position = "table"` only. Whether to print the group
      name at the left of each row. Default `TRUE`. Set `FALSE` to
      identify the rows from the legend instead, which also reclaims the
      left margin the labels reserve.

  legend

  :   `position = "table"` only. `"none"` (the default) hides the
      legend, on the assumption that the row labels identify the groups;
      `"keep"` leaves it in place, which is what
      `show_group_labels = FALSE` needs.

  region

  :   `position = "table"` only. Where the rows are drawn: `"margin"`
      (the default) holds the panel to the data range and reserves plot
      margin beneath it; `"panel"` expands the y scale to include the
      rows, spending vertical space inside the panel rather than outside
      it. Prefer `"panel"` on a figure that is already tall on furniture
      (a multi-line subtitle, a bottom legend), where a reserved margin
      can squeeze the panel to a sliver.

- error_opts:

  List. Appearance overrides for the `"bar"` and `"line"` error layers.
  Elements (all optional):

  colour

  :   Bar colour. `NULL`, the default, inherits the group colour so that
      error bars match the series they belong to. Supply a string (e.g.
      `"black"`) to override.

  alpha

  :   Transparency, 0-1. Default 1.

  linewidth

  :   Line width. Default 0.35.

  width

  :   Cap width, `error_type = "bar"` only. Default 0.2.

- contrast_display:

  Optional character string controlling whether and how pairwise
  contrast annotations are added to the plot. NULL (default) suppresses
  contrast display.

- contrast_data:

  Optional data frame of contrast results to annotate. When NULL
  (default) no contrasts are drawn.

- summary_statistic:

  Character. The summary used to build `stats`, one of `"mean"`,
  `"mean_se"`, `"median"`, or `"boxplot"`. Used only to word the
  automatic caption; pass it so the caption names the correct
  uncertainty measure.

- p_adjust_method:

  Character. Multiplicity correction that was applied, used to word the
  automatic caption.

- auto_caption:

  Logical. If TRUE (default) and no `caption` is supplied, a caption is
  generated stating what the error bars or bands represent, and, when
  significance stars are drawn, what the star thresholds and
  multiplicity adjustment are. Set to FALSE to leave the caption empty.
  An explicit `caption` always wins.

## Value

A `ggplot` object representing the visualization.

## Examples

``` r
library(ggplot2)
data <- data.frame(
  x = rep(1:10, each = 2),
  mean_value = c(1:10, 2:11),
  group = rep(c("A", "B"), 10),
  bound_lower = c(0.8 * (1:10), 1:10),
  bound_upper = c(1.2 * (1:10), 2:11),
  is_continuous = TRUE
)

# Create a plot with error bands
plot <- generate_plot(
  stats = data,
  x_var = "x",
  y_var = "mean_value",
  group_var = "group",
  error_type = "band",
  xlab = "Time",
  ylab = "Measurement",
  title = "Example Plot"
)
print(plot)


# Create a plot with jittered error bars
plot_jitter <- generate_plot(
  stats = data,
  x_var = "x", 
  y_var = "mean_value",
  group_var = "group",
  error_type = "bar",
  jitter_width = 0.2,
  xlab = "Time",
  ylab = "Measurement", 
  title = "Example Plot with Jittered Error Bars"
)
print(plot_jitter)

```
