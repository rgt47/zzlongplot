# Compute Summary Statistics for Longitudinal Data

Computes summary statistics for observed and change values in
longitudinal data, supporting both continuous and categorical x-axis
variables.

## Usage

``` r
compute_stats(
  df,
  x_var,
  y_var,
  group_var,
  cluster_var,
  baseline_value,
  confidence_interval = NULL,
  summary_statistic = "mean",
  show_sample_sizes = FALSE,
  statistical_tests = FALSE,
  facet_vars = NULL
)
```

## Arguments

- df:

  A data frame containing the data to be plotted.

- x_var:

  The independent variable (x-axis) name.

- y_var:

  The dependent variable (y-axis) name.

- group_var:

  Grouping variable for data (optional).

- cluster_var:

  Cluster variable for within-subject grouping (subject ID).

- baseline_value:

  Baseline value for calculating changes.

- confidence_interval:

  Numeric. Confidence level (e.g., 0.95 for 95% CI). If specified,
  calculates confidence intervals instead of standard error.

- summary_statistic:

  Character. Type of summary statistic: "mean" (mean ± CI/SE), "mean_se"
  (mean ± SE), "median" (median + IQR), or "boxplot" (quartiles +
  whiskers).

- show_sample_sizes:

  Logical. If TRUE, includes sample sizes in output.

- statistical_tests:

  Logical. If TRUE, performs statistical comparisons.

- facet_vars:

  Character vector. Names of variables to use for faceting (optional).

## Value

A data frame containing the computed statistics with columns:

- Original x and group variables

- mean_value: Mean/median of y values (depending on summary_statistic)

- change_mean: Mean/median of change from baseline

- sample_size: Number of observations

- standard_deviation: SD of y values (for mean) or IQR (for median)

- change_sd: SD of change values (for mean) or IQR (for median)

- standard_error: Standard error of mean/median

- change_se: Standard error of change mean/median

- bound_lower/bound_upper: Lower/upper bounds (CI/SE for mean, Q1/Q3 for
  median)

- bound_lower_change/bound_upper_change: Bounds for change values

- group: Factor combining all grouping variables

- is_continuous: Boolean indicating if x is continuous

## Examples

``` r
df <- data.frame(
  subject_id = rep(1:10, each = 3),
  visit = rep(c(0, 1, 2), times = 10),
  measure = rnorm(30, mean = 50, sd = 10),
  group = rep(c("A", "B"), length.out = 30)
)
# Compute statistics with visit as x variable, measure as y variable,
# grouped by treatment group, with subject_id as the cluster variable
stats <- compute_stats(df, "visit", "measure", "group", "subject_id", 0)
head(stats)
#> # A tibble: 6 × 15
#>   group visit mean_value change_mean sample_size standard_deviation change_sd
#>   <fct> <dbl>      <dbl>       <dbl>       <int>              <dbl>     <dbl>
#> 1 A         0       42.8       0               5               4.55      0   
#> 2 A         1       45.8      -0.375           5               7.01     17.2 
#> 3 A         2       60.1      17.3             5               7.16     10.8 
#> 4 B         0       46.2       0               5              10.5       0   
#> 5 B         1       49.7       6.90            5              14.9      14.5 
#> 6 B         2       50.9       4.65            5               7.85      7.78
#> # ℹ 8 more variables: standard_error <dbl>, change_se <dbl>, bound_lower <dbl>,
#> #   bound_upper <dbl>, bound_lower_change <dbl>, bound_upper_change <dbl>,
#> #   ci_level <lgl>, is_continuous <lgl>
```
