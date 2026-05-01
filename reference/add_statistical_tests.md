# Add Statistical Tests to Summary Statistics

Internal function to add statistical comparisons between groups.

## Usage

``` r
add_statistical_tests(
  stats_df,
  original_df,
  x_var,
  y_var,
  group_var,
  cluster_var
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

## Value

Enhanced statistics data frame with p-values.
