
# **zzlongplot**

`zzlongplot` is an R package for flexible, dynamic visualization of observed and change values in longitudinal datasets. Designed for both continuous and categorical variables, `zzlongplot` simplifies the creation of grouped and faceted plots, offering customization options for axes, titles, and error representations. 

This package is particularly useful for analyzing longitudinal clinical trial data, repeated measures, or any data with a time- or visit-dependent structure.

---

## **Features**

### **Core Functionality**
- **Dynamic Plotting**: Automatically adapts plots for continuous or categorical x-axis variables.
- **Observed and Change Plots**: Easily visualize both observed values and their changes relative to a baseline (`baseline_value`).
- **Grouping and Faceting**: Support for multiple grouping variables and faceting for stratified visualizations.
- **Custom Error Representation**: Choose between error bars or ribbons to represent uncertainty.
- **Combining Plots**: Use the **patchwork** package to display observed and change plots side-by-side.
- **Formula Interface**: Seamless integration with formulas for specifying variables (`y ~ x | group`).

### **Clinical Trials Support** 🏥
- **CDISC Compliance**: Automatic recognition of standard CDISC variable names (AVAL, AVISITN, TRT01P, etc.)
- **Clinical Themes**: FDA and regulatory-ready plot styling with professional themes
- **Treatment Styling**: Predefined color schemes for placebo vs. active treatment visualization
- **Visit Windows**: Handle visit timing variations common in clinical trials
- **Clinical Statistics**: 95% confidence intervals, sample size annotations, missing data handling
- **Regulatory Output**: Export plots in formats suitable for regulatory submissions

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
  subject_id = rep(1:10, each = 3),
  visit = rep(c(0, 1, 2), times = 10),
  measure = rnorm(30, mean = 50, sd = 10),
  group = rep(c("A", "B"), length.out = 30)
)

# Generate the plot
plot <- lplot(
  df, 
  form = measure ~ visit | group, 
  cluster_var = "subject_id",
  baseline_value = 0, 
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
  subject_id = rep(1:10, each = 3),
  visit = rep(c("baseline", "month1", "month2"), times = 10),
  measure = rnorm(30, mean = 50, sd = 10),
  group = rep(c("A", "B"), length.out = 30)
)

# Generate the plot
plot <- lplot(
  df, 
  form = measure ~ visit | group, 
  cluster_var = "subject_id",
  baseline_value = "baseline", 
  xlab = "Visit", 
  ylab = "Measure", 
  title = "Observed Measures Over Time"
)
print(plot)
```

### **Example 3: Clinical Trial with CDISC Variables** 🏥

```r
# Clinical trial data with CDISC variable names
clinical_data <- data.frame(
  SUBJID = rep(paste0("001-", sprintf("%03d", 1:20)), each = 4),
  AVISITN = rep(c(0, 4, 8, 12), times = 20),  # Visit weeks
  AVAL = rnorm(80, mean = c(45, 42, 38, 35), sd = 8),  # Efficacy score
  TRT01P = rep(c("Placebo", "Drug A", "Drug B"), length.out = 80),
  CHG = NA  # Will be calculated automatically
)

# Clinical mode - automatically handles CDISC variables and styling
plot_clinical <- lplot(
  clinical_data,
  form = AVAL ~ AVISITN | TRT01P,
  cluster_var = "SUBJID",
  baseline_value = 0,
  clinical_mode = TRUE,           # Enables clinical defaults
  treatment_colors = "standard",  # Standard clinical colors
  confidence_interval = 0.95,     # 95% CI instead of SE
  show_sample_sizes = TRUE,       # Show N at each timepoint
  plot_type = "both",            # Both observed and change plots
  title = "Efficacy Over Time",
  title2 = "Change from Baseline"
)
print(plot_clinical)
```

---

## **Functions**

### `lplot`
The main function for generating plots. Combines the functionality of helper functions to produce observed plots, change plots, or both.

- **Arguments**:
  - `df`: The data frame containing the data.
  - `form`: A formula specifying the dependent (`y`) and independent (`x`) variables, as well as grouping variables.
  - `facet_form`: An optional formula for faceting.
  - `cluster_var`: The column name for the clustering variable.
  - `baseline_value`: The baseline value for calculating changes.
  - Other arguments for customizing axis labels, titles, and error types.

---

### Helper Functions

- **`compute_stats`**:
  Computes summary statistics for observed and change values, accounting for grouping, faceting, and baseline (`baseline_value`).

- **`generate_plot`**:
  Creates a ggplot object with dynamic axis scaling, grouping, faceting, and error representation.

- **`parse_formula`**:
  Parses the formula to extract dependent, independent, grouping, and faceting variables.

### **Clinical Utilities** 🏥

- **`suggest_clinical_vars()`**:
  Auto-detect likely CDISC variables in your dataset and suggest proper formula syntax.

- **`get_clinical_theme()`**:
  Returns regulatory-ready ggplot2 themes (FDA, EMA, ICH guidelines).

- **`clinical_colors()`**:
  Predefined color palettes for treatment groups following clinical standards.

---

## **Customization**

### Error Types
You can customize how errors are displayed:
- `"bar"`: Error bars
- `"band"`: Error ribbons

### Faceting
Faceting allows stratified visualizations. Use the `facet_form` argument to specify row and column facets.

### Combining Plots
Use the `"both"` option for `plot_type` to display observed and change plots side-by-side using the **patchwork** package.

### **Clinical Trial Customization** 🏥

#### Clinical Modes
```r
# Enable all clinical defaults at once
lplot(data, AVAL ~ AVISITN | TRT01P, clinical_mode = TRUE)

# Or customize individual clinical features
lplot(data, AVAL ~ AVISITN | TRT01P, 
      treatment_colors = "standard",    # Placebo=grey, Active=blue/red
      confidence_interval = 0.95,       # 95% CI instead of SE
      show_sample_sizes = TRUE,         # N at each timepoint
      visit_windows = list("Week 4" = c(22, 35))  # Handle visit windows
)
```

#### CDISC Variable Detection
```r
# Automatically suggests CDISC-compliant formulas
suggest_clinical_vars(clinical_data)
#> Suggested formula: AVAL ~ AVISITN | TRT01P
#> Cluster variable: SUBJID detected
#> Baseline: Visit 1 (AVISITN = 1)
```

#### Regulatory Themes
```r
# FDA submission ready
lplot(data, AVAL ~ AVISITN | TRT01P, theme = "fda")

# EMA guidelines compliant  
lplot(data, AVAL ~ AVISITN | TRT01P, theme = "ema")
```

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
