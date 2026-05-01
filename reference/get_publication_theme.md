# Get Publication Theme by Name

Convenience function to get publication themes by name.

## Usage

``` r
get_publication_theme(theme_name = "nature", ...)
```

## Arguments

- theme_name:

  Character string specifying theme name. Options: "nature", "science",
  "nejm", "lancet", "jama", "jco", "fda", "default".

- ...:

  Additional arguments passed to specific theme functions.

## Value

A ggplot2 theme object.

## Examples

``` r
theme_pub <- get_publication_theme("nature")
#> Warning: The `size` argument of `element_line()` is deprecated as of ggplot2 3.4.0.
#> ℹ Please use the `linewidth` argument instead.
#> ℹ The deprecated feature was likely used in the zzlongplot package.
#>   Please report the issue at <https://github.com/rgt47/zzlongplot/issues>.
#> Warning: The `size` argument of `element_rect()` is deprecated as of ggplot2 3.4.0.
#> ℹ Please use the `linewidth` argument instead.
#> ℹ The deprecated feature was likely used in the zzlongplot package.
#>   Please report the issue at <https://github.com/rgt47/zzlongplot/issues>.
theme_reg <- get_publication_theme("fda", high_contrast = TRUE)
```
