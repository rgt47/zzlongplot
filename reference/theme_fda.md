# FDA Regulatory Theme

Creates a theme suitable for FDA regulatory submissions and clinical
study reports.

## Usage

``` r
theme_fda(base_size = 10, base_family = "sans", high_contrast = TRUE)
```

## Arguments

- base_size:

  Base font size in points. Default is 10pt for regulatory readability.

- base_family:

  Font family. Default is "sans" (Helvetica equivalent).

- high_contrast:

  Logical. If TRUE, uses high contrast styling.

## Value

A ggplot2 theme object.

## Details

FDA regulatory specifications:

- High readability for regulatory review

- Conservative, professional styling

- Clear distinctions for regulatory clarity

- Suitable for CSR (Clinical Study Report) inclusion

## Examples

``` r
library(ggplot2)
ggplot(mtcars, aes(wt, mpg)) +
  geom_point() +
  theme_fda()

```
