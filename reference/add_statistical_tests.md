# Add Statistical Tests to Summary Statistics

Internal function to add statistical comparisons between groups at each
timepoint. Dispatches to pointwise tests (parametric or non-parametric)
or a joint MMRM model with emmeans contrasts.

## Usage

``` r
add_statistical_tests(
  stats_df,
  original_df,
  x_var,
  y_var,
  group_var,
  cluster_var,
  test_method = "parametric",
  p_adjust_method = "BH",
  cov_struct = "auto"
)
```

## Arguments

- stats_df:

  Summary statistics data frame.

- original_df:

  Original data frame.

- x_var:

  X variable name.

- y_var:

  Y variable name.

- group_var:

  Group variable name.

- cluster_var:

  Cluster variable name.

- test_method:

  Character. Testing approach: "parametric" (t-test / ANOVA),
  "nonparametric" (Wilcoxon rank-sum / Kruskal-Wallis), or "mmrm" (mixed
  model for repeated measures with emmeans contrasts). Default is
  "parametric".

- p_adjust_method:

  Character. Method for multiple comparison correction. For pointwise
  tests, passed to
  [`stats::p.adjust()`](https://rdrr.io/r/stats/p.adjust.html). For
  MMRM, passed to emmeans as the `adjust` argument. Default is "BH". Use
  "none" to disable adjustment.

- cov_struct:

  Character. Covariance structure for MMRM. Default is "auto". See
  [`lplot()`](https://rgt47.github.io/zzlongplot/reference/lplot.md) for
  options.

## Value

Enhanced statistics data frame with p-values.
