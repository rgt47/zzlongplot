# Get CDISC Variable Suggestions for Common Scenarios

Provides template variable names for common clinical trial analysis
scenarios.

## Usage

``` r
get_cdisc_template(scenario = "efficacy")
```

## Arguments

- scenario:

  Character string specifying the analysis scenario. Options:
  "efficacy", "safety", "pk" (pharmacokinetics), "biomarker".

## Value

Character vector of recommended variable names.

## See also

Other CDISC utilities:
[`suggest_clinical_vars()`](https://rgt47.github.io/zzlongplot/reference/suggest_clinical_vars.md),
[`validate_cdisc_data()`](https://rgt47.github.io/zzlongplot/reference/validate_cdisc_data.md)

## Examples

``` r
efficacy_vars <- get_cdisc_template("efficacy")
safety_vars <- get_cdisc_template("safety")
```
