# Parse Formula Components for Longitudinal Plotting

Parses an R formula object into its constituent components for use in
longitudinal plotting functions. This function extracts variables for
plotting observed values and changes over time, with optional grouping
and faceting specifications.

## Usage

``` r
parse_formula(formula)
```

## Arguments

- formula:

  An R formula object. The formula can have the following forms:

  - `y ~ x` (simple x-y relationship)

  - `y ~ x | group` (with grouping)

  - `y ~ x | group ~ facet` (with grouping and single facet)

  - `y ~ x | group ~ facet1 + facet2` (with grouping and multiple
    facets)

## Value

A list with four components:

- `y`: character string, the dependent variable name (e.g., measure
  value)

- `x`: character string, the independent variable name (typically time
  or visit)

- `group`: character string or NULL, the grouping variable name if
  specified

- `facets`: character vector or NULL, the faceting variable name(s) if
  specified

## Details

The function processes formula components in the following order:

1.  Extracts the y-variable (dependent variable) from the left-hand side
    of the first '~'

2.  Extracts the x-variable (typically time/visit) from before the '\|'
    on the right-hand side

3.  If present, extracts the grouping variable after the '\|'

4.  If present, extracts faceting variables after the second '~'

Multiple faceting variables should be separated by '+'. The function is
designed to work with both continuous and categorical x-variables,
supporting the flexible plotting capabilities of the zzlongplot package.

## Examples

``` r
# Simple longitudinal measurement
parse_formula(score ~ visit)
#> $y
#> [1] "score"
#> 
#> $x
#> [1] "visit"
#> 
#> $group
#> NULL
#> 
#> $facets
#> NULL
#> 

# With treatment group
parse_formula(score ~ visit | treatment)
#> $y
#> [1] "score"
#> 
#> $x
#> [1] "visit"
#> 
#> $group
#> [1] "treatment"
#> 
#> $facets
#> NULL
#> 

# With treatment group and site facet
parse_formula(score ~ visit | treatment ~ site)
#> $y
#> [1] "score"
#> 
#> $x
#> [1] "visit"
#> 
#> $group
#> [1] "treatment"
#> 
#> $facets
#> [1] "site"
#> 

# With treatment group and multiple facets
parse_formula(score ~ visit | treatment ~ site + gender)
#> $y
#> [1] "score"
#> 
#> $x
#> [1] "visit"
#> 
#> $group
#> [1] "treatment"
#> 
#> $facets
#> [1] "site"   "gender"
#> 
```
