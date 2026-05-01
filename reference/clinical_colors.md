# Clinical Trial Color Palettes

Provides standardized color palettes for clinical trial visualizations,
following industry conventions for treatment group representation.

## Usage

``` r
clinical_colors(type = "treatment", n = NULL, placebo_first = TRUE)
```

## Arguments

- type:

  Character string specifying the type of clinical palette. Options:
  "treatment" (standard treatment colors), "severity" (condition
  severity), "outcome" (positive/negative outcomes), "fda" (FDA
  submission), or journal-specific palettes: "nejm", "nature", "lancet",
  "jama", "science", "jco". Default is "treatment".

- n:

  Integer specifying the number of colors needed. If not specified,
  returns the full palette.

- placebo_first:

  Logical. If TRUE, places placebo color first in treatment palettes.
  Default is TRUE.

## Value

A character vector of hex color codes.

## Details

Clinical color palettes follow these conventions:

- **Treatment**: Placebo in neutral grey, active treatments in distinct
  colors

- **Severity**: Progression from mild (light) to severe (dark)

- **Outcome**: Green for positive, red for negative, grey for neutral

- **FDA**: High contrast colors for regulatory submissions

Journal-specific palettes (based on ggsci package):

- **NEJM**: New England Journal of Medicine official colors

- **Nature**: Nature Publishing Group colors (Nature Reviews Cancer)

- **Lancet**: Lancet journal colors (Lancet Oncology)

- **JAMA**: Journal of the American Medical Association colors

- **Science**: Science journal (AAAS) colors

- **JCO**: Journal of Clinical Oncology colors

All palettes maintain distinction in grayscale printing and follow
accessibility guidelines.

## Examples

``` r
# Standard treatment palette
colors <- clinical_colors("treatment", n = 3)

# Severity progression
severity_colors <- clinical_colors("severity", n = 5)

# Journal-specific palettes
nejm_colors <- clinical_colors("nejm", n = 4)
nature_colors <- clinical_colors("nature", n = 4) 
lancet_colors <- clinical_colors("lancet", n = 4)

# Use in plot
df <- data.frame(
  visit = rep(1:4, 60),
  efficacy = rnorm(240),
  treatment = rep(c("Placebo", "Drug 10mg", "Drug 20mg"), each = 80)
)
```
