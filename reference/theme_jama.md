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

## See also

Other publication themes:
[`theme_bw_print()`](https://rgt47.github.io/zzlongplot/reference/theme_bw_print.md),
[`theme_fda()`](https://rgt47.github.io/zzlongplot/reference/theme_fda.md),
[`theme_jco()`](https://rgt47.github.io/zzlongplot/reference/theme_jco.md),
[`theme_lancet()`](https://rgt47.github.io/zzlongplot/reference/theme_lancet.md),
[`theme_nature()`](https://rgt47.github.io/zzlongplot/reference/theme_nature.md),
[`theme_nejm()`](https://rgt47.github.io/zzlongplot/reference/theme_nejm.md),
[`theme_science()`](https://rgt47.github.io/zzlongplot/reference/theme_science.md)

## Examples

``` r
library(ggplot2)
ggplot(mtcars, aes(wt, mpg)) +
  geom_point() +
  theme_jama()

```
