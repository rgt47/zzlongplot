# zzlongplot API Reference

## Table of Contents

1. [Core Functions](#core-functions)
2. [Statistical Functions](#statistical-functions)
3. [Visualization Functions](#visualization-functions)
4. [Clinical Trial Functions](#clinical-trial-functions)
5. [Publication Functions](#publication-functions)
6. [Theme Functions](#theme-functions)
7. [Color Functions](#color-functions)
8. [Utility Functions](#utility-functions)

---

## Core Functions

### `lplot()`

**Description**: Main function for creating longitudinal plots with observed and change values.

**Usage**:
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

**Parameters**:
- `df`: Data frame containing the longitudinal data
- `form`: Formula specifying variables (`y ~ x | group`)
- `facet_form`: Optional formula for faceting
- `cluster_var`: Variable name for clustering (typically subject ID)
- `baseline_value`: Baseline value for change calculations
- `plot_type`: Type of plot ("obs", "change", "both")
- `error_type`: Error representation ("bar" or "band")
- `clinical_mode`: Enable clinical trial defaults
- `theme`: Publication theme name
- Additional parameters for customization

**Returns**: ggplot2 object or patchwork combination

**Examples**:
```r
# Basic longitudinal plot
lplot(data, efficacy ~ visit | treatment, cluster_var = "subject_id")

# Clinical trial analysis
lplot(clinical_data, AVAL ~ AVISITN | TRT01P, clinical_mode = TRUE)

# Publication-ready output
lplot(data, score ~ time | group, theme = "nature", plot_type = "both")
```

---

## Statistical Functions

### `compute_stats()`

**Description**: Computes summary statistics for longitudinal data.

**Usage**:
```r
compute_stats(df, x_var, y_var, group_var, cluster_var, baseline_value,
              confidence_interval = NULL, summary_statistic = "mean",
              show_sample_sizes = FALSE, statistical_tests = FALSE,
              facet_vars = NULL)
```

**Parameters**:
- `df`: Data frame containing the data
- `x_var`: Independent variable name
- `y_var`: Dependent variable name
- `group_var`: Grouping variable name
- `cluster_var`: Clustering variable name
- `baseline_value`: Baseline value for change calculations
- `summary_statistic`: Type of summary ("mean", "median", "boxplot")
- `confidence_interval`: Confidence level (e.g., 0.95)

**Returns**: Data frame with computed statistics including means, standard errors, confidence intervals, and change from baseline calculations

### `add_statistical_tests()`

**Description**: Internal function to add statistical comparisons between groups.

**Usage**:
```r
add_statistical_tests(stats_df, original_df, x_var, y_var, group_var, cluster_var)
```

**Returns**: Enhanced statistics data frame with p-values and significance indicators

---

## Visualization Functions

### `generate_plot()`

**Description**: Creates customized ggplot2 visualizations for longitudinal data.

**Usage**:
```r
generate_plot(stats, x_var, y_var, group_var = NULL, error_type = "bar",
              jitter_width = 0.1, xlab = NULL, ylab = NULL, title = NULL,
              subtitle = NULL, caption = NULL, facet = NULL,
              color_palette = NULL, reference_lines = NULL,
              show_sample_sizes = FALSE, statistical_annotations = FALSE,
              use_boxplot = FALSE, ribbon_alpha = 0.2, ribbon_fill = NULL)
```

**Parameters**:
- `stats`: Data frame with computed statistics
- `x_var`: X-axis variable name
- `y_var`: Y-axis variable name
- `error_type`: Error visualization type
- `use_boxplot`: Whether to render boxplots
- `ribbon_alpha`: Transparency for ribbon bands
- `reference_lines`: List of reference line specifications

**Returns**: ggplot2 object

### `parse_formula()`

**Description**: Parses formula components for longitudinal plotting.

**Usage**:
```r
parse_formula(formula)
```

**Parameters**:
- `formula`: R formula object with format `y ~ x | group`

**Returns**: List with components: y, x, group, facets

**Examples**:
```r
parse_formula(score ~ visit | treatment)
parse_formula(efficacy ~ time | arm ~ site + gender)
```

---

## Clinical Trial Functions

### `suggest_clinical_vars()`

**Description**: Automatically detects CDISC variables and suggests formula syntax.

**Usage**:
```r
suggest_clinical_vars(data, verbose = TRUE)
```

**Parameters**:
- `data`: Data frame containing clinical trial data
- `verbose`: Whether to provide detailed output

**Returns**: List containing suggested formula, detected variables, cluster variable, baseline value, and warnings

**Examples**:
```r
suggestions <- suggest_clinical_vars(clinical_data)
print(suggestions$suggested_formula)
```

### `validate_cdisc_data()`

**Description**: Checks clinical dataset for CDISC compliance.

**Usage**:
```r
validate_cdisc_data(data, required_vars = c("USUBJID", "AVISITN", "AVAL"),
                    check_population_flags = TRUE)
```

**Parameters**:
- `data`: Clinical trial data frame
- `required_vars`: Variables that must be present
- `check_population_flags`: Whether to check for population flags

**Returns**: List with compliance score, issues, and recommendations

### `get_cdisc_template()`

**Description**: Provides template variable names for clinical scenarios.

**Usage**:
```r
get_cdisc_template(scenario = "efficacy")
```

**Parameters**:
- `scenario`: Analysis type ("efficacy", "safety", "pk", "biomarker")

**Returns**: Character vector of recommended variable names

---

## Publication Functions

### `save_publication()`

**Description**: Exports plots in publication-ready formats with journal specifications.

**Usage**:
```r
save_publication(plot, filename, journal = "nature", width_mm = NULL,
                 height_mm = NULL, dpi = NULL, format = NULL,
                 column_type = "double", panel_label = NULL,
                 add_label_to_plot = FALSE, ...)
```

**Parameters**:
- `plot`: ggplot object to save
- `filename`: Output filename
- `journal`: Journal name ("nature", "science", "nejm", "cell", "fda", "ema")
- `width_mm`: Plot width in millimeters
- `height_mm`: Plot height in millimeters
- `dpi`: Resolution in dots per inch
- `column_type`: "single" or "double" column
- `panel_label`: Panel label for multi-panel figures

**Returns**: Invisible path to saved file

### `publication_panels()`

**Description**: Combines multiple plots into publication-ready multi-panel figures.

**Usage**:
```r
publication_panels(plots, labels = NULL, layout = "horizontal",
                   ncol = NULL, nrow = NULL, shared_legend = FALSE,
                   legend_position = "bottom", label_size = 12,
                   label_face = "bold", spacing = 0.02)
```

**Parameters**:
- `plots`: List of ggplot objects
- `labels`: Panel labels (e.g., c("A", "B", "C"))
- `layout`: Layout type ("horizontal", "vertical", "grid")
- `shared_legend`: Whether to use shared legend

**Returns**: Combined plot object (patchwork)

### `get_journal_specs()`

**Description**: Returns formatting specifications for a journal.

**Usage**:
```r
get_journal_specs(journal)
```

**Returns**: List containing journal specifications

### `list_journals()`

**Description**: Lists available journal specifications.

**Usage**:
```r
list_journals(detailed = FALSE)
```

**Returns**: Data frame of journal specifications

---

## Theme Functions

### Publication Themes

#### `theme_nature()`
**Description**: Nature journal theme following publication guidelines.

**Usage**:
```r
theme_nature(base_size = 7, base_family = "sans", grid = FALSE, border = TRUE)
```

#### `theme_science()`
**Description**: Science journal theme with AAAS specifications.

**Usage**:
```r
theme_science(base_size = 7, base_family = "sans", grid = TRUE)
```

#### `theme_nejm()`
**Description**: New England Journal of Medicine theme for clinical publications.

**Usage**:
```r
theme_nejm(base_size = 8, base_family = "sans", clinical = TRUE)
```

#### `theme_fda()`
**Description**: FDA regulatory theme for submission documents.

**Usage**:
```r
theme_fda(base_size = 10, base_family = "sans", high_contrast = TRUE)
```

#### `theme_lancet()`
**Description**: Lancet journal theme for medical publications.

**Usage**:
```r
theme_lancet(base_size = 8, base_family = "sans", grid = FALSE)
```

#### `theme_jama()`
**Description**: JAMA journal theme with conservative styling.

**Usage**:
```r
theme_jama(base_size = 8, base_family = "sans", grid = FALSE)
```

#### `theme_jco()`
**Description**: Journal of Clinical Oncology theme.

**Usage**:
```r
theme_jco(base_size = 8, base_family = "sans", grid = FALSE)
```

### Theme Utilities

#### `get_publication_theme()`
**Description**: Convenience function to get themes by name.

**Usage**:
```r
get_publication_theme(theme_name = "nature", ...)
```

#### `apply_publication_style()`
**Description**: Applies both theme and color palette to plots.

**Usage**:
```r
apply_publication_style(plot, theme_name = "nature", color_palette = NULL, ...)
```

---

## Color Functions

### `clinical_colors()`

**Description**: Provides standardized color palettes for clinical visualizations.

**Usage**:
```r
clinical_colors(type = "treatment", n = NULL, placebo_first = TRUE)
```

**Parameters**:
- `type`: Palette type ("treatment", "severity", "outcome", "fda", journal names)
- `n`: Number of colors needed
- `placebo_first`: Whether placebo should be first color

**Returns**: Character vector of hex color codes

**Examples**:
```r
# Standard treatment colors
colors <- clinical_colors("treatment", n = 3)

# Journal-specific colors
nejm_colors <- clinical_colors("nejm", n = 4)
```

### `assign_treatment_colors()`

**Description**: Automatically assigns colors to treatment groups.

**Usage**:
```r
assign_treatment_colors(treatment_var, palette_type = "treatment")
```

**Parameters**:
- `treatment_var`: Character vector of treatment names
- `palette_type`: Color palette type

**Returns**: Named character vector of colors

### `apply_clinical_colors()`

**Description**: Applies clinical color schemes to ggplot objects.

**Usage**:
```r
apply_clinical_colors(plot, treatment_var = NULL, palette_type = "treatment", ...)
```

**Parameters**:
- `plot`: ggplot object
- `treatment_var`: Treatment variable name
- `palette_type`: Clinical palette type

**Returns**: Modified ggplot object

### `get_colorblind_palette()`

**Description**: Creates colorblind-friendly palettes.

**Usage**:
```r
get_colorblind_palette(n = 8, type = "qualitative")
```

**Parameters**:
- `n`: Number of colors
- `type`: Palette type ("qualitative", "sequential", "diverging")

**Returns**: Character vector of colorblind-friendly colors

---

## Utility Functions

### Data Validation

#### Global Variables Declaration
The package properly declares global variables to avoid R CMD check notes:
- Statistical variables: `change`, `standard_deviation`, `sample_size`, `change_sd`
- Summary variables: `mean_value`, `standard_error`, `change_mean`, `change_se`
- Bound variables: `bound_lower`, `bound_upper`, `bound_lower_change`, `bound_upper_change`
- Quartile variables: `q25_value`, `q75_value`, `q25_change`, `q75_change`
- IQR and whisker variables: `iqr_value`, `iqr_change`, `whisker_lower`, `whisker_upper`

### Internal Lookup Tables

#### `.cdisc_lookup`
Internal lookup table for CDISC variable recognition:
- Subject identifiers: USUBJID, SUBJID
- Visit variables: AVISITN, AVISIT
- Analysis values: AVAL, AVALC
- Treatment variables: TRT01P, TRT01A
- Population flags: SAFFL, FASFL
- Parameter information: PARAM, PARAMCD

#### `.journal_specs`
Internal specifications for journal formatting:
- Dimension requirements (single/double column)
- Resolution specifications (DPI)
- Font requirements
- Acceptable file formats
- Color mode specifications

### Error Handling

The package implements comprehensive error handling:
- Input validation for all user-facing functions
- Graceful degradation with informative warnings
- Parameter bounds checking
- Missing data handling strategies

### Performance Optimizations

- Vectorized statistical computations using dplyr
- Efficient ggplot2 layer management
- Minimal data copying and transformation
- Cached computation reuse where appropriate

---

## Usage Patterns

### Basic Longitudinal Analysis
```r
# Load package and data
library(zzlongplot)

# Create basic longitudinal plot
plot <- lplot(data, efficacy ~ visit | treatment,
              cluster_var = "subject_id",
              baseline_value = 0)
```

### Clinical Trial Analysis
```r
# Enable clinical mode for CDISC data
clinical_plot <- lplot(clinical_data,
                      AVAL ~ AVISITN | TRT01P,
                      cluster_var = "USUBJID",
                      clinical_mode = TRUE,
                      plot_type = "both")
```

### Publication Output
```r
# Create publication-ready figure
pub_plot <- lplot(data, score ~ time | group,
                  theme = "nature",
                  confidence_interval = 0.95,
                  show_sample_sizes = TRUE)

# Save for journal submission
save_publication(pub_plot, "figure1.pdf",
                journal = "nature",
                column_type = "double")
```

### Multi-Panel Figures
```r
# Create individual plots
p1 <- lplot(data1, y1 ~ x | group, theme = "nejm")
p2 <- lplot(data2, y2 ~ x | group, theme = "nejm")

# Combine into publication figure
combined <- publication_panels(list(p1, p2),
                              labels = c("A", "B"),
                              layout = "horizontal")

# Export combined figure
save_publication(combined, "figure2.pdf", journal = "nejm")
```