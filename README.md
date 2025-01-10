
# **zzlongplot**

`zzlongplot` is  an R package for flexible, dynamic visualization of observed and change values in longitudinal datasets. Designed for both continuous and categorical variables, `zzlongplot` simplifies the creation of grouped and faceted plots, offering customization options for axes, titles, and error representations. 

This package is particularly useful for analyzing longitudinal clinical trial data, repeated measures, or any data with a time- or visit-dependent structure.

---

## **Features**

- **Dynamic Plotting**: Automatically adapts plots for continuous or categorical x-axis variables.
- **Observed and Change Plots**: Easily visualize both observed values and their changes relative to a baseline (`zeroval`).
- **Grouping and Faceting**: Support for multiple grouping variables and faceting for stratified visualizations.
- **Custom Error Representation**: Choose between error bars or ribbons to represent uncertainty.
- **Combining Plots**: Use the **patchwork** package to display observed and change plots side-by-side.
- **Non-standard Evaluation (NSE)**: Seamless integration with formulas for specifying variables.

---

## **Installation**

### Install from GitHub
To install the development version directly from GitHub, use the following command:
```r
# Install devtools if not already installed
install.packages("devtools")

# Install zzlongplot from GitHub
devtools::install_github("your-username/zzlongplot")
```

---

## **Quick Start**

Here’s how to get started with `zzlongplot`:

### **Example 1: Continuous x-axis**

```r
# Load the required libraries
library(zzlongplot)
library(ggplot2)

# Example dataset
df <- data.frame(
  rid = rep(1:10, each = 3),
  visit = rep(c(0, 1, 2), times = 10),
  measure = rnorm(30, mean = 50, sd = 10),
  group = rep(c("A", "B"), length.out = 30)
)

# Generate the plot
plot <- lplot(
  df, 
  form = measure ~ visit | group, 
  zeroval = 0, 
  xlab = "Visit", 
  ylab = "Measure", 
  title = "Observed Measures Over Time"
)
print(plot)
```

### **Example 2: Categorical x-axis**

```r
# Example dataset with categorical x-axis
df <- data.frame(
  rid = rep(1:10, each = 3),
  visit = rep(c("baseline", "month1", "month2"), times = 10),
  measure = rnorm(30, mean = 50, sd = 10),
  group = rep(c("A", "B"), length.out = 30)
)

# Generate the plot
plot <- lplot(
  df, 
  form = measure ~ visit | group, 
  zeroval = "baseline", 
  xlab = "Visit", 
  ylab = "Measure", 
  title = "Observed Measures Over Time"
)
print(plot)
```

---

## **Functions**

### `lplot`
The main function for generating plots. Combines the functionality of helper functions to produce observed plots, change plots, or both.

- **Arguments**:
  - `df`: The data frame containing the data.
  - `form`: A formula specifying the dependent (`y`) and independent (`x`) variables, as well as grouping variables.
  - `facet_form`: An optional formula for faceting.
  - `clustervar`: The column name for the clustering variable.
  - `zeroval`: The baseline value for calculating changes.
  - Other arguments for customizing axis labels, titles, and error types.

---

### Helper Functions

- **`compute_stats`**:
  Computes summary statistics for observed and change values, accounting for grouping, faceting, and baseline (`zeroval`).

- **`generate_plot`**:
  Creates a ggplot object with dynamic axis scaling, grouping, faceting, and error representation.

- **`parse_formula`**:
  Parses the formula to extract dependent, independent, grouping, and faceting variables.

---

## **Customization**

### Error Types
You can customize how errors are displayed:
- `"bar"`: Error bars
- `"band"`: Error ribbons

### Faceting
Faceting allows stratified visualizations. Use the `facet_form` argument to specify row and column facets.

### Combining Plots
Use the `"both"` option for `ytype` to display observed and change plots side-by-side using the **patchwork** package.

---

## **Dependencies**

The `zzlongplot` package depends on the following R packages:
- **dplyr**: For data manipulation.
- **ggplot2**: For visualization.
- **patchwork**: For combining plots.

Ensure these packages are installed before using `zzlongplot`.

---

## **Contributing**

We welcome contributions to `zzlongplot`! If you'd like to contribute:
1. Fork the repository.
2. Create a feature branch.
3. Submit a pull request.

For bug reports or feature requests, please open an issue on GitHub.

---

## **License**

`zzlongplot` is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## **Acknowledgments**

The `zzlongplot` package was inspired by the need for simple yet flexible tools to visualize longitudinal data in clinical and biomedical research.

---

If you have questions or need help, feel free to reach out via the [GitHub Issues](https://github.com/your-username/zzlongplot/issues) page.
