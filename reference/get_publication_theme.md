# Get Publication Theme by Name

Convenience function to get publication themes by name.

## Usage

``` r
get_publication_theme(theme_name = "nature", ...)
```

## Arguments

- theme_name:

  Character string specifying theme name. Options: `"nature"`,
  `"science"`, `"nejm"`, `"lancet"`, `"jama"`, `"jco"`, `"fda"`, `"bw"`,
  `"default"`. `"bw"` is
  [`theme_bw_print()`](https://rgt47.github.io/zzlongplot/reference/theme_bw_print.md)
  and is the fallback used by
  [`lplot()`](https://rgt47.github.io/zzlongplot/reference/lplot.md);
  `"default"` is
  [`ggplot2::theme_bw()`](https://ggplot2.tidyverse.org/reference/ggtheme.html).

- ...:

  Additional arguments passed to the selected theme function. Note that
  the accepted arguments differ by theme: most take `base_size`,
  `base_family`, and `grid`, whereas `"fda"` takes `high_contrast`,
  `"nejm"` takes `clinical`, `"nature"` takes `border`, and `"default"`
  accepts only
  [`ggplot2::theme_bw()`](https://ggplot2.tidyverse.org/reference/ggtheme.html)'s
  arguments.

## Value

A ggplot2 theme object (class `c("theme", "gg")`), suitable for adding
to a plot with `+`.

## See also

The individual themes
[`theme_nature()`](https://rgt47.github.io/zzlongplot/reference/theme_nature.md),
[`theme_science()`](https://rgt47.github.io/zzlongplot/reference/theme_science.md),
[`theme_nejm()`](https://rgt47.github.io/zzlongplot/reference/theme_nejm.md),
[`theme_lancet()`](https://rgt47.github.io/zzlongplot/reference/theme_lancet.md),
[`theme_jama()`](https://rgt47.github.io/zzlongplot/reference/theme_jama.md),
[`theme_jco()`](https://rgt47.github.io/zzlongplot/reference/theme_jco.md),
[`theme_fda()`](https://rgt47.github.io/zzlongplot/reference/theme_fda.md),
[`theme_bw_print()`](https://rgt47.github.io/zzlongplot/reference/theme_bw_print.md);
and
[`apply_publication_style()`](https://rgt47.github.io/zzlongplot/reference/apply_publication_style.md)
to apply a theme and palette together.

## Examples

``` r
theme_pub <- get_publication_theme("nature")
theme_reg <- get_publication_theme("fda", high_contrast = TRUE)
```
