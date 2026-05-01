# Detect Treatment Groups for Color Assignment

Automatically detects placebo and treatment groups from treatment
variable and assigns appropriate colors following clinical conventions.

## Usage

``` r
assign_treatment_colors(treatment_var, palette_type = "treatment")
```

## Arguments

- treatment_var:

  Character vector of treatment names.

- palette_type:

  Character string specifying color palette type.

## Value

Named character vector of colors with treatment names as names.

## Details

This function uses pattern matching to identify placebo groups and
assigns neutral grey color, while active treatments get distinct colors.

Placebo detection patterns include: "placebo", "control", "sham",
case-insensitive matching.

## Examples

``` r
treatments <- c("Placebo", "Drug A 10mg", "Drug A 20mg")
colors <- assign_treatment_colors(treatments)
```
