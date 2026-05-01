# Validate CDISC Data Compliance

Checks a clinical dataset for compliance with CDISC standards and
provides recommendations for improvement.

## Usage

``` r
validate_cdisc_data(
  data,
  required_vars = c("USUBJID", "AVISITN", "AVAL"),
  check_population_flags = TRUE
)
```

## Arguments

- data:

  A data frame containing clinical trial data.

- required_vars:

  Character vector of variables that must be present.

- check_population_flags:

  Logical. Whether to check for population flags.

## Value

A list containing compliance score and recommendations.

## Examples

``` r
clinical_data <- data.frame(
  USUBJID = paste0("001-", 1:20),
  AVISITN = rep(c(0, 1, 2, 3), 5),
  AVAL = rnorm(20)
)
validation <- validate_cdisc_data(clinical_data)
print(validation$compliance_score)
#> [1] 80
```
