# Apply Clinical Color Scheme to ggplot

Convenience function to apply clinical color schemes to ggplot objects.

## Usage

``` r
apply_clinical_colors(
  plot,
  treatment_var = NULL,
  palette_type = "treatment",
  ...
)
```

## Arguments

- plot:

  A ggplot object.

- treatment_var:

  Character string specifying the treatment variable name.

- palette_type:

  Character string specifying the clinical palette type.

- ...:

  Additional arguments passed to scale_color_manual and
  scale_fill_manual.

## Value

The input `plot` with manual color and fill scales added, assigning gray
to any detected placebo or control level and distinct colors to the
active arms. If `treatment_var` is not a column of the plot's data, the
plot is returned **unchanged** and a warning is issued.

## See also

[`assign_treatment_colors()`](https://rgt47.github.io/zzlongplot/reference/assign_treatment_colors.md)
for the underlying name-to-color mapping,
[`clinical_colors()`](https://rgt47.github.io/zzlongplot/reference/clinical_colors.md)
for the palettes, and
[`apply_publication_style()`](https://rgt47.github.io/zzlongplot/reference/apply_publication_style.md)
to apply a journal theme at the same time.

Other color helpers:
[`assign_treatment_colors()`](https://rgt47.github.io/zzlongplot/reference/assign_treatment_colors.md),
[`clinical_colors()`](https://rgt47.github.io/zzlongplot/reference/clinical_colors.md),
[`get_colorblind_palette()`](https://rgt47.github.io/zzlongplot/reference/get_colorblind_palette.md)

## Examples

``` r
library(ggplot2)

# Create sample data
data <- data.frame(
  visit = rep(1:4, each = 10),
  efficacy = rnorm(40, mean = 50, sd = 10),
  treatment = rep(c("Placebo", "Drug A"), length.out = 40)
)

# Create base plot
p <- ggplot(data, aes(x = visit, y = efficacy, color = treatment)) +
  geom_line()

# Apply clinical colors
p_clinical <- apply_clinical_colors(p, "treatment")
```
