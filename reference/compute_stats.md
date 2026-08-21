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
  cluster_var = "subject_id",
  baseline_value,
  confidence_interval = NULL,
  summary_statistic = "mean",
  statistical_tests = FALSE,
  facet_vars = NULL,
  test_method = "parametric",
  p_adjust_method = "BH",
  cov_struct = "auto"
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

  Cluster variable for within-subject grouping (subject ID). Defaults to
  `"subject_id"`, matching
  [`lplot()`](https://rgt47.github.io/zzlongplot/reference/lplot.md).

- baseline_value:

  Baseline value for calculating changes.

- confidence_interval:

  Numeric. Confidence level (e.g., 0.95 for 95% CI). If specified,
  calculates confidence intervals instead of standard error.

- summary_statistic:

  Character. Type of summary statistic: "mean" (mean +/- CI/SE),
  "mean_se" (mean +/- SE), "median" (median + IQR), or "boxplot"
  (quartiles + whiskers).

- statistical_tests:

  Logical. If TRUE, performs statistical comparisons.

- facet_vars:

  Character vector. Names of variables to use for faceting (optional).

- test_method:

  Character. Testing approach for group comparisons: "parametric"
  (t-test / ANOVA, the default), "nonparametric" (Wilcoxon rank-sum /
  Kruskal-Wallis), or "mmrm" (mixed model for repeated measures with
  emmeans contrasts; requires the mmrm and emmeans packages).

- p_adjust_method:

  Character. Multiple comparison correction passed to
  [`stats::p.adjust()`](https://rdrr.io/r/stats/p.adjust.html). Default
  is "BH" (Benjamini-Hochberg). Use "none" to disable adjustment.

- cov_struct:

  Character. Covariance structure for MMRM. See
  [`lplot()`](https://rgt47.github.io/zzlongplot/reference/lplot.md) for
  available options. Default is "auto".

## Value

A tibble (`tbl_df`) of one row per x value per group, with one
observation dropped for any group-timepoint whose summary is `NA`.
Columns, in addition to the original x, grouping, and faceting
variables:

- `mean_value`: mean of y, or median when `summary_statistic` is
  `"median"` or `"boxplot"`.

- `change_mean`: the same summary applied to change from baseline.

- `sample_size`: count of non-missing y values, after missing-value
  removal.

- `standard_deviation`, `change_sd`: SD for `"mean"`/`"mean_se"`; IQR
  for `"median"`/`"boxplot"`.

- `standard_error`, `change_se`: the above divided by
  `sqrt(sample_size)`.

- `bound_lower`, `bound_upper`, `bound_lower_change`,
  `bound_upper_change`: the plotted interval. A *t*-based confidence
  interval for `"mean"` with `confidence_interval` set; a
  normal-approximation median interval for `"median"` with
  `confidence_interval` set; +/-1 standard error for `"mean_se"`;
  quartiles for `"median"` without a level; and 1.5-IQR whiskers for
  `"boxplot"`.

- `ci_level`: the confidence level the bounds represent, or `NA` when
  they are not a confidence interval (`"mean_se"`, `"boxplot"`, or no
  `confidence_interval`).

- `group`: an [`interaction()`](https://rdrr.io/r/base/interaction.html)
  factor of the grouping variables, or the character scalar `"all"` when
  `group_var` is `NULL`.

- `is_continuous`: `TRUE` when the x variable is numeric.

When `statistical_tests = TRUE`, three further columns are present:

- `p_value`: the omnibus p-value for that x value, repeated across that
  value's group rows.

- `p_adj`: `p_value` adjusted by `p_adjust_method` across the distinct
  tests (one per x value, not one per row).

- `significance`: a star code derived from `p_adj`.

Additionally, when pairwise comparisons were computed, the result
carries a `"pairwise"` attribute (retrieve with `attr(x, "pairwise")`):
a data frame with columns `x_val`, `group1`, `group2`, `estimate`,
`lower_cl`, `upper_cl`, `p_value`, `p_adj`, and `significance`. This
attribute is absent when no pairwise comparison was performed.

## See also

[`lplot()`](https://rgt47.github.io/zzlongplot/reference/lplot.md) for
the end-to-end workflow,
[`generate_plot()`](https://rgt47.github.io/zzlongplot/reference/generate_plot.md)
which consumes this result, and
[`parse_formula()`](https://rgt47.github.io/zzlongplot/reference/parse_formula.md)
which produces the variable names it expects.

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
#> 1 A         0       49.8        0              5               9.16      0   
#> 2 A         1       53.5        4.81           5              12.5       9.35
#> 3 A         2       57.7        7.92           5               7.82     16.3 
#> 4 B         0       48.7        0              5              13.7       0   
#> 5 B         1       53.0        3.22           5              11.5      15.3 
#> 6 B         2       52.8        4.09           5              11.9      24.1 
#> # ℹ 8 more variables: standard_error <dbl>, change_se <dbl>, bound_lower <dbl>,
#> #   bound_upper <dbl>, bound_lower_change <dbl>, bound_upper_change <dbl>,
#> #   ci_level <dbl>, is_continuous <lgl>
```
