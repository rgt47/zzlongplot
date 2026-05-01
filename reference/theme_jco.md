# JCO Journal Theme

Creates a publication-ready theme following JCO journal guidelines.

## Usage

``` r
theme_jco(base_size = 8, base_family = "sans", grid = FALSE)
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

JCO journal specifications:

- Oncology-focused styling

- Professional clinical appearance

- Clean, medical design

## Examples

``` r
library(ggplot2)
ggplot(mtcars, aes(wt, mpg)) +
  geom_point() +
  theme_jco()

```
