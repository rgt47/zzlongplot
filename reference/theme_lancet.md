# Lancet Journal Theme

Creates a publication-ready theme following Lancet journal guidelines.

## Usage

``` r
theme_lancet(base_size = 8, base_family = "sans", grid = FALSE)
```

## Arguments

- base_size:

  Base font size in points. Default is 8pt.

- base_family:

  Font family. Default is "sans" (Helvetica equivalent).

- grid:

  Logical. Whether to show grid lines. Default is FALSE.

## Value

A ggplot2 theme object.

## Details

Lancet journal specifications:

- Professional medical styling

- Clean, readable design for clinical research

- Conservative color scheme

## Examples

``` r
library(ggplot2)
ggplot(mtcars, aes(wt, mpg)) +
  geom_point() +
  theme_lancet()

```
