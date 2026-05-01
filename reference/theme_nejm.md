# New England Journal of Medicine Theme

Creates a publication-ready theme following NEJM guidelines for clinical
publications.

## Usage

``` r
theme_nejm(base_size = 8, base_family = "sans", clinical = TRUE)
```

## Arguments

- base_size:

  Base font size in points. Default is 8pt.

- base_family:

  Font family. Default is "sans" (Helvetica equivalent).

- clinical:

  Logical. If TRUE, applies clinical trial specific styling.

## Value

A ggplot2 theme object.

## Details

NEJM specifications for clinical figures:

- Professional, clinical appearance

- Clear axis labels and readable fonts

- Suitable for medical/clinical publication

- Conservative, trustworthy design

## Examples

``` r
library(ggplot2)
ggplot(mtcars, aes(wt, mpg)) +
  geom_point() +
  theme_nejm()

```
