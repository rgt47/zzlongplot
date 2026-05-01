# Create a Color-Blind Friendly Palette

Generates a colorblind-friendly palette for use in plots.

## Usage

``` r
get_colorblind_palette(n = 8, type = "qualitative")
```

## Arguments

- n:

  The number of colors to generate. Default is 8.

- type:

  The type of palette. Options are "qualitative" (for categorical data),
  "sequential" (for numeric data), or "diverging" (for data with a
  meaningful zero). Default is "qualitative".

## Value

A character vector of hex color codes.

## Details

The function uses the ColorBrewer palettes through the RColorBrewer
package. For qualitative data, it uses the "Dark2" palette which is
colorblind-friendly. For sequential data, it uses the "Blues" palette.
For diverging data, it uses the "RdBu" palette.

## Examples

``` r
# Get 4 colors for categorical groups
colors <- get_colorblind_palette(4)

# Use in a plot
df <- data.frame(
  x = 1:20,
  y = rnorm(20),
  group = rep(letters[1:4], each = 5)
)
library(ggplot2)
ggplot(df, aes(x, y, color = group)) +
  geom_line() +
  scale_color_manual(values = colors)

```
