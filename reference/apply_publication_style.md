# Apply Publication Theme with Color Palette

Convenience function that applies both publication theme and appropriate
color palette.

## Usage

``` r
apply_publication_style(plot, theme_name = "nature", color_palette = NULL, ...)
```

## Arguments

- plot:

  A ggplot object.

- theme_name:

  Character string specifying theme name.

- color_palette:

  Character string specifying color palette or vector of colors.
  Options: "clinical", "treatment", "severity", "outcome", "fda", or
  journal-specific palettes: "nejm", "nature", "lancet", "jama",
  "science", "jco".

- ...:

  Additional arguments passed to theme function.

## Value

Modified ggplot object.

## Examples

``` r
 
if (FALSE) { # \dontrun{
library(ggplot2)
p <- ggplot(mtcars, aes(wt, mpg, color = factor(cyl))) + geom_point()
p_pub <- apply_publication_style(p, "nature", "clinical")

# Apply journal-specific theme and colors together
p_nejm <- apply_publication_style(p, "nejm", "nejm")
p_nature <- apply_publication_style(p, "nature", "nature")
p_lancet <- apply_publication_style(p, "lancet", "lancet")
} # }
```
