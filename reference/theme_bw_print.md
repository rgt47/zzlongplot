# Black-and-White Print Theme

Creates a theme optimized for monochrome (black-and-white) printing.
Groups are distinguished by linetype and point shape rather than color.

## Usage

``` r
theme_bw_print(base_size = 10, base_family = "sans", grid = TRUE)
```

## Arguments

- base_size:

  Base font size in points. Default is 10pt for print readability.

- base_family:

  Font family. Default is "sans" (Helvetica equivalent).

- grid:

  Logical. Whether to show major grid lines. Default is TRUE for
  readability without color cues.

## Value

A ggplot2 theme object.

## Details

Designed for figures that will be printed in greyscale or photocopied.
Uses high-contrast black-on-white styling with no color dependency. Pair
with greyscale color scales and mapped linetype/shape aesthetics for
full black-and-white compatibility.

## Examples

``` r
library(ggplot2)
ggplot(mtcars, aes(wt, mpg)) +
  geom_point() +
  theme_bw_print()

```
