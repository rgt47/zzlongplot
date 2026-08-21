# Science Journal Theme

Creates a publication-ready theme following Science journal guidelines.

## Usage

``` r
theme_science(base_size = 7, base_family = "sans", grid = TRUE)
```

## Arguments

- base_size:

  Base font size in points. Default is 7pt per Science guidelines.

- base_family:

  Font family. Default is "sans" (Helvetica equivalent).

- grid:

  Logical. Whether to show major grid lines.

## Value

A ggplot2 theme object.

## Details

Science journal specifications:

- Font: Arial, 6-7pt minimum

- Single column: 8.5 cm, Double column: 17.8 cm

- Clean, minimalist design

- Grid lines acceptable but subtle

## See also

Other publication themes:
[`theme_bw_print()`](https://rgt47.github.io/zzlongplot/reference/theme_bw_print.md),
[`theme_fda()`](https://rgt47.github.io/zzlongplot/reference/theme_fda.md),
[`theme_jama()`](https://rgt47.github.io/zzlongplot/reference/theme_jama.md),
[`theme_jco()`](https://rgt47.github.io/zzlongplot/reference/theme_jco.md),
[`theme_lancet()`](https://rgt47.github.io/zzlongplot/reference/theme_lancet.md),
[`theme_nature()`](https://rgt47.github.io/zzlongplot/reference/theme_nature.md),
[`theme_nejm()`](https://rgt47.github.io/zzlongplot/reference/theme_nejm.md)

## Examples

``` r
library(ggplot2)
ggplot(mtcars, aes(wt, mpg)) +
  geom_point() +
  theme_science()

```
