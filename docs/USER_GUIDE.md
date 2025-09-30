# zzlongplot User Guide

**A Comprehensive Guide to Longitudinal Data Visualization for Clinical Trials**

Version: 0.0.0.1000
Author: Ronald (Ryy) G. Thomas
Last Updated: 2025-09-30

---

## Table of Contents

1. [Introduction](#introduction)
2. [Installation and Setup](#installation-and-setup)
3. [Core Concepts and Workflow](#core-concepts-and-workflow)
4. [Basic Usage Examples](#basic-usage-examples)
5. [Advanced Features](#advanced-features)
6. [Clinical Trials Features](#clinical-trials-features)
7. [Publication-Ready Output](#publication-ready-output)
8. [Color Palettes and Themes](#color-palettes-and-themes)
9. [Statistical Features](#statistical-features)
10. [Troubleshooting and FAQ](#troubleshooting-and-faq)
11. [Complete API Reference](#complete-api-reference)

---

## Introduction

### What is zzlongplot?

`zzlongplot` is a specialized R package designed for flexible, publication-quality visualization of longitudinal data. It provides comprehensive support for clinical trials, with built-in CDISC compliance, regulatory-ready themes, and industry-standard statistical representations.

### Key Features

- **Flexible Data Visualization**: Works with both continuous and categorical time variables
- **Dual Plotting**: Displays both observed values and change from baseline
- **Clinical Trials Support**: CDISC variable recognition, regulatory themes, treatment color schemes
- **Publication Quality**: Journal-specific themes (Nature, NEJM, Science, Lancet, JAMA, JCO)
- **Statistical Rigor**: Confidence intervals, sample size annotations, statistical testing
- **Formula Interface**: Intuitive R formula syntax for variable specification
- **Customizable**: Extensive options for colors, themes, error representations

### When to Use zzlongplot

- Clinical trial efficacy and safety analyses
- Repeated measures studies
- Before/after intervention studies
- Time series with grouped comparisons
- Regulatory submission visualizations
- Publication-quality figures for journals

### Package Philosophy

The package is built on three principles:

1. **Simplicity**: Complex visualizations with minimal code
2. **Compliance**: Built-in support for CDISC and regulatory standards
3. **Quality**: Publication-ready output by default

---

## Installation and Setup

### Installation

```r
# Install from CRAN (when available)
install.packages("zzlongplot")

# Install from GitHub (development version)
devtools::install_github("rgt47/zzlongplot")
```

### Required Dependencies

```r
# Core dependencies (installed automatically)
install.packages(c("dplyr", "ggplot2", "patchwork", "RColorBrewer"))
```

### Optional Dependencies

```r
# For enhanced functionality
install.packages(c("showtext", "extrafont"))  # Font support for PDF output
install.packages("conflicted")  # Manage namespace conflicts
```

### Loading the Package

```r
library(zzlongplot)
library(ggplot2)  # For additional customization
library(dplyr)    # For data manipulation

# Optional: Resolve namespace conflicts
if (requireNamespace("conflicted", quietly = TRUE)) {
  conflicted::conflict_prefer("filter", "dplyr")
  conflicted::conflict_prefer("summarize", "dplyr")
}
```

### Verifying Installation

```r
# Check package version
packageVersion("zzlongplot")

# View help
?lplot

# List available functions
ls("package:zzlongplot")
```

### Font Setup for PDF Output

When creating PDFs with publication themes, you may need to register fonts:

**Option 1: Using showtext (Recommended)**
```r
library(showtext)

# Register Arial fonts (macOS)
font_add('Arial',
         regular = '/System/Library/Fonts/Supplemental/Arial.ttf',
         bold = '/System/Library/Fonts/Supplemental/Arial Bold.ttf')

# Enable for all devices
showtext_auto()
```

**Option 2: Using extrafont**
```r
library(extrafont)

# One-time setup (takes several minutes)
font_import()

# Load fonts for PostScript devices
loadfonts(device = "postscript")
```

---

## Core Concepts and Workflow

### Data Structure Requirements

`zzlongplot` works with data in **long format**, where each row represents one observation at one time point for one subject.

**Required structure:**
```r
# Example: Proper data structure
data <- data.frame(
  subject_id = c(1, 1, 1, 2, 2, 2),           # Subject identifier
  visit = c(0, 1, 2, 0, 1, 2),                 # Time variable
  outcome = c(50, 48, 45, 52, 49, 46),         # Measured outcome
  treatment = c("A", "A", "A", "B", "B", "B")  # Grouping variable
)
```

**Key components:**
- **Cluster variable**: Identifies individual subjects (e.g., `subject_id`, `USUBJID`)
- **Time variable**: Continuous (e.g., weeks, days) or categorical (e.g., "Baseline", "Month 1")
- **Outcome variable**: The measurement being tracked
- **Grouping variable(s)**: Optional variables for comparing groups (e.g., treatment, site)

### The Formula Interface

`zzlongplot` uses R's formula syntax to specify variables:

```r
# Basic structure
y ~ x | group

# Components:
# y      = outcome/dependent variable
# x      = time/visit variable
# group  = grouping variable (optional)
```

**Examples:**
```r
# No grouping
outcome ~ visit

# Single grouping variable
outcome ~ visit | treatment

# Multiple grouping variables
outcome ~ visit | treatment + site

# With faceting (separate parameter)
lplot(data, outcome ~ visit | treatment, facet_form = ~ site)
```

### Baseline Values

The `baseline_value` parameter specifies which time point is the reference for calculating change:

```r
# For numeric time variables
baseline_value = 0  # Week 0, Day 0, etc.

# For categorical time variables
baseline_value = "Baseline"  # Visit name
baseline_value = "Screening"
```

### Plot Types

Three plot types are available:

```r
plot_type = "obs"     # Observed values only (default)
plot_type = "change"  # Change from baseline only
plot_type = "both"    # Both plots side-by-side
```

### The zzlongplot Workflow

```r
# 1. Prepare data in long format
data <- prepare_longitudinal_data()

# 2. Create visualization
plot <- lplot(
  df = data,
  form = outcome ~ visit | treatment,
  cluster_var = "subject_id",
  baseline_value = 0,
  plot_type = "both"
)

# 3. Customize (optional)
plot <- plot + theme_minimal()

# 4. Export
ggsave("figure.pdf", plot, width = 10, height = 6)
```

---

## Basic Usage Examples

### Example 1: Simple Longitudinal Plot

**Scenario**: Visualize outcome over time with no grouping

```r
# Create sample data
set.seed(123)
data <- data.frame(
  subject_id = rep(1:20, each = 4),
  visit = rep(c(0, 1, 2, 3), times = 20),
  outcome = rnorm(80, mean = 50, sd = 10)
)

# Create basic plot
plot <- lplot(
  data,
  outcome ~ visit,
  cluster_var = "subject_id",
  baseline_value = 0,
  title = "Outcome Over Time",
  xlab = "Visit Number",
  ylab = "Outcome Score"
)

print(plot)
```

### Example 2: Comparing Treatment Groups

**Scenario**: Compare two or more treatment groups over time

```r
# Create data with treatment groups
set.seed(123)
data <- data.frame(
  subject_id = rep(1:40, each = 4),
  visit = rep(c(0, 1, 2, 3), times = 40),
  outcome = rnorm(160, mean = c(50, 48, 46, 44), sd = 8),
  treatment = rep(c("Placebo", "Drug A"), each = 80)
)

# Create grouped plot
plot <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  baseline_value = 0,
  title = "Treatment Comparison",
  xlab = "Visit Number",
  ylab = "Efficacy Score"
)

print(plot)
```

### Example 3: Observed and Change from Baseline

**Scenario**: Display both absolute values and changes

```r
# Create plot showing both views
plot <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  baseline_value = 0,
  plot_type = "both",
  title = "Observed Values",
  title2 = "Change from Baseline",
  xlab = "Visit Number",
  ylab = "Outcome Score",
  ylab2 = "Change in Outcome"
)

print(plot)
```

### Example 4: Categorical Time Variables

**Scenario**: Use visit names instead of numbers

```r
# Create data with categorical visits
data_cat <- data.frame(
  subject_id = rep(1:30, each = 4),
  visit = rep(c("Baseline", "Week 4", "Week 8", "Week 12"), times = 30),
  score = rnorm(120, mean = c(60, 55, 50, 48), sd = 10),
  treatment = rep(c("Active", "Control"), each = 60)
)

# Create plot
plot <- lplot(
  data_cat,
  score ~ visit | treatment,
  cluster_var = "subject_id",
  baseline_value = "Baseline",
  plot_type = "both",
  title = "Treatment Response",
  xlab = "Study Visit",
  ylab = "Pain Score"
)

print(plot)
```

### Example 5: Multiple Treatment Arms

**Scenario**: Compare three or more treatment groups

```r
# Create data with three treatment arms
set.seed(456)
data_multi <- data.frame(
  subject_id = rep(1:60, each = 5),
  visit = rep(c(0, 1, 2, 3, 4), times = 60),
  efficacy = rnorm(300, mean = c(50, 48, 45, 42, 40), sd = 8),
  treatment = rep(c("Placebo", "Low Dose", "High Dose"), each = 100)
)

# Create plot
plot <- lplot(
  data_multi,
  efficacy ~ visit | treatment,
  cluster_var = "subject_id",
  baseline_value = 0,
  plot_type = "both",
  title = "Dose-Response Analysis",
  xlab = "Visit",
  ylab = "Efficacy Score"
)

print(plot)
```

---

## Advanced Features

### Grouping and Faceting

#### Multiple Grouping Variables

Combine grouping variables to examine interactions:

```r
# Add gender to data
data$gender <- rep(c("Female", "Male"), length.out = nrow(data))

# Plot with two grouping variables
plot <- lplot(
  data,
  outcome ~ visit | treatment + gender,
  cluster_var = "subject_id",
  baseline_value = 0,
  title = "Treatment by Gender Interaction"
)

print(plot)
```

#### Faceting by Additional Variables

Use faceting to create panel plots:

```r
# Add site variable
data$site <- rep(c("Site 1", "Site 2", "Site 3"), length.out = nrow(data))

# Single faceting variable (columns)
plot1 <- lplot(
  data,
  outcome ~ visit | treatment,
  facet_form = ~ site,
  cluster_var = "subject_id",
  baseline_value = 0,
  title = "Treatment Effect by Site"
)

# Two-dimensional faceting (rows and columns)
data$age_group <- rep(c("Young", "Middle", "Elderly"), length.out = nrow(data))

plot2 <- lplot(
  data,
  outcome ~ visit | treatment,
  facet_form = age_group ~ site,
  cluster_var = "subject_id",
  baseline_value = 0,
  title = "Treatment Effect by Age and Site"
)
```

### Error Representation

#### Error Bars

Standard error bars are useful for discrete time points:

```r
# Error bars with default settings
plot_bars <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  error_type = "bar",
  baseline_value = 0
)

# Jittered error bars (better for overlapping groups)
plot_jitter <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  error_type = "bar",
  jitter_width = 0.2,  # Increase separation
  baseline_value = 0
)
```

#### Ribbon Bands

Confidence ribbons work well for continuous time or many time points:

```r
# Standard ribbon
plot_ribbon <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  error_type = "band",
  baseline_value = 0
)

# Customized ribbon
plot_ribbon_custom <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  error_type = "band",
  ribbon_alpha = 0.3,      # More opaque
  ribbon_fill = "lightblue",  # Custom color
  baseline_value = 0
)
```

### Summary Statistics Options

#### Mean with Confidence Interval

Default for most analyses:

```r
# Mean with 95% CI
plot_mean_ci <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  summary_statistic = "mean",
  confidence_interval = 0.95,
  baseline_value = 0
)
```

#### Mean with Standard Error

For exploratory analyses:

```r
# Mean with SE
plot_mean_se <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  summary_statistic = "mean_se",
  baseline_value = 0
)
```

#### Median with IQR

For non-normal or skewed data:

```r
# Median with interquartile range
plot_median <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  summary_statistic = "median",
  baseline_value = 0
)
```

#### Boxplot Summary

For exploratory visualization of distributions:

```r
# Boxplot representation
plot_boxplot <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  summary_statistic = "boxplot",
  baseline_value = 0
)
```

### Reference Lines

Add clinical or statistical reference lines:

```r
# Define reference lines
ref_lines <- list(
  # Horizontal line at clinically meaningful threshold
  list(value = 50, axis = "y", color = "red",
       linetype = "dashed", size = 0.5, alpha = 0.7),

  # Vertical line at key time point
  list(value = 2, axis = "x", color = "blue",
       linetype = "dotted", size = 0.5, alpha = 0.7)
)

# Create plot with reference lines
plot <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  baseline_value = 0,
  reference_lines = ref_lines,
  title = "Treatment Response with Clinical Thresholds"
)
```

### Statistical Annotations

Add statistical test results to plots:

```r
# Plot with statistical comparisons
plot_stats <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  baseline_value = 0,
  statistical_annotations = TRUE,  # Add p-values
  confidence_interval = 0.95,
  show_sample_sizes = TRUE
)
```

### Custom Color Palettes

#### Manual Color Specification

```r
# Define custom colors
my_colors <- c("#E69F00", "#56B4E9", "#009E73")

# Apply to plot
plot <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  baseline_value = 0,
  color_palette = my_colors
)
```

#### Colorblind-Friendly Palettes

```r
# Get colorblind-friendly palette
colors <- get_colorblind_palette(n = 3, type = "qualitative")

# Apply to plot
plot <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  baseline_value = 0,
  color_palette = colors
)
```

---

## Clinical Trials Features

### CDISC Compliance

#### CDISC Variable Recognition

The package automatically recognizes standard CDISC variable names:

```r
# Clinical trial data with CDISC variables
clinical_data <- data.frame(
  USUBJID = rep(paste0("001-", sprintf("%03d", 1:30)), each = 5),
  AVISITN = rep(c(0, 1, 2, 3, 4), times = 30),
  AVAL = rnorm(150, mean = c(50, 48, 45, 42, 40), sd = 8),
  TRT01P = rep(c("Placebo", "Drug 10mg", "Drug 20mg"), each = 50),
  PARAM = "Efficacy Score (0-100)"
)

# Automatic variable detection
suggestions <- suggest_clinical_vars(clinical_data, verbose = TRUE)

# Output:
# CDISC Variable Detection Results:
# =================================
#
# Suggested Formula: AVAL ~ AVISITN | TRT01P
# Cluster Variable: USUBJID
# Baseline Value: 0
#
# Detected Variables:
#   subject_id: USUBJID
#   visit: AVISITN
#   analysis_value: AVAL
#   treatment: TRT01P
```

#### CDISC Data Validation

Check your data for CDISC compliance:

```r
# Validate CDISC compliance
validation <- validate_cdisc_data(
  clinical_data,
  required_vars = c("USUBJID", "AVISITN", "AVAL"),
  check_population_flags = TRUE
)

# View results
print(paste("Compliance Score:", validation$compliance_score, "%"))
print("Issues:")
print(validation$issues)
print("Recommendations:")
print(validation$recommendations)
```

#### CDISC Templates

Get recommended variables for different analysis types:

```r
# Efficacy analysis variables
efficacy_vars <- get_cdisc_template("efficacy")
print(efficacy_vars)

# Safety analysis variables
safety_vars <- get_cdisc_template("safety")

# PK analysis variables
pk_vars <- get_cdisc_template("pk")

# Biomarker analysis variables
biomarker_vars <- get_cdisc_template("biomarker")
```

### Clinical Mode

Enable all clinical trial defaults with one parameter:

```r
# Clinical mode activation
plot_clinical <- lplot(
  clinical_data,
  AVAL ~ AVISITN | TRT01P,
  cluster_var = "USUBJID",
  baseline_value = 0,
  clinical_mode = TRUE,  # Enables all clinical features
  plot_type = "both",
  title = "Clinical Trial: Primary Efficacy Endpoint",
  title2 = "Change from Baseline"
)

# Clinical mode automatically enables:
# - 95% confidence intervals
# - Sample size annotations
# - Clinical color scheme (placebo=grey, treatments=colors)
# - Statistical annotations
# - Professional NEJM theme
```

### Treatment Color Schemes

Apply standard clinical color conventions:

```r
# Standard treatment colors
# Placebo/Control = grey, Active treatments = distinct colors
plot <- lplot(
  clinical_data,
  AVAL ~ AVISITN | TRT01P,
  cluster_var = "USUBJID",
  baseline_value = 0,
  treatment_colors = "standard",
  title = "Treatment Comparison with Clinical Colors"
)

# Or use specific clinical palettes
colors <- clinical_colors("treatment", n = 3, placebo_first = TRUE)
# Returns: c("#7F7F7F", "#1F77B4", "#D62728")  # Grey, Blue, Red

plot <- lplot(
  clinical_data,
  AVAL ~ AVISITN | TRT01P,
  cluster_var = "USUBJID",
  baseline_value = 0,
  color_palette = colors
)
```

### Clinical Color Palettes

Multiple clinical palette types are available:

```r
# Treatment palette (placebo + active)
treatment_colors <- clinical_colors("treatment", n = 4)

# Severity progression
severity_colors <- clinical_colors("severity", n = 5)

# Outcome colors (positive/neutral/negative)
outcome_colors <- clinical_colors("outcome")

# FDA submission palette (high contrast)
fda_colors <- clinical_colors("fda", n = 6)
```

### Confidence Intervals and Sample Sizes

```r
# Show 95% confidence intervals
plot_ci <- lplot(
  clinical_data,
  AVAL ~ AVISITN | TRT01P,
  cluster_var = "USUBJID",
  baseline_value = 0,
  confidence_interval = 0.95,  # 95% CI
  show_sample_sizes = TRUE,    # Show N at each timepoint
  title = "Efficacy Analysis with 95% CI"
)

# Show 90% confidence intervals (less common)
plot_ci90 <- lplot(
  clinical_data,
  AVAL ~ AVISITN | TRT01P,
  cluster_var = "USUBJID",
  baseline_value = 0,
  confidence_interval = 0.90
)
```

### Visit Windows

Handle visit timing variations in clinical trials:

```r
# Data with actual visit days (not perfectly aligned)
clinical_data_windows <- clinical_data %>%
  mutate(
    VISIT_DAY = case_when(
      AVISITN == 0 ~ 0,
      AVISITN == 1 ~ round(rnorm(n(), 28, 3)),   # Week 4 ± 3 days
      AVISITN == 2 ~ round(rnorm(n(), 56, 4)),   # Week 8 ± 4 days
      AVISITN == 3 ~ round(rnorm(n(), 84, 5)),   # Week 12 ± 5 days
      AVISITN == 4 ~ round(rnorm(n(), 112, 6))   # Week 16 ± 6 days
    )
  )

# Plot with visit windows (future feature)
plot_windows <- lplot(
  clinical_data_windows,
  AVAL ~ VISIT_DAY | TRT01P,
  cluster_var = "USUBJID",
  baseline_value = 0,
  clinical_mode = TRUE,
  # visit_windows = list(
  #   "Week 4" = c(21, 35),
  #   "Week 8" = c(49, 63),
  #   "Week 12" = c(77, 91),
  #   "Week 16" = c(105, 119)
  # ),
  xlab = "Study Day"
)
```

### Real-World Clinical Trial Example

Complete example with all clinical features:

```r
# Simulate realistic clinical trial
set.seed(789)
n_subjects <- 90
visits <- c(0, 4, 8, 12, 16)  # Weeks

clinical_study <- expand.grid(
  USUBJID = paste0("STUDY123-", sprintf("%03d", 1:n_subjects)),
  AVISITN = visits
) %>%
  mutate(
    # Treatment assignments
    TRT01P = rep(c("Placebo", "Drug 50mg", "Drug 100mg"), length.out = n()),

    # Site stratification
    SITEID = rep(paste0("Site ", 1:3), length.out = n()),

    # Age groups
    AGEGRP = rep(c("18-40", "41-65", ">65"), length.out = n()),

    # Primary endpoint: Depression score (higher = worse)
    AVAL = case_when(
      TRT01P == "Placebo" ~ rnorm(n(), mean = 20 - AVISITN * 0.3, sd = 5),
      TRT01P == "Drug 50mg" ~ rnorm(n(), mean = 20 - AVISITN * 0.8, sd = 4.5),
      TRT01P == "Drug 100mg" ~ rnorm(n(), mean = 20 - AVISITN * 1.2, sd = 4)
    ),

    # Ensure scores stay in valid range (0-50)
    AVAL = pmax(0, pmin(50, AVAL)),

    # Visit labels
    AVISIT = case_when(
      AVISITN == 0 ~ "Baseline",
      AVISITN == 4 ~ "Week 4",
      AVISITN == 8 ~ "Week 8",
      AVISITN == 12 ~ "Week 12",
      AVISITN == 16 ~ "Week 16"
    ),

    # Parameter
    PARAM = "Depression Severity Score (0-50)",
    PARAMCD = "DEPRESS"
  )

# Primary efficacy analysis
primary_plot <- lplot(
  clinical_study,
  AVAL ~ AVISITN | TRT01P,
  cluster_var = "USUBJID",
  baseline_value = 0,
  clinical_mode = TRUE,
  plot_type = "both",
  title = "Figure 1A: Primary Efficacy Endpoint",
  title2 = "Figure 1B: Change from Baseline",
  subtitle = "Depression Severity Score by Treatment Group",
  subtitle2 = "ITT Population, LOCF Imputation",
  caption = "Error bars represent 95% confidence intervals",
  xlab = "Study Week",
  ylab = "Depression Score",
  ylab2 = "Change in Depression Score"
)

# Subgroup analysis by site
site_plot <- lplot(
  clinical_study,
  AVAL ~ AVISITN | TRT01P,
  facet_form = ~ SITEID,
  cluster_var = "USUBJID",
  baseline_value = 0,
  clinical_mode = TRUE,
  title = "Figure 2: Efficacy by Study Site"
)

# Subgroup analysis by age
age_plot <- lplot(
  clinical_study,
  AVAL ~ AVISITN | TRT01P,
  facet_form = ~ AGEGRP,
  cluster_var = "USUBJID",
  baseline_value = 0,
  clinical_mode = TRUE,
  title = "Figure 3: Efficacy by Age Group"
)
```

---

## Publication-Ready Output

### Journal-Specific Themes

The package includes themes for major scientific journals:

#### Nature Publishing Group

```r
# Nature theme
plot_nature <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  baseline_value = 0,
  theme = "nature",  # Nature theme + colors
  plot_type = "both"
)

# Nature theme applies:
# - 7pt base font size
# - Clean backgrounds
# - Minimal grid lines
# - Professional typography
# - Nature color palette
```

#### New England Journal of Medicine (NEJM)

```r
# NEJM clinical theme
plot_nejm <- lplot(
  clinical_data,
  AVAL ~ AVISITN | TRT01P,
  cluster_var = "USUBJID",
  baseline_value = 0,
  theme = "nejm",  # NEJM theme + colors
  clinical_mode = TRUE,
  plot_type = "both"
)

# NEJM theme features:
# - Bold axis titles
# - Clinical appearance
# - Strong panel borders
# - Professional medical styling
# - NEJM color palette
```

#### Science (AAAS)

```r
# Science journal theme
plot_science <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  baseline_value = 0,
  theme = "science",
  plot_type = "both"
)
```

#### The Lancet

```r
# Lancet theme
plot_lancet <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  baseline_value = 0,
  theme = "lancet",
  plot_type = "both"
)
```

#### JAMA

```r
# JAMA theme
plot_jama <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  baseline_value = 0,
  theme = "jama",
  plot_type = "both"
)
```

#### Journal of Clinical Oncology (JCO)

```r
# JCO theme
plot_jco <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  baseline_value = 0,
  theme = "jco",
  plot_type = "both"
)
```

#### FDA Regulatory

```r
# FDA regulatory theme
plot_fda <- lplot(
  clinical_data,
  AVAL ~ AVISITN | TRT01P,
  cluster_var = "USUBJID",
  baseline_value = 0,
  theme = "fda",
  plot_type = "both"
)

# FDA theme features:
# - High readability (10pt base font)
# - Strong contrast
# - Grid lines for data reading
# - Conservative styling
# - Suitable for CSR inclusion
```

### Saving Publication Plots

#### Basic Export

```r
# Save with journal specifications
plot <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  baseline_value = 0,
  theme = "nature",
  plot_type = "both"
)

# Save for Nature journal
save_publication(
  plot,
  filename = "figure1.pdf",
  journal = "nature",
  column_type = "double",  # Double column width
  dpi = 600                # High resolution
)

# Output:
# Plot saved for Nature:
#   File: figure1.pdf
#   Dimensions: 180 x 111 mm
#   Resolution: 600 DPI
#   Format: PDF
```

#### Custom Dimensions

```r
# Custom width and height
save_publication(
  plot,
  filename = "figure2.pdf",
  journal = "nature",
  width_mm = 180,   # Double column
  height_mm = 150,  # Custom height
  dpi = 600
)
```

#### Single Column Figures

```r
# Single column figure
save_publication(
  plot,
  filename = "supplementary_fig1.pdf",
  journal = "nature",
  column_type = "single",  # Single column width (90mm for Nature)
  dpi = 600
)
```

#### Different Formats

```r
# TIFF format for some journals
save_publication(
  plot,
  filename = "figure1.tiff",
  journal = "nejm",
  format = "tiff",
  dpi = 600
)

# EPS format
save_publication(
  plot,
  filename = "figure1.eps",
  journal = "science",
  format = "eps",
  dpi = 600
)

# PNG format
save_publication(
  plot,
  filename = "figure1.png",
  journal = "nature",
  format = "png",
  dpi = 300  # Lower DPI acceptable for PNG
)
```

### Multi-Panel Figures

Create complex multi-panel figures with automatic labeling:

```r
# Create individual plots
plot_a <- lplot(
  data1,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  theme = "nature",
  title = "Efficacy Analysis"
)

plot_b <- lplot(
  data2,
  safety ~ visit | treatment,
  cluster_var = "subject_id",
  theme = "nature",
  title = "Safety Analysis"
)

plot_c <- lplot(
  data3,
  biomarker ~ visit | treatment,
  cluster_var = "subject_id",
  theme = "nature",
  title = "Biomarker Response"
)

# Combine into multi-panel figure
combined <- publication_panels(
  plots = list(plot_a, plot_b, plot_c),
  labels = c("A", "B", "C"),        # Panel labels
  layout = "horizontal",            # Side-by-side
  shared_legend = TRUE,             # Single legend
  legend_position = "bottom",
  label_size = 12,
  label_face = "bold"
)

# Save combined figure
save_publication(
  combined,
  filename = "figure2_combined.pdf",
  journal = "nature",
  column_type = "double",
  dpi = 600
)
```

#### Vertical Layout

```r
# Stack plots vertically
combined_vert <- publication_panels(
  plots = list(plot_a, plot_b, plot_c),
  labels = c("A", "B", "C"),
  layout = "vertical"
)
```

#### Grid Layout

```r
# Create 2x2 grid
plot_d <- lplot(...)  # Create 4th plot

combined_grid <- publication_panels(
  plots = list(plot_a, plot_b, plot_c, plot_d),
  labels = c("A", "B", "C", "D"),
  layout = "grid",
  ncol = 2,
  nrow = 2
)
```

### Journal Specifications

View specifications for different journals:

```r
# Get Nature specifications
nature_specs <- get_journal_specs("nature")
print(nature_specs)
# $name
# [1] "Nature"
# $single_column_mm
# [1] 90
# $double_column_mm
# [1] 180
# $preferred_dpi
# [1] 600
# $formats
# [1] "pdf"  "eps"  "tiff"

# List all available journals
journals <- list_journals(detailed = TRUE)
print(journals)
```

### Publication-Ready Workflow

Complete workflow for creating publication figures:

```r
# 1. Create plot with publication theme
fig1 <- lplot(
  clinical_data,
  AVAL ~ AVISITN | TRT01P,
  cluster_var = "USUBJID",
  baseline_value = 0,
  theme = "nature",
  clinical_mode = TRUE,
  plot_type = "both",
  title = "Primary Efficacy Endpoint",
  title2 = "Change from Baseline"
)

# 2. Review plot
print(fig1)

# 3. Save in multiple formats for journal

# High-resolution PDF for print
save_publication(
  fig1,
  "manuscript/figures/figure1.pdf",
  journal = "nature",
  column_type = "double",
  dpi = 600
)

# Lower-resolution PNG for online
save_publication(
  fig1,
  "manuscript/figures/figure1_web.png",
  journal = "nature",
  column_type = "double",
  dpi = 150
)

# TIFF for submission system
save_publication(
  fig1,
  "manuscript/figures/figure1_submission.tiff",
  journal = "nature",
  column_type = "double",
  dpi = 600
)
```

---

## Color Palettes and Themes

### Colorblind-Friendly Palettes

The package provides colorblind-friendly palettes:

```r
# Qualitative palette (for categorical data)
qual_colors <- get_colorblind_palette(n = 5, type = "qualitative")

# Sequential palette (for numeric data)
seq_colors <- get_colorblind_palette(n = 7, type = "sequential")

# Diverging palette (for data with meaningful zero)
div_colors <- get_colorblind_palette(n = 9, type = "diverging")

# Use in plot
plot <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  color_palette = qual_colors
)
```

### Journal-Specific Color Palettes

Each journal theme includes matching colors:

```r
# NEJM colors
nejm_colors <- clinical_colors("nejm", n = 4)
# c("#BC3C29", "#0072B5", "#E18727", "#20854E")

# Nature colors
nature_colors <- clinical_colors("nature", n = 4)
# c("#E64B35", "#4DBBD5", "#00A087", "#3C5488")

# Lancet colors
lancet_colors <- clinical_colors("lancet", n = 4)
# c("#00468B", "#ED0000", "#42B540", "#0099B4")

# JAMA colors
jama_colors <- clinical_colors("jama", n = 4)
# c("#374E55", "#DF8F44", "#00A1D5", "#B24745")

# Science colors
science_colors <- clinical_colors("science", n = 4)
# c("#3B4992", "#EE0000", "#008B45", "#631879")

# JCO colors
jco_colors <- clinical_colors("jco", n = 4)
# c("#0073C2", "#EFC000", "#868686", "#CD534C")
```

### Clinical Color Palettes

#### Treatment Colors

```r
# Standard treatment palette
# Placebo = grey, Active treatments = distinct colors
treatment_colors <- clinical_colors("treatment", n = 4)
# c("#7F7F7F", "#1F77B4", "#D62728", "#FF7F0E")

# Apply to plot
plot <- lplot(
  clinical_data,
  AVAL ~ AVISITN | TRT01P,
  cluster_var = "USUBJID",
  color_palette = treatment_colors
)
```

#### Severity Colors

```r
# Progression from mild to severe
severity_colors <- clinical_colors("severity", n = 5)
# Light green → Dark green

# Use for adverse event severity
plot_ae <- lplot(
  ae_data,
  count ~ visit | severity,
  cluster_var = "USUBJID",
  color_palette = severity_colors
)
```

#### Outcome Colors

```r
# Positive/Neutral/Negative outcomes
outcome_colors <- clinical_colors("outcome")
# c("#2CA02C", "#7F7F7F", "#D62728")  # Green, Grey, Red
```

#### FDA Submission Colors

```r
# High contrast for regulatory submissions
fda_colors <- clinical_colors("fda", n = 6)
# Black, Orange, Sky Blue, Bluish Green, Yellow, Blue
```

### Automatic Treatment Color Assignment

Automatically detect and assign appropriate colors:

```r
# Automatically assigns grey to placebo, colors to treatments
treatments <- c("Placebo", "Drug A 10mg", "Drug A 20mg")
auto_colors <- assign_treatment_colors(treatments)

# Returns named vector:
# Placebo      = "#7F7F7F" (grey)
# Drug A 10mg  = "#1F77B4" (blue)
# Drug A 20mg  = "#D62728" (red)

# Apply to plot
plot <- lplot(
  clinical_data,
  AVAL ~ AVISITN | TRT01P,
  cluster_var = "USUBJID",
  color_palette = auto_colors
)
```

### Custom Theme Creation

Create custom themes for your organization:

```r
# Start with base theme
custom_theme <- theme_nature(base_size = 10)

# Customize specific elements
custom_theme <- custom_theme +
  theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    axis.title = element_text(size = 12, face = "bold"),
    legend.position = "right",
    panel.border = element_rect(color = "black", size = 1)
  )

# Apply to plot
plot <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id"
) + custom_theme
```

### Applying Themes and Colors Together

```r
# Method 1: Use theme parameter (automatically applies matching colors)
plot1 <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  theme = "nejm"  # Applies NEJM theme + NEJM colors
)

# Method 2: Manual application
plot2 <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id"
)

# Apply theme and colors
plot2_styled <- apply_publication_style(
  plot2,
  theme_name = "nature",
  color_palette = "nature"
)

# Method 3: Separate color palette
plot3 <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  theme = "nature",
  color_palette = clinical_colors("treatment")  # Override Nature colors
)
```

---

## Statistical Features

### Summary Statistics

#### Mean-Based Statistics

```r
# Mean with standard error (default)
plot_mean_se <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  summary_statistic = "mean_se",
  baseline_value = 0
)

# Mean with confidence interval
plot_mean_ci <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  summary_statistic = "mean",
  confidence_interval = 0.95,  # 95% CI
  baseline_value = 0
)
```

#### Median-Based Statistics

For skewed or non-normal data:

```r
# Median with IQR
plot_median <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  summary_statistic = "median",
  baseline_value = 0
)

# Median with approximate CI
plot_median_ci <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  summary_statistic = "median",
  confidence_interval = 0.95,
  baseline_value = 0
)
```

#### Boxplot Statistics

Full distributional visualization:

```r
# Boxplot summary (quartiles + whiskers)
plot_box <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  summary_statistic = "boxplot",
  baseline_value = 0
)
```

### Confidence Intervals

Different confidence levels:

```r
# 90% CI
plot_90 <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  confidence_interval = 0.90,
  baseline_value = 0
)

# 95% CI (most common)
plot_95 <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  confidence_interval = 0.95,
  baseline_value = 0
)

# 99% CI
plot_99 <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  confidence_interval = 0.99,
  baseline_value = 0
)
```

### Sample Size Annotations

Display sample sizes for transparency:

```r
# Show sample sizes
plot_n <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  baseline_value = 0,
  show_sample_sizes = TRUE  # Adds "n = XX" labels
)
```

### Statistical Testing

Add statistical comparisons between groups:

```r
# Automatic statistical tests
plot_stats <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  baseline_value = 0,
  statistical_annotations = TRUE,  # Adds significance stars
  confidence_interval = 0.95
)

# Statistical annotations show:
# *** = p < 0.001
# **  = p < 0.01
# *   = p < 0.05
# ns  = not significant
```

### Complete Statistical Example

Comprehensive example with all statistical features:

```r
# Clinical trial with full statistical presentation
statistical_plot <- lplot(
  clinical_data,
  AVAL ~ AVISITN | TRT01P,
  cluster_var = "USUBJID",
  baseline_value = 0,

  # Statistical settings
  summary_statistic = "mean",      # Mean ± CI
  confidence_interval = 0.95,      # 95% confidence intervals
  show_sample_sizes = TRUE,        # Show N at each timepoint
  statistical_annotations = TRUE,  # Add p-values

  # Visualization
  error_type = "bar",              # Error bars
  jitter_width = 0.15,             # Separate overlapping bars

  # Clinical features
  treatment_colors = "standard",   # Clinical colors
  theme = "nejm",                  # Professional theme

  # Labels
  plot_type = "both",
  title = "Primary Efficacy Analysis",
  title2 = "Change from Baseline",
  subtitle = "ITT Population with LOCF",
  xlab = "Study Week",
  ylab = "Efficacy Score (0-100)",
  ylab2 = "Change from Baseline",
  caption = "Error bars: 95% CI. *p<0.05, **p<0.01, ***p<0.001"
)

print(statistical_plot)
```

---

## Troubleshooting and FAQ

### Common Errors and Solutions

#### Error: "The following required columns are missing"

**Problem**: Variables specified in formula don't exist in data.

**Solution**:
```r
# Check your column names
names(data)

# Verify formula matches actual column names
parse_formula(outcome ~ visit | treatment)

# Common mistakes:
# - Typos: "Treatment" vs "treatment"
# - Wrong variable: "VISIT" vs "AVISITN"
# - Missing variable: forgot to add grouping variable
```

#### Error: "The baseline value 'X' is not present"

**Problem**: Specified baseline value doesn't exist in the time variable.

**Solution**:
```r
# Check unique values in visit variable
unique(data$visit)

# Make sure baseline_value matches exactly
# For numeric: baseline_value = 0
# For categorical: baseline_value = "Baseline"  (case-sensitive!)

# Fix the baseline value
plot <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  baseline_value = 0  # or whatever value is actually in your data
)
```

#### Error: "Cluster variable 'X' not found"

**Problem**: Subject ID variable doesn't exist or is misspelled.

**Solution**:
```r
# Check if variable exists
"subject_id" %in% names(data)

# Use correct variable name
plot <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "USUBJID"  # Use actual column name
)
```

#### Warning: "Limited longitudinal data"

**Problem**: Fewer than 2 observations per subject.

**Solution**:
```r
# Check observations per subject
data %>%
  group_by(subject_id) %>%
  summarise(n_obs = n()) %>%
  summary()

# Verify data structure
# Each subject should have multiple timepoints
```

#### Issue: Overlapping Error Bars

**Problem**: Error bars overlap when plotting multiple groups.

**Solution**:
```r
# Option 1: Increase jitter width
plot <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  error_type = "bar",
  jitter_width = 0.25  # Increase from default 0.15
)

# Option 2: Use ribbon bands instead
plot <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  error_type = "band"
)
```

#### Issue: Plot Text Too Small

**Problem**: Text is too small to read in saved plot.

**Solution**:
```r
# Option 1: Use theme with larger base size
plot <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id"
)

# Customize font sizes
plot <- plot + theme(
  text = element_text(size = 12),
  axis.title = element_text(size = 14),
  plot.title = element_text(size = 16)
)

# Option 2: Save with larger dimensions
ggsave("plot.pdf", plot, width = 12, height = 8)
```

#### Issue: Colors Not Distinct Enough

**Problem**: Treatment groups hard to distinguish.

**Solution**:
```r
# Use colorblind-friendly palette
colors <- get_colorblind_palette(n = 3, type = "qualitative")

plot <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  color_palette = colors
)

# Or use clinical colors (automatically distinct)
plot <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  treatment_colors = "standard"
)
```

#### Error: "Font family not found" in PDF

**Problem**: Publication themes require fonts not available in PDF device.

**Solution**:
```r
# Option 1: Use showtext package
library(showtext)
font_add('Arial', regular = '/System/Library/Fonts/Supplemental/Arial.ttf')
showtext_auto()

# Option 2: Override font family
plot <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  theme = "nature"
)
plot <- plot + theme(text = element_text(family = "sans"))

# Option 3: Use PNG instead of PDF
ggsave("plot.png", plot, dpi = 300)
```

### Frequently Asked Questions

#### Q: How do I handle missing data?

**A**: The package uses complete case analysis by default. For clinical trials, consider:

```r
# Option 1: LOCF imputation before plotting
library(zoo)
data_imputed <- data %>%
  group_by(subject_id, treatment) %>%
  arrange(visit) %>%
  mutate(outcome = na.locf(outcome, na.rm = FALSE)) %>%
  ungroup()

# Option 2: Document missingness
plot <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  show_sample_sizes = TRUE,  # Shows decreasing N if data missing
  caption = "Analysis includes only observed data; LOCF not applied"
)
```

#### Q: Can I customize the plot beyond package options?

**A**: Yes! The output is a ggplot2 object:

```r
# Create base plot
plot <- lplot(
  data,
  outcome ~ visit | treatment,
  cluster_var = "subject_id"
)

# Add custom elements
plot <- plot +
  geom_hline(yintercept = 50, linetype = "dashed", color = "red") +
  annotate("text", x = 2, y = 55, label = "Clinical threshold") +
  scale_y_continuous(limits = c(0, 100), breaks = seq(0, 100, 20)) +
  theme(
    plot.background = element_rect(fill = "white", color = NA),
    legend.position = c(0.8, 0.2)
  )
```

#### Q: How do I compare more than 2 groups?

**A**: Specify multiple levels in your grouping variable:

```r
# Data with 4 treatment groups
data_multi <- data.frame(
  subject_id = rep(1:80, each = 4),
  visit = rep(0:3, times = 80),
  outcome = rnorm(320),
  treatment = rep(c("Placebo", "Low", "Medium", "High"), each = 80)
)

# Plot automatically handles multiple groups
plot <- lplot(
  data_multi,
  outcome ~ visit | treatment,
  cluster_var = "subject_id",
  color_palette = get_colorblind_palette(4)
)
```

#### Q: Can I use this for non-clinical data?

**A**: Absolutely! The package works for any longitudinal data:

```r
# Educational assessment data
student_data <- data.frame(
  student_id = rep(1:100, each = 4),
  semester = rep(1:4, times = 100),
  gpa = rnorm(400, mean = 3.2, sd = 0.5),
  major = rep(c("STEM", "Humanities", "Business"), length.out = 400)
)

plot <- lplot(
  student_data,
  gpa ~ semester | major,
  cluster_var = "student_id",
  baseline_value = 1,
  title = "GPA Progression by Major"
)
```

#### Q: How do I create forest plots or other specialized visualizations?

**A**: For specialized plots, use the package functions as building blocks:

```r
# Get summary statistics
stats <- compute_stats(
  data,
  x_var = "visit",
  y_var = "outcome",
  group_var = "treatment",
  cluster_var = "subject_id",
  baseline_value = 0,
  confidence_interval = 0.95
)

# Create custom visualization
library(ggplot2)
custom_plot <- ggplot(stats, aes(x = visit, y = change_mean, color = group)) +
  # Your custom plotting code here
  theme_minimal()
```

#### Q: What's the difference between clinical_mode and theme parameters?

**A**:
- `clinical_mode = TRUE`: Enables multiple clinical features (95% CI, sample sizes, treatment colors, statistical tests, NEJM theme)
- `theme = "nejm"`: Only applies the visual theme and matching colors

```r
# Just the theme (visual appearance only)
plot1 <- lplot(data, outcome ~ visit | treatment,
               cluster_var = "subject_id", theme = "nejm")

# Full clinical mode (theme + statistical features + colors)
plot2 <- lplot(data, outcome ~ visit | treatment,
               cluster_var = "subject_id", clinical_mode = TRUE)

# Custom combination
plot3 <- lplot(data, outcome ~ visit | treatment,
               cluster_var = "subject_id",
               theme = "nature",           # Nature visual theme
               confidence_interval = 0.95, # Clinical CI
               show_sample_sizes = TRUE)   # Clinical sample sizes
```

#### Q: How do I cite this package?

**A**:
```r
# Get citation information
citation("zzlongplot")

# Or manually:
# Thomas, R.G. (2025). zzlongplot: Longitudinal Plotting with Clinical
# Trials Support. R package version 0.0.0.1000.
# https://github.com/rgt47/zzlongplot
```

---

## Complete API Reference

### Main Function

#### `lplot()`

Main function for creating longitudinal plots.

**Usage:**
```r
lplot(df, form, facet_form = NULL, cluster_var = "subject_id",
      baseline_value = "baseline", xlab = "visit", ylab = "measure",
      ylab2 = "measure change", title = "Observed Values",
      title2 = "Change from Baseline", subtitle = "", subtitle2 = "",
      caption = "", caption2 = "", plot_type = "obs", error_type = "bar",
      jitter_width = 0.15, color_palette = NULL, clinical_mode = FALSE,
      treatment_colors = NULL, confidence_interval = NULL,
      summary_statistic = "mean", show_sample_sizes = FALSE,
      visit_windows = NULL, theme = NULL, publication_ready = FALSE,
      statistical_annotations = FALSE, reference_lines = NULL,
      ribbon_alpha = 0.2, ribbon_fill = NULL)
```

**Parameters:**

- `df` - Data frame containing longitudinal data
- `form` - Formula: `y ~ x | group`
- `facet_form` - Optional faceting formula
- `cluster_var` - Subject/cluster ID variable name (default: "subject_id")
- `baseline_value` - Reference value for changes (numeric or character)
- `xlab`, `ylab`, `ylab2` - Axis labels
- `title`, `title2` - Plot titles
- `subtitle`, `subtitle2` - Plot subtitles
- `caption`, `caption2` - Plot captions
- `plot_type` - "obs", "change", or "both"
- `error_type` - "bar" or "band"
- `jitter_width` - Horizontal jitter for error bars (default: 0.15)
- `color_palette` - Vector of colors
- `clinical_mode` - Enable all clinical defaults (default: FALSE)
- `treatment_colors` - "standard" for clinical colors
- `confidence_interval` - CI level (e.g., 0.95)
- `summary_statistic` - "mean", "mean_se", "median", or "boxplot"
- `show_sample_sizes` - Show N at each timepoint (default: FALSE)
- `visit_windows` - List of visit window specifications
- `theme` - Publication theme name
- `publication_ready` - Enable publication defaults (default: FALSE)
- `statistical_annotations` - Add p-values (default: FALSE)
- `reference_lines` - List of reference line specs
- `ribbon_alpha` - Transparency for ribbons (0-1, default: 0.2)
- `ribbon_fill` - Custom ribbon fill color

**Returns:** ggplot2 object or patchwork combination

**Examples:**
```r
# Basic usage
lplot(data, outcome ~ visit | treatment, cluster_var = "subject_id")

# Clinical mode
lplot(clinical_data, AVAL ~ AVISITN | TRT01P,
      cluster_var = "USUBJID", clinical_mode = TRUE)

# Publication ready
lplot(data, score ~ time | group, theme = "nature", plot_type = "both")
```

---

### Statistical Functions

#### `compute_stats()`

Compute summary statistics for longitudinal data.

**Usage:**
```r
compute_stats(df, x_var, y_var, group_var, cluster_var, baseline_value,
              confidence_interval = NULL, summary_statistic = "mean",
              show_sample_sizes = FALSE, statistical_tests = FALSE,
              facet_vars = NULL)
```

**Parameters:**
- `df` - Data frame
- `x_var` - Independent variable name
- `y_var` - Dependent variable name
- `group_var` - Grouping variable name
- `cluster_var` - Cluster variable name
- `baseline_value` - Reference value for changes
- `confidence_interval` - CI level (e.g., 0.95)
- `summary_statistic` - "mean", "mean_se", "median", or "boxplot"
- `show_sample_sizes` - Include sample sizes
- `statistical_tests` - Perform group comparisons
- `facet_vars` - Faceting variables

**Returns:** Data frame with computed statistics

---

#### `add_statistical_tests()`

Add statistical comparisons (internal function).

**Usage:**
```r
add_statistical_tests(stats_df, original_df, x_var, y_var, group_var, cluster_var)
```

**Returns:** Enhanced statistics data frame with p-values

---

### Visualization Functions

#### `generate_plot()`

Create ggplot2 visualizations.

**Usage:**
```r
generate_plot(stats, x_var, y_var, group_var = NULL, error_type = "bar",
              jitter_width = 0.1, xlab = NULL, ylab = NULL, title = NULL,
              subtitle = NULL, caption = NULL, facet = NULL,
              color_palette = NULL, reference_lines = NULL,
              show_sample_sizes = FALSE, statistical_annotations = FALSE,
              use_boxplot = FALSE, ribbon_alpha = 0.2, ribbon_fill = NULL)
```

**Returns:** ggplot2 object

---

#### `parse_formula()`

Parse formula components.

**Usage:**
```r
parse_formula(formula)
```

**Parameters:**
- `formula` - R formula object (`y ~ x | group`)

**Returns:** List with y, x, group, facets

**Examples:**
```r
parse_formula(outcome ~ visit | treatment)
# $y: "outcome"
# $x: "visit"
# $group: "treatment"
# $facets: NULL
```

---

### Clinical Trial Functions

#### `suggest_clinical_vars()`

Detect CDISC variables and suggest formulas.

**Usage:**
```r
suggest_clinical_vars(data, verbose = TRUE)
```

**Parameters:**
- `data` - Clinical trial data frame
- `verbose` - Print detailed output

**Returns:** List with suggested_formula, detected_vars, cluster_var, baseline_value, warnings

---

#### `validate_cdisc_data()`

Validate CDISC compliance.

**Usage:**
```r
validate_cdisc_data(data, required_vars = c("USUBJID", "AVISITN", "AVAL"),
                    check_population_flags = TRUE)
```

**Returns:** List with compliance_score, issues, recommendations

---

#### `get_cdisc_template()`

Get template variables for analysis scenarios.

**Usage:**
```r
get_cdisc_template(scenario = "efficacy")
```

**Parameters:**
- `scenario` - "efficacy", "safety", "pk", or "biomarker"

**Returns:** Character vector of variable names

---

### Color Functions

#### `get_colorblind_palette()`

Generate colorblind-friendly palettes.

**Usage:**
```r
get_colorblind_palette(n = 8, type = "qualitative")
```

**Parameters:**
- `n` - Number of colors
- `type` - "qualitative", "sequential", or "diverging"

**Returns:** Character vector of hex color codes

---

#### `clinical_colors()`

Get clinical trial color palettes.

**Usage:**
```r
clinical_colors(type = "treatment", n = NULL, placebo_first = TRUE)
```

**Parameters:**
- `type` - "treatment", "severity", "outcome", "fda", or journal names
- `n` - Number of colors needed
- `placebo_first` - Placebo color first (for treatment palette)

**Returns:** Character vector of hex colors

**Available types:**
- "treatment" - Placebo (grey) + active treatments
- "severity" - Mild to severe progression
- "outcome" - Positive/neutral/negative
- "fda" - High contrast regulatory colors
- "nejm" - NEJM journal colors
- "nature" - Nature journal colors
- "lancet" - Lancet journal colors
- "jama" - JAMA journal colors
- "science" - Science journal colors
- "jco" - JCO journal colors

---

#### `assign_treatment_colors()`

Automatically assign colors to treatments.

**Usage:**
```r
assign_treatment_colors(treatment_var, palette_type = "treatment")
```

**Parameters:**
- `treatment_var` - Vector of treatment names
- `palette_type` - Palette type

**Returns:** Named vector of colors

---

#### `apply_clinical_colors()`

Apply clinical colors to ggplot objects.

**Usage:**
```r
apply_clinical_colors(plot, treatment_var = NULL, palette_type = "treatment", ...)
```

**Returns:** Modified ggplot object

---

### Theme Functions

#### `theme_nature()`

Nature journal theme.

**Usage:**
```r
theme_nature(base_size = 7, base_family = "sans", grid = FALSE, border = TRUE)
```

---

#### `theme_science()`

Science journal theme.

**Usage:**
```r
theme_science(base_size = 7, base_family = "sans", grid = TRUE)
```

---

#### `theme_nejm()`

NEJM clinical theme.

**Usage:**
```r
theme_nejm(base_size = 8, base_family = "sans", clinical = TRUE)
```

---

#### `theme_fda()`

FDA regulatory theme.

**Usage:**
```r
theme_fda(base_size = 10, base_family = "sans", high_contrast = TRUE)
```

---

#### `theme_lancet()`

Lancet journal theme.

**Usage:**
```r
theme_lancet(base_size = 8, base_family = "sans", grid = FALSE)
```

---

#### `theme_jama()`

JAMA journal theme.

**Usage:**
```r
theme_jama(base_size = 8, base_family = "sans", grid = FALSE)
```

---

#### `theme_jco()`

JCO journal theme.

**Usage:**
```r
theme_jco(base_size = 8, base_family = "sans", grid = FALSE)
```

---

#### `get_publication_theme()`

Get theme by name.

**Usage:**
```r
get_publication_theme(theme_name = "nature", ...)
```

**Parameters:**
- `theme_name` - "nature", "science", "nejm", "lancet", "jama", "jco", "fda"

**Returns:** ggplot2 theme object

---

#### `apply_publication_style()`

Apply theme and colors together.

**Usage:**
```r
apply_publication_style(plot, theme_name = "nature", color_palette = NULL, ...)
```

**Returns:** Modified ggplot object

---

### Publication Functions

#### `save_publication()`

Save plots with journal specifications.

**Usage:**
```r
save_publication(plot, filename, journal = "nature", width_mm = NULL,
                 height_mm = NULL, dpi = NULL, format = NULL,
                 column_type = "double", panel_label = NULL,
                 add_label_to_plot = FALSE, ...)
```

**Parameters:**
- `plot` - ggplot object
- `filename` - Output filename
- `journal` - "nature", "science", "nejm", "cell", "fda", "ema"
- `width_mm` - Width in millimeters
- `height_mm` - Height in millimeters
- `dpi` - Resolution (dots per inch)
- `format` - File format (if not in filename)
- `column_type` - "single" or "double"
- `panel_label` - Panel label (e.g., "A")
- `add_label_to_plot` - Add label directly to plot

**Returns:** Invisible path to saved file

---

#### `publication_panels()`

Create multi-panel figures.

**Usage:**
```r
publication_panels(plots, labels = NULL, layout = "horizontal",
                   ncol = NULL, nrow = NULL, shared_legend = FALSE,
                   legend_position = "bottom", label_size = 12,
                   label_face = "bold", spacing = 0.02)
```

**Parameters:**
- `plots` - List of ggplot objects
- `labels` - Panel labels (e.g., c("A", "B", "C"))
- `layout` - "horizontal", "vertical", or "grid"
- `ncol`, `nrow` - Grid dimensions
- `shared_legend` - Use single shared legend
- `legend_position` - Legend position
- `label_size` - Size of panel labels
- `label_face` - Font face for labels
- `spacing` - Spacing between panels

**Returns:** Combined plot object (patchwork)

---

#### `get_journal_specs()`

Get journal specifications.

**Usage:**
```r
get_journal_specs(journal)
```

**Returns:** List with journal specifications

---

#### `list_journals()`

List available journals.

**Usage:**
```r
list_journals(detailed = FALSE)
```

**Returns:** Data frame of journal specifications

---

## Appendix: Quick Reference

### Formula Syntax

```r
# Basic patterns
y ~ x                    # No grouping
y ~ x | group           # Single grouping
y ~ x | group1 + group2 # Multiple grouping

# With faceting (separate parameter)
lplot(data, y ~ x | group, facet_form = ~ facet_var)
lplot(data, y ~ x | group, facet_form = row_var ~ col_var)
```

### Common Parameter Combinations

```r
# Clinical trial analysis
lplot(data, AVAL ~ AVISITN | TRT01P,
      cluster_var = "USUBJID",
      clinical_mode = TRUE,
      plot_type = "both")

# Publication figure
lplot(data, outcome ~ visit | treatment,
      cluster_var = "subject_id",
      theme = "nature",
      confidence_interval = 0.95,
      plot_type = "both")

# Exploratory analysis
lplot(data, score ~ time | group,
      cluster_var = "id",
      summary_statistic = "median",
      error_type = "band")

# Regulatory submission
lplot(data, AVAL ~ AVISITN | TRT01P,
      cluster_var = "USUBJID",
      theme = "fda",
      confidence_interval = 0.95,
      show_sample_sizes = TRUE,
      statistical_annotations = TRUE)
```

### Default Values

- `cluster_var` = "subject_id"
- `baseline_value` = "baseline"
- `plot_type` = "obs"
- `error_type` = "bar"
- `jitter_width` = 0.15
- `summary_statistic` = "mean"
- `ribbon_alpha` = 0.2

### Color Palette Quick Reference

```r
# Clinical colors
clinical_colors("treatment", n = 3)  # Placebo + 2 active
clinical_colors("severity", n = 5)   # Mild to severe
clinical_colors("outcome")           # Positive/neutral/negative
clinical_colors("fda", n = 6)        # FDA submission

# Journal colors
clinical_colors("nejm", n = 4)
clinical_colors("nature", n = 4)
clinical_colors("lancet", n = 4)
clinical_colors("jama", n = 4)
clinical_colors("science", n = 4)
clinical_colors("jco", n = 4)

# Colorblind-friendly
get_colorblind_palette(n = 3, type = "qualitative")
get_colorblind_palette(n = 7, type = "sequential")
get_colorblind_palette(n = 9, type = "diverging")
```

### Theme Quick Reference

```r
theme = "nature"   # Nature Publishing Group
theme = "science"  # Science (AAAS)
theme = "nejm"     # New England Journal of Medicine
theme = "lancet"   # The Lancet
theme = "jama"     # JAMA
theme = "jco"      # Journal of Clinical Oncology
theme = "fda"      # FDA regulatory
```

---

## Additional Resources

### Package Website
https://github.com/rgt47/zzlongplot

### Report Issues
https://github.com/rgt47/zzlongplot/issues

### Vignettes
```r
vignette("zzlongplot_introduction")
vignette("clinical-trials")
vignette("cdisc-compliance")
vignette("publication-themes")
```

### Related Packages
- **ggplot2** - Graphics foundation
- **dplyr** - Data manipulation
- **patchwork** - Combining plots
- **RColorBrewer** - Color palettes

---

**Document Version:** 1.0
**Last Updated:** 2025-09-30
**Package Version:** 0.0.0.1000

For the latest documentation, visit the package website or view the built-in help:
```r
?lplot
help(package = "zzlongplot")
```
