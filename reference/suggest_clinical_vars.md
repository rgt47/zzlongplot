# Suggest Clinical Variables for Formula Construction

Automatically detects likely CDISC variables in a dataset and suggests
appropriate formula syntax for longitudinal plotting.

## Usage

``` r
suggest_clinical_vars(data, verbose = TRUE)
```

## Arguments

- data:

  A data frame containing clinical trial data.

- verbose:

  Logical. If TRUE, provides detailed suggestions and warnings.

## Value

Invisibly, a list of five elements. The function is normally called for
its side effect: when `verbose = TRUE` (the default) it prints a
formatted report to the console. Assign the result to inspect it.

- `suggested_formula`: recommended formula for
  [`lplot()`](https://rgt47.github.io/zzlongplot/reference/lplot.md), as
  a character string, or `NA_character_` if required variables were not
  found.

- `detected_vars`: named list of detected CDISC variables by category
  (`subject_id`, `visit`, `analysis_value`, `treatment`, `change`,
  `population`); entries are `character(0)` when nothing matched.

- `cluster_var`: recommended cluster variable (subject ID).

- `baseline_value`: detected baseline visit value.

- `warnings`: character vector of data-quality or compliance issues;
  `character(0)` when none.

## See also

[`validate_cdisc_data()`](https://rgt47.github.io/zzlongplot/reference/validate_cdisc_data.md)
for a compliance score, and
[`get_cdisc_template()`](https://rgt47.github.io/zzlongplot/reference/get_cdisc_template.md)
for the expected variables of a scenario.

Other CDISC utilities:
[`get_cdisc_template()`](https://rgt47.github.io/zzlongplot/reference/get_cdisc_template.md),
[`validate_cdisc_data()`](https://rgt47.github.io/zzlongplot/reference/validate_cdisc_data.md)

## Examples

``` r
# Clinical trial dataset
clinical_data <- data.frame(
  USUBJID = paste0("001-", 1:20),
  AVISITN = rep(c(0, 1, 2, 3), 5),
  AVAL = rnorm(20),
  TRT01P = rep(c("Placebo", "Active"), 10)
)

suggestions <- suggest_clinical_vars(clinical_data)
#> CDISC Variable Detection Results:
#> =================================
#> 
#> Suggested Formula: AVAL ~ AVISITN | TRT01P 
#> Cluster Variable: USUBJID 
#> Baseline Value: 0 
#> 
#> Detected Variables:
#>   subject_id: USUBJID
#>   visit: AVISITN
#>   analysis_value: AVAL
#>   treatment: TRT01P
#> 
#> Warnings:
#>   ! Dataset appears to have limited longitudinal data (< 2 observations per subject).
#>   ! No population analysis flags detected. Consider adding SAFFL, FASFL.
#> 
print(suggestions$suggested_formula)
#> [1] "AVAL ~ AVISITN | TRT01P"
```
