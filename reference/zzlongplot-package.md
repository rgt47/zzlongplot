# Flexible Plotting of Observed and Change Values with Grouping and Faceting

These functions provide a flexible framework for generating observed and
change plots using a data frame, accommodating both continuous and
categorical variables for the x-axis. They handle baseline
(`baseline_value`) specification, grouping, and faceting. This version
allows the user to return either the observed plot, the change plot, or
both combined side-by-side using the **patchwork** package.

## Details

- `compute_stats`: Computes summary statistics for observed and change
  values, adapting to continuous or categorical x-axis variables.

- `generate_plot`: Dynamically generates ggplot objects based on whether
  the x-axis is continuous or categorical, supports error representation
  (bars or ribbons), and faceting.

- `parse_formula`: Parses the formula to extract dependent, independent,
  grouping, and faceting variables.

- `lplot`: Combines the functionality of the helper functions to produce
  the final plots or combined plots as specified.
