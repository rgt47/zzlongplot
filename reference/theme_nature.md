# Publication-Ready ggplot2 Themes

Provides professional themes for scientific publications, following
specific journal guidelines and regulatory requirements.

Creates a publication-ready theme following Nature journal guidelines.

## Usage

``` r
theme_nature(base_size = 7, base_family = "sans", grid = FALSE, border = TRUE)
```

## Arguments

- base_size:

  Base font size in points. Default is 7pt per Nature guidelines.

- base_family:

  Font family. Default is "sans" (Helvetica equivalent).

- grid:

  Logical. Whether to show grid lines. Default is FALSE for clean look.

- border:

  Logical. Whether to show panel border. Default is TRUE.

## Value

A ggplot2 theme object.

## Details

These themes are designed to meet the formatting requirements of major
scientific journals and regulatory agencies, with proper typography,
spacing, and clean aesthetics suitable for print and digital
publication. Nature Journal Theme

Nature journal specifications:

- Font: Arial or Helvetica, 5-7pt

- Dimensions: 90mm (single) or 180mm (double column)

- Clean backgrounds, minimal grid lines

- Professional appearance for peer review

## See also

Other publication themes:
[`theme_bw_print()`](https://rgt47.github.io/zzlongplot/reference/theme_bw_print.md),
[`theme_fda()`](https://rgt47.github.io/zzlongplot/reference/theme_fda.md),
[`theme_jama()`](https://rgt47.github.io/zzlongplot/reference/theme_jama.md),
[`theme_jco()`](https://rgt47.github.io/zzlongplot/reference/theme_jco.md),
[`theme_lancet()`](https://rgt47.github.io/zzlongplot/reference/theme_lancet.md),
[`theme_nejm()`](https://rgt47.github.io/zzlongplot/reference/theme_nejm.md),
[`theme_science()`](https://rgt47.github.io/zzlongplot/reference/theme_science.md)

## Examples

``` r
library(ggplot2)
ggplot(mtcars, aes(wt, mpg)) + 
  geom_point() + 
  theme_nature()

  
```
