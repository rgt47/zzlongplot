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

A list containing:

- suggested_formula: Recommended formula for lplot

- detected_vars: List of detected CDISC variables by category

- cluster_var: Recommended cluster variable (subject ID)

- baseline_value: Detected baseline visit value

- warnings: Any data quality or compliance issues

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
