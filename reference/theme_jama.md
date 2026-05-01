# JAMA Journal Theme

Creates a publication-ready theme following JAMA journal guidelines.

## Usage

``` r
theme_jama(base_size = 8, base_family = "sans", grid = FALSE)
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

JAMA journal specifications:

- Conservative, professional styling

- Medical journal typography

- Clean, readable design

## Examples

``` r
library(ggplot2)
ggplot(mtcars, aes(wt, mpg)) +
  geom_point() +
  theme_jama()

```
