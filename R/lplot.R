#' @title Flexible Plotting of Observed and Change Values with Grouping and Faceting
#' @name zzlongplot-package
#' 
#' @description These functions provide a flexible framework for generating observed
#' and change plots using a data frame, accommodating both continuous and 
#' categorical variables for the x-axis. They handle baseline (`baseline_value`) 
#' specification, grouping, and faceting. This version allows the user to return 
#' either the observed plot, the change plot, or both combined side-by-side using 
#' the **patchwork** package.
#'
#' @details
#' - `compute_stats`: Computes summary statistics for observed and change values, 
#'   adapting to continuous or categorical x-axis variables.
#' - `generate_plot`: Dynamically generates ggplot objects based on whether the 
#'   x-axis is continuous or categorical, supports error representation (bars or 
#'   ribbons), and faceting.
#' - `parse_formula`: Parses the formula to extract dependent, independent, 
#'   grouping, and faceting variables.
#' - `lplot`: Combines the functionality of the helper functions to produce 
#'   the final plots or combined plots as specified.
#'
#' @import dplyr ggplot2 patchwork
NULL

# Declare global variables to avoid R CMD check notes
#' @noRd
utils::globalVariables(c(
  "change", "standard_deviation", "sample_size", "change_sd", 
  "mean_value", "standard_error", "change_mean", "change_se", 
  "bound_lower", "bound_upper", "bound_lower_change", "bound_upper_change"
))

#' @title Create Longitudinal Plots for Observed and Change Values
#'
#' @description Generates flexible plots for longitudinal data, showing either 
#' observed values, change from baseline, or both. Supports grouping and faceting.
#'
#' @param df A data frame containing the data to be plotted.
#' @param form A formula specifying the variables for the x-axis, grouping, and 
#'   y-axis. Format: `y ~ x | group`.
#' @param facet_form A formula specifying the variables for faceting. Format: 
#'   `facet_y ~ facet_x`. Default is `NULL`.
#' @param cluster_var A character string specifying the name of the cluster 
#'   variable for grouping within subjects (typically a participant or subject ID).
#' @param baseline_value The baseline value of the x variable, used to calculate changes.
#'   For categorical x variables, this is treated as a level. For continuous x 
#'   variables, this is treated as a numeric value.
#' @param xlab Label for the x-axis.
#' @param ylab Label for the y-axis of the observed values plot.
#' @param ylab2 Label for the y-axis of the change values plot.
#' @param title Title for the observed values plot.
#' @param title2 Title for the change values plot.
#' @param subtitle Subtitle for the observed values plot.
#' @param subtitle2 Subtitle for the change values plot.
#' @param caption Caption for the observed values plot.
#' @param caption2 Caption for the change values plot.
#' @param plot_type Type of plot to return. Options are `"obs"` (observed values), 
#'   `"change"` (change values), or `"both"` for combined plots.
#' @param error_type Type of error representation. Options are `"bar"` for error bars 
#'   (vertical lines showing standard error) or `"band"` for error ribbons 
#'   (shaded areas around the line).
#' @param jitter_width Numeric. Width of horizontal jitter for error bars when 
#'   multiple groups are present. Default is 0.1. Set to 0 to disable jittering.
#'   Only applies when error_type = "bar".
#' @param color_palette Optional vector of colors to use for groups. If NULL, 
#'   default ggplot colors are used.
#' @param clinical_mode Logical. If TRUE, enables clinical trial defaults 
#'   (95% CI, sample sizes, clinical colors). Default is FALSE.
#' @param treatment_colors Character. Predefined color scheme for treatments. 
#'   Options: "standard" (placebo=grey, active=colors), or NULL.
#' @param confidence_interval Numeric. Confidence level for error bounds 
#'   (e.g., 0.95 for 95% CI). If NULL, uses standard error.
#' @param summary_statistic Character. Type of summary statistic to calculate.
#'   Options: "mean" (mean ± CI/SE), "mean_se" (mean ± SE), "median" (median + IQR), 
#'   or "boxplot" (boxplot summary with quartiles). Default is "mean".
#' @param show_sample_sizes Logical. If TRUE, shows sample sizes at each timepoint.
#' @param visit_windows List. Named list defining visit windows for grouping 
#'   (e.g., list("Week 4" = c(22, 35))).
#' @param theme Character. Predefined publication theme with matching colors.
#'   Options: "nejm", "nature", "lancet", "jama", "science", "jco", "fda", or NULL.
#'   Applies both typography/layout AND journal-specific color palette automatically.
#' @param publication_ready Logical. If TRUE, applies publication-ready defaults
#'   (professional theme, proper typography, clean styling).
#' @param statistical_annotations Logical. If TRUE, adds p-values and significance
#'   indicators to the plots.
#' @param reference_lines List of reference line specifications. Each should be a 
#'   list with 'value', 'axis' ("x"/"y"), 'color', 'linetype', etc.
#'
#' @return A ggplot2 object or a combination of objects representing the requested 
#'   plots.
#'
#' @examples
#' # Example with continuous x variable
#' df <- data.frame(
#'   subject_id = rep(1:10, each = 3),
#'   visit = rep(c(0, 1, 2), times = 10),
#'   measure = rnorm(30, mean = 50, sd = 10),
#'   group = rep(c("Treatment", "Control"), length.out = 30)
#' )
#' # Plot observed values by visit and group
#' lplot(df, measure ~ visit | group, baseline_value = 0, 
#'       cluster_var = "subject_id")
#' 
#' # Plot with jittered error bars for better group separation
#' lplot(df, measure ~ visit | group, baseline_value = 0, 
#'       cluster_var = "subject_id", jitter_width = 0.15)
#' 
#' # Plot using median and IQR instead of mean and CI
#' lplot(df, measure ~ visit | group, baseline_value = 0,
#'       cluster_var = "subject_id", summary_statistic = "median")
#' 
#' # Plot using mean ± SE (standard error)
#' lplot(df, measure ~ visit | group, baseline_value = 0,
#'       cluster_var = "subject_id", summary_statistic = "mean_se")
#'
#' # Plot using boxplot summary (quartiles + whiskers)
#' lplot(df, measure ~ visit | group, baseline_value = 0,
#'       cluster_var = "subject_id", summary_statistic = "boxplot")
#' 
#' # Apply complete journal styling (theme + colors) with single parameter
#' lplot(df, measure ~ visit | group, baseline_value = 0,
#'       cluster_var = "subject_id", theme = "nejm")    # NEJM theme + colors
#' lplot(df, measure ~ visit | group, baseline_value = 0,
#'       cluster_var = "subject_id", theme = "nature")  # Nature theme + colors
#'
#' # Example with categorical x variable
#' df2 <- data.frame(
#'   subject_id = rep(1:10, each = 3),
#'   visit = rep(c("baseline", "month1", "month2"), times = 10),
#'   measure = rnorm(30, mean = 50, sd = 10),
#'   group = rep(c("Treatment", "Control"), length.out = 30)
#' )
#' # Plot both observed and change values
#' lplot(df2, measure ~ visit | group, baseline_value = "baseline",
#'       cluster_var = "subject_id", plot_type = "both",
#'       title = "Treatment Response", title2 = "Change from Baseline")
#'
#' # Clinical trial example with CDISC variables
#' clinical_data <- data.frame(
#'   USUBJID = rep(paste0("001-", sprintf("%03d", 1:20)), each = 4),
#'   AVISITN = rep(c(0, 1, 2, 3), times = 20),
#'   AVAL = rnorm(80, mean = c(50, 48, 45, 42), sd = 8),
#'   TRT01P = rep(c("Placebo", "Drug A", "Drug B"), length.out = 80)
#' )
#' 
#' # Clinical mode with automatic CDISC handling
#' lplot(clinical_data, AVAL ~ AVISITN | TRT01P, 
#'       cluster_var = "USUBJID", baseline_value = 0,
#'       clinical_mode = TRUE, plot_type = "both",
#'       title = "Clinical Trial Results")
#'
#' @export
lplot <- function(
  df, form, facet_form = NULL, cluster_var = "subject_id", baseline_value = "baseline",
  xlab = "visit", ylab = "measure", ylab2 = "measure change",
  title = "Observed Values", title2 = "Change from Baseline",
  subtitle = "", subtitle2 = "", caption = "", caption2 = "",
  plot_type = "obs", error_type = "bar", jitter_width = 0.1, color_palette = NULL,
  clinical_mode = FALSE, treatment_colors = NULL, confidence_interval = NULL,
  summary_statistic = "mean", show_sample_sizes = FALSE, visit_windows = NULL, theme = NULL,
  publication_ready = FALSE, statistical_annotations = FALSE,
  reference_lines = NULL
) {
  # Input validation
  if (!is.data.frame(df)) {
    stop("Input 'df' must be a data frame")
  }
  
  if (!inherits(form, "formula")) {
    stop("Input 'form' must be a formula object")
  }
  
  if (!is.null(facet_form) && !inherits(facet_form, "formula")) {
    stop("If provided, 'facet_form' must be a formula object")
  }
  
  if (!cluster_var %in% names(df)) {
    stop(sprintf("Cluster variable '%s' not found in data frame", cluster_var))
  }
  
  # Validate plot type
  valid_plot_types <- c("obs", "change", "both")
  if (!plot_type %in% valid_plot_types) {
    stop(sprintf("Invalid plot_type '%s'. Must be one of: %s", 
                 plot_type, paste(valid_plot_types, collapse = ", ")))
  }
  
  # Validate error type
  valid_error_types <- c("bar", "band")
  if (!error_type %in% valid_error_types) {
    stop(sprintf("Invalid error_type '%s'. Must be one of: %s", 
                 error_type, paste(valid_error_types, collapse = ", ")))
  }
  
  # Validate jitter_width
  if (!is.numeric(jitter_width) || length(jitter_width) != 1 || jitter_width < 0) {
    stop("jitter_width must be a non-negative numeric value")
  }
  
  # Validate summary_statistic
  valid_statistics <- c("mean", "mean_se", "median", "boxplot")
  if (!summary_statistic %in% valid_statistics) {
    stop(sprintf("Invalid summary_statistic '%s'. Must be one of: %s", 
                 summary_statistic, paste(valid_statistics, collapse = ", ")))
  }
  
  # Apply clinical mode defaults
  if (clinical_mode) {
    if (is.null(confidence_interval)) confidence_interval <- 0.95
    if (is.null(treatment_colors)) treatment_colors <- "standard"  
    show_sample_sizes <- TRUE
    statistical_annotations <- TRUE
    if (is.null(theme)) theme <- "nejm"
  }
  
  # Apply publication ready defaults  
  if (publication_ready) {
    if (is.null(theme)) theme <- "nature"
    if (is.null(confidence_interval)) confidence_interval <- 0.95
    show_sample_sizes <- TRUE
  }
  
  # Parse formulas
  parsed_form <- parse_formula(form)
  parsed_facet <- if (!is.null(facet_form)) parse_formula(facet_form) else NULL
  
  # Compute grouped statistics
  stats <- compute_stats(
    df = df, 
    x_var = parsed_form$x, 
    y_var = parsed_form$y, 
    group_var = parsed_form$group, 
    cluster_var = cluster_var, 
    baseline_value = baseline_value,
    confidence_interval = confidence_interval,
    summary_statistic = summary_statistic,
    show_sample_sizes = show_sample_sizes,
    statistical_tests = statistical_annotations
  )
  
  # Prepare stats for change plot
  stats_change <- stats %>%
    dplyr::select(-bound_upper, -bound_lower) %>%
    dplyr::rename(
      bound_lower = bound_lower_change,
      bound_upper = bound_upper_change
    )
  
  # Apply treatment colors if specified
  if (!is.null(treatment_colors) && treatment_colors == "standard") {
    color_palette <- assign_treatment_colors(unique(stats$group))
  }
  
  # Generate the observed and change plots
  fig_obs <- generate_plot(
    stats = stats, 
    x_var = parsed_form$x, 
    y_var = "mean_value", 
    group_var = "group",
    error_type = error_type, 
    jitter_width = jitter_width,
    xlab = xlab, 
    ylab = ylab, 
    title = title, 
    subtitle = subtitle, 
    caption = caption, 
    facet = parsed_facet,
    color_palette = color_palette,
    reference_lines = reference_lines,
    show_sample_sizes = show_sample_sizes,
    statistical_annotations = statistical_annotations
  )
  
  fig_change <- generate_plot(
    stats = stats_change, 
    x_var = parsed_form$x, 
    y_var = "change_mean", 
    group_var = "group",
    error_type = error_type, 
    jitter_width = jitter_width,
    xlab = xlab, 
    ylab = ylab2, 
    title = title2, 
    subtitle = subtitle2, 
    caption = caption2, 
    facet = parsed_facet,
    color_palette = color_palette,
    reference_lines = reference_lines,
    show_sample_sizes = show_sample_sizes,
    statistical_annotations = statistical_annotations
  )
  
  # Apply publication theme and colors if specified
  if (!is.null(theme)) {
    # Apply theme
    pub_theme <- get_publication_theme(theme)
    fig_obs <- fig_obs + pub_theme
    fig_change <- fig_change + pub_theme
    
    # Apply matching journal colors if available and no color_palette specified
    journal_themes <- c("nejm", "nature", "lancet", "jama", "science", "jco")
    if (theme %in% journal_themes && is.null(color_palette)) {
      # Get journal-specific colors
      journal_colors <- clinical_colors(theme)
      
      # Apply colors to both plots
      fig_obs <- fig_obs + 
        ggplot2::scale_color_manual(values = journal_colors) +
        ggplot2::scale_fill_manual(values = journal_colors)
      
      fig_change <- fig_change + 
        ggplot2::scale_color_manual(values = journal_colors) +
        ggplot2::scale_fill_manual(values = journal_colors)
    }
  }
  
  # Return the requested plots
  if (plot_type == "obs") {
    return(fig_obs)
  } else if (plot_type == "change") {
    return(fig_change)
  } else if (plot_type == "both") {
    return(fig_obs + fig_change + patchwork::plot_layout(ncol = 2))
  }
}