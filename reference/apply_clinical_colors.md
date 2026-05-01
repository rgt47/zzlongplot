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

Modified ggplot object with clinical colors applied.

## Examples

``` r
if (FALSE) { # \dontrun{
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
} # }
```
