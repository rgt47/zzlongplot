# Save Publication-Ready Plot

Exports a ggplot object in publication-ready format with automatic
application of journal-specific specifications.

## Usage

``` r
save_publication(
  plot,
  filename,
  journal = "nature",
  width_mm = NULL,
  height_mm = NULL,
  dpi = NULL,
  format = NULL,
  column_type = "double",
  panel_label = NULL,
  add_label_to_plot = FALSE,
  ...
)
```

## Arguments

- plot:

  A ggplot object to be saved.

- filename:

  Character string specifying the output filename. File extension
  determines format if not specified in format parameter.

- journal:

  Character string specifying journal name. Options: "nature",
  "science", "nejm", "cell", "fda", "ema".

- width_mm:

  Numeric. Plot width in millimeters. If NULL, uses journal's single
  column width.

- height_mm:

  Numeric. Plot height in millimeters. If NULL, calculated from plot
  aspect ratio.

- dpi:

  Numeric. Resolution in dots per inch. If NULL, uses journal's
  preferred DPI.

- format:

  Character string specifying file format. If NULL, detected from
  filename extension.

- column_type:

  Character string. Either "single" or "double" for journal column
  specifications.

- panel_label:

  Character string. Panel label for multi-panel figures (e.g., "A",
  "B").

- add_label_to_plot:

  Logical. If TRUE, adds panel label directly to plot.

- ...:

  Additional arguments passed to ggsave().

## Value

Invisible path to saved file.

## Examples

``` r
library(ggplot2)

# Create example plot
p <- ggplot(mtcars, aes(wt, mpg, color = factor(cyl))) + 
  geom_point() + 
  theme_nature()

# Save for Nature journal
save_publication(p, "figure1.pdf", journal = "nature")
#> Plot saved for Nature:
#>   File: figure1.pdf
#>   Dimensions: 180 x 111 mm
#>   Resolution: 600 DPI
#>   Format: PDF

# Save with panel label for multi-panel figure
save_publication(p, "figure1a.pdf", journal = "nature", 
                 panel_label = "A", column_type = "single")
#> Plot saved for Nature:
#>   File: figure1a.pdf
#>   Dimensions: 90 x 56 mm
#>   Resolution: 600 DPI
#>   Format: PDF
#>   Panel: A
```
