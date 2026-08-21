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

A list of six elements, returned visibly:

- `compliance_score`: overall score as a percentage of
  `max_possible_score`.

- `score_breakdown`: named list of the seven component scores
  (`required_vars`, `subject_id`, `visit_vars`, `analysis_values`,
  `change_vars`, `treatment_vars`, `population_flags`).

- `issues`: character vector of detected compliance problems;
  `character(0)` when none.

- `recommendations`: character vector of suggested remedies;
  `character(0)` when none.

- `max_possible_score`: the denominator used, normally `100`.

- `actual_score`: the unnormalized points awarded.

## See also

[`suggest_clinical_vars()`](https://rgt47.github.io/zzlongplot/reference/suggest_clinical_vars.md)
to detect CDISC variables and build a formula, and
[`get_cdisc_template()`](https://rgt47.github.io/zzlongplot/reference/get_cdisc_template.md)
for the expected variable set of a given analysis scenario.

Other CDISC utilities:
[`get_cdisc_template()`](https://rgt47.github.io/zzlongplot/reference/get_cdisc_template.md),
[`suggest_clinical_vars()`](https://rgt47.github.io/zzlongplot/reference/suggest_clinical_vars.md)

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
