# zzlongplot Usage Guide

## Table of Contents

1. [Getting Started](#getting-started)
2. [Basic Usage](#basic-usage)
3. [Clinical Trial Analysis](#clinical-trial-analysis)
4. [Advanced Visualizations](#advanced-visualizations)
5. [Publication-Ready Outputs](#publication-ready-outputs)
6. [Customization Options](#customization-options)
7. [Best Practices](#best-practices)
8. [Troubleshooting](#troubleshooting)

## Getting Started

### Installation

Install the package from CRAN or GitHub:

```r
# From CRAN (when available)
install.packages("zzlongplot")

# From GitHub (development version)
devtools::install_github("rgt47/zzlongplot")
```

### Loading the Package

```r
library(zzlongplot)
library(ggplot2)  # For additional plot customization
library(dplyr)    # For data manipulation
```

### Basic Data Structure

The package works with longitudinal data in "long" format where each row represents one observation at one timepoint for one subject:

```r
# Example data structure
data <- data.frame(
  subject_id = rep(1:20, each = 4),
  visit = rep(c(0, 1, 2, 3), times = 20),
  efficacy_score = rnorm(80, mean = 50, sd = 10),
  treatment = rep(c("Placebo", "Drug A", "Drug B"), length.out = 80),
  site = rep(c("Site 1", "Site 2"), each = 40)
)
```

## Basic Usage

### Simple Longitudinal Plot

Create a basic plot showing values over time:

```r
# Basic observed values plot
plot_basic <- lplot(
  data,
  efficacy_score ~ visit | treatment,
  cluster_var = "subject_id",
  baseline_value = 0,
  title = "Efficacy Over Time"
)
print(plot_basic)
```

### Change from Baseline Plot

Show change from baseline values:

```r
# Change from baseline plot
plot_change <- lplot(
  data,
  efficacy_score ~ visit | treatment,
  cluster_var = "subject_id",
  baseline_value = 0,
  plot_type = "change",
  title = "Change from Baseline"
)
print(plot_change)
```

### Combined Plots

Display both observed and change plots side-by-side:

```r
# Combined observed and change plots
plot_both <- lplot(
  data,
  efficacy_score ~ visit | treatment,
  cluster_var = "subject_id",
  baseline_value = 0,
  plot_type = "both",
  title = "Efficacy Scores",
  title2 = "Change from Baseline"
)
print(plot_both)
```

### Categorical Time Variables

Handle categorical visit labels:

```r
# Data with categorical visits
data_cat <- data.frame(
  subject_id = rep(1:20, each = 4),
  visit = rep(c("Baseline", "Week 4", "Week 8", "Week 12"), times = 20),
  score = rnorm(80, mean = 50, sd = 10),
  treatment = rep(c("Placebo", "Active"), each = 40)
)

# Plot with categorical x-axis
plot_cat <- lplot(
  data_cat,
  score ~ visit | treatment,
  cluster_var = "subject_id",
  baseline_value = "Baseline",
  title = "Treatment Response Over Time"
)
print(plot_cat)
```

## Clinical Trial Analysis

### CDISC Data Analysis

For clinical trial data following CDISC standards:

```r
# Clinical trial dataset with CDISC variables
clinical_data <- data.frame(
  USUBJID = rep(paste0("001-", sprintf("%03d", 1:30)), each = 5),
  AVISITN = rep(c(0, 1, 2, 3, 4), times = 30),
  AVAL = rnorm(150, mean = c(50, 48, 45, 42, 40), sd = 8),
  TRT01P = rep(c("Placebo", "Drug 10mg", "Drug 20mg"), each = 50),
  PARAM = "Efficacy Score"
)

# Automatic CDISC variable detection
suggestions <- suggest_clinical_vars(clinical_data)
print(suggestions$suggested_formula)
```

### Clinical Mode Analysis

Enable clinical trial defaults:

```r
# Clinical mode with automatic settings
clinical_plot <- lplot(
  clinical_data,
  AVAL ~ AVISITN | TRT01P,
  cluster_var = "USUBJID",
  baseline_value = 0,
  clinical_mode = TRUE,        # Enables clinical defaults
  plot_type = "both",
  title = "Clinical Trial Results",
  title2 = "Change from Baseline"
)
print(clinical_plot)
```

### Treatment Color Schemes

Apply standard clinical color conventions:

```r
# Standard treatment colors
plot_clinical_colors <- lplot(
  clinical_data,
  AVAL ~ AVISITN | TRT01P,
  cluster_var = "USUBJID",
  baseline_value = 0,
  treatment_colors = "standard",  # Placebo=grey, active=colors
  confidence_interval = 0.95,     # 95% confidence intervals
  show_sample_sizes = TRUE        # Show N at each timepoint
)
print(plot_clinical_colors)
```

### CDISC Compliance Validation

Check data compliance with CDISC standards:

```r
# Validate CDISC compliance
validation <- validate_cdisc_data(clinical_data)
print(paste("Compliance Score:", validation$compliance_score, "%"))
print("Recommendations:")
print(validation$recommendations)
```

## Advanced Visualizations

### Error Representation Options

Choose between different error visualization methods:

```r
# Error bars (default)
plot_bars <- lplot(
  data,
  efficacy_score ~ visit | treatment,
  cluster_var = "subject_id",
  error_type = "bar",
  jitter_width = 0.2  # Separate overlapping error bars
)

# Error ribbons/bands
plot_ribbons <- lplot(
  data,
  efficacy_score ~ visit | treatment,
  cluster_var = "subject_id",
  error_type = "band",
  ribbon_alpha = 0.3  # Transparency level
)
```

### Summary Statistics Options

Different statistical summaries:

```r
# Mean with standard error (default)
plot_mean <- lplot(
  data,
  efficacy_score ~ visit | treatment,
  cluster_var = "subject_id",
  summary_statistic = "mean"
)

# Median with IQR
plot_median <- lplot(
  data,
  efficacy_score ~ visit | treatment,
  cluster_var = "subject_id",
  summary_statistic = "median"
)

# Boxplot representation
plot_boxplot <- lplot(
  data,
  efficacy_score ~ visit | treatment,
  cluster_var = "subject_id",
  summary_statistic = "boxplot"
)
```

### Faceting by Additional Variables

Add faceting for complex experimental designs:

```r
# Facet by site
plot_faceted <- lplot(
  data,
  efficacy_score ~ visit | treatment,
  facet_form = ~ site,
  cluster_var = "subject_id",
  baseline_value = 0,
  title = "Treatment Response by Site"
)
print(plot_faceted)
```

### Statistical Annotations

Add statistical comparisons:

```r
# Include statistical tests
plot_stats <- lplot(
  data,
  efficacy_score ~ visit | treatment,
  cluster_var = "subject_id",
  baseline_value = 0,
  statistical_annotations = TRUE,  # Add p-values
  confidence_interval = 0.95       # 95% confidence intervals
)
print(plot_stats)
```

### Reference Lines

Add reference lines for clinical context:

```r
# Add reference lines
reference_lines <- list(
  list(value = 40, axis = "y", color = "red", linetype = "dashed"),
  list(value = 2, axis = "x", color = "blue", linetype = "dotted")
)

plot_refs <- lplot(
  data,
  efficacy_score ~ visit | treatment,
  cluster_var = "subject_id",
  reference_lines = reference_lines
)
print(plot_refs)
```

## Publication-Ready Outputs

### Journal-Specific Themes

Apply themes for specific journals:

```r
# Nature journal theme
plot_nature <- lplot(
  data,
  efficacy_score ~ visit | treatment,
  cluster_var = "subject_id",
  theme = "nature"
)

# NEJM clinical theme
plot_nejm <- lplot(
  clinical_data,
  AVAL ~ AVISITN | TRT01P,
  cluster_var = "USUBJID",
  theme = "nejm"
)

# FDA regulatory theme
plot_fda <- lplot(
  clinical_data,
  AVAL ~ AVISITN | TRT01P,
  cluster_var = "USUBJID",
  theme = "fda"
)
```

### Publication-Ready Export

Save plots with journal specifications:

```r
# Create publication plot
pub_plot <- lplot(
  clinical_data,
  AVAL ~ AVISITN | TRT01P,
  cluster_var = "USUBJID",
  theme = "nature",
  plot_type = "both",
  clinical_mode = TRUE
)

# Save for Nature journal
save_publication(
  pub_plot,
  filename = "figure1.pdf",
  journal = "nature",
  column_type = "double",
  width_mm = 180,  # Double column width
  dpi = 600        # High resolution
)
```

### Multi-Panel Figures

Create complex multi-panel figures:

```r
# Create individual plots
plot1 <- lplot(data, efficacy_score ~ visit | treatment,
               cluster_var = "subject_id", theme = "nature")
plot2 <- lplot(data, safety_score ~ visit | treatment,
               cluster_var = "subject_id", theme = "nature")
plot3 <- lplot(data, biomarker ~ visit | treatment,
               cluster_var = "subject_id", theme = "nature")

# Combine into multi-panel figure
combined_figure <- publication_panels(
  plots = list(plot1, plot2, plot3),
  labels = c("A", "B", "C"),
  layout = "horizontal",
  shared_legend = TRUE
)

# Save combined figure
save_publication(
  combined_figure,
  "figure2.pdf",
  journal = "nature",
  column_type = "double"
)
```

## Customization Options

### Custom Color Palettes

Define custom color schemes:

```r
# Custom colors
custom_colors <- c("#1B9E77", "#D95F02", "#7570B3")

plot_custom <- lplot(
  data,
  efficacy_score ~ visit | treatment,
  cluster_var = "subject_id",
  color_palette = custom_colors
)
```

### Font and Typography Customization

Modify text elements:

```r
# Custom typography
plot_custom_text <- lplot(
  data,
  efficacy_score ~ visit | treatment,
  cluster_var = "subject_id",
  theme = "nature"
) +
theme(
  axis.title = element_text(size = 12, face = "bold"),
  plot.title = element_text(size = 14, hjust = 0.5),
  legend.text = element_text(size = 10)
)
```

### Advanced Plot Modifications

Add custom elements:

```r
# Advanced customization
plot_advanced <- lplot(
  data,
  efficacy_score ~ visit | treatment,
  cluster_var = "subject_id"
) +
labs(
  caption = "Data from clinical trial ABC-123",
  subtitle = "Primary efficacy endpoint"
) +
annotate("text", x = 2, y = 60, label = "Clinically meaningful threshold",
         color = "red", size = 3) +
geom_hline(yintercept = 55, linetype = "dashed", color = "red", alpha = 0.7)
```

## Best Practices

### Data Preparation

1. **Ensure proper data structure**:
   ```r
   # Check data structure
   str(data)

   # Verify required columns exist
   required_cols <- c("subject_id", "visit", "efficacy_score", "treatment")
   missing_cols <- setdiff(required_cols, names(data))
   if (length(missing_cols) > 0) {
     stop("Missing columns: ", paste(missing_cols, collapse = ", "))
   }
   ```

2. **Handle missing data appropriately**:
   ```r
   # Check for missing data
   summary(data)

   # Consider multiple imputation for clinical trials
   # Or use complete case analysis with documentation
   ```

3. **Validate baseline identification**:
   ```r
   # Ensure baseline value exists in data
   unique(data$visit)
   # [1] 0 1 2 3  # Confirm baseline_value = 0 is valid
   ```

### Statistical Considerations

1. **Choose appropriate summary statistics**:
   - Use means for normally distributed data
   - Use medians for skewed data
   - Use boxplots for exploratory analysis

2. **Select confidence intervals appropriately**:
   ```r
   # 95% CI for regulatory submissions
   lplot(..., confidence_interval = 0.95)

   # Standard error for exploratory analysis
   lplot(..., summary_statistic = "mean_se")
   ```

3. **Consider sample size implications**:
   ```r
   # Show sample sizes for transparency
   lplot(..., show_sample_sizes = TRUE)
   ```

### Visualization Guidelines

1. **Choose appropriate error representations**:
   - Error bars for discrete timepoints
   - Ribbons for continuous time trends
   - Boxplots for distribution visualization

2. **Use consistent color schemes**:
   ```r
   # Clinical trials
   lplot(..., treatment_colors = "standard")

   # Publications
   lplot(..., theme = "nature")  # Includes matching colors
   ```

3. **Ensure accessibility**:
   ```r
   # Use colorblind-friendly palettes
   colors <- get_colorblind_palette(n = 3)
   lplot(..., color_palette = colors)
   ```

### Publication Workflow

1. **Plan figure layout early**:
   ```r
   # Check journal requirements
   specs <- get_journal_specs("nature")
   print(specs)
   ```

2. **Create consistent figure series**:
   ```r
   # Use same theme across all figures
   common_theme <- "nature"

   # Apply consistently
   plot1 <- lplot(..., theme = common_theme)
   plot2 <- lplot(..., theme = common_theme)
   ```

3. **Validate output quality**:
   ```r
   # Save high-resolution version for checking
   save_publication(plot, "test.png", journal = "nature", dpi = 300)
   ```

## Troubleshooting

### Common Issues and Solutions

#### Error: "Missing required columns"

**Problem**: The specified variables don't exist in the data.

**Solution**:
```r
# Check column names
names(data)

# Verify formula variables exist
parse_formula(efficacy_score ~ visit | treatment)
```

#### Error: "Baseline value not found"

**Problem**: The specified baseline value doesn't exist in the x variable.

**Solution**:
```r
# Check unique values in visit variable
unique(data$visit)

# Update baseline_value accordingly
lplot(..., baseline_value = 0)  # or "Baseline", etc.
```

#### Warning: "Limited longitudinal data"

**Problem**: Insufficient observations per subject for longitudinal analysis.

**Solution**:
```r
# Check data structure
data %>%
  group_by(subject_id) %>%
  summarise(n_obs = n()) %>%
  summary()

# Ensure multiple timepoints per subject
```

#### Issue: Overlapping error bars

**Problem**: Error bars overlap when multiple groups are plotted.

**Solution**:
```r
# Use jittering to separate groups
lplot(..., jitter_width = 0.2, error_type = "bar")

# Or use ribbon bands instead
lplot(..., error_type = "band")
```

#### Issue: Poor print quality

**Problem**: Plots don't meet publication standards.

**Solution**:
```r
# Use publication themes
lplot(..., theme = "nature")

# Export with proper specifications
save_publication(plot, "figure.pdf", journal = "nature", dpi = 600)
```

#### Error: Font not found in PDF

**Problem**: Publication themes require fonts not available.

**Solution**:
```r
# Install required fonts
library(showtext)
font_add('Arial', regular = '/path/to/arial.ttf')
showtext_auto()

# Or use system fonts
lplot(..., theme = "nature") +
  theme(text = element_text(family = "sans"))
```

### Getting Help

1. **Check function documentation**:
   ```r
   ?lplot
   ?save_publication
   ```

2. **Review examples**:
   ```r
   example(lplot)
   ```

3. **Consult vignettes**:
   ```r
   vignette("zzlongplot_introduction")
   vignette("clinical-trials")
   vignette("publication-themes")
   ```

4. **Report issues**:
   Visit the GitHub repository to report bugs or request features:
   https://github.com/rgt47/zzlongplot/issues

### Performance Tips

1. **Optimize large datasets**:
   ```r
   # Pre-filter data if possible
   data_subset <- data[data$analysis_population == "Y", ]

   # Use efficient summary statistics
   lplot(..., summary_statistic = "mean")  # Fastest option
   ```

2. **Simplify complex plots**:
   ```r
   # Reduce jitter for better performance
   lplot(..., jitter_width = 0.1)

   # Use error bars instead of ribbons for large datasets
   lplot(..., error_type = "bar")
   ```

3. **Optimize export settings**:
   ```r
   # Balance quality and file size
   save_publication(plot, "figure.pdf", dpi = 300)  # Instead of 600
   ```

This usage guide provides comprehensive coverage of the zzlongplot package capabilities. For additional examples and advanced use cases, consult the package vignettes and documentation.