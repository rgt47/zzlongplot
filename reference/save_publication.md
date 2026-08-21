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

  Numeric. Plot width in millimeters. If NULL, uses the journal's column
  width for `column_type`. When the journal publishes no width (see
  [`get_journal_specs()`](https://rgt47.github.io/zzlongplot/reference/get_journal_specs.md)),
  a general print default of 90 mm single / 180 mm double is substituted
  and a message names it as the package's default rather than the
  journal's.

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

## See also

Other publication export:
[`get_journal_specs()`](https://rgt47.github.io/zzlongplot/reference/get_journal_specs.md),
[`list_journals()`](https://rgt47.github.io/zzlongplot/reference/list_journals.md),
[`publication_panels()`](https://rgt47.github.io/zzlongplot/reference/publication_panels.md)

## Examples

``` r
library(ggplot2)

# Create example plot
p <- ggplot(mtcars, aes(wt, mpg, color = factor(cyl))) + 
  geom_point() + 
  theme_nature()

# Save for Nature journal (written to a temporary directory here so
# the example does not create files in the working directory)
save_publication(p, file.path(tempdir(), "figure1.pdf"),
                 journal = "nature")
#> Plot saved for Nature:
#>   File: /tmp/Rtmpv9jNvj/figure1.pdf
#>   Dimensions: 183 x 113 mm
#>   Resolution: 600 DPI
#>   Format: PDF

# Save with panel label for multi-panel figure
save_publication(p, file.path(tempdir(), "figure1a.pdf"),
                 journal = "nature",
                 panel_label = "A", column_type = "single")
#> Plot saved for Nature:
#>   File: /tmp/Rtmpv9jNvj/figure1a.pdf
#>   Dimensions: 89 x 55 mm
#>   Resolution: 600 DPI
#>   Format: PDF
#>   Panel: A
```
