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
#' @param baseline_value The baseline value of the x variable, used to calculate
#'   changes. For categorical x variables, this is treated as a level. For
#'   continuous x variables, this is treated as a numeric value. If NULL
#'   (the default), the function attempts to auto-detect a baseline code
#'   from common labels (e.g., 'bl', 'baseline', 'screening') or, for
#'   numeric visit variables, uses the minimum value.
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
#'   multiple groups are present. Default is 0.15. Set to 0 to disable jittering.
#'   Only applies when error_type = "bar".
#' @param color_palette Optional vector of colors to use for groups. If NULL, 
#'   default ggplot colors are used.
#' @param clinical_mode Logical. If TRUE, enables clinical trial defaults 
#'   (95% CI, sample sizes, clinical colors). Default is FALSE.
#' @param treatment_colors Character. Predefined color scheme for treatments. 
#'   Options: "standard" (placebo=gray, active=colors), or NULL.
#' @param confidence_interval Numeric. Confidence level for error bounds 
#'   (e.g., 0.95 for 95% CI). If NULL, uses standard error.
#' @param summary_statistic Character. Type of summary statistic to calculate.
#'   Options: "mean" (mean +/- CI/SE), "mean_se" (mean +/- SE), "median" (median + IQR), 
#'   or "boxplot" (boxplot summary with quartiles). Default is "mean".
#' @param show_sample_sizes Logical. If TRUE (the default), the number
#'   of non-missing observations contributing to each group at each
#'   timepoint is drawn on the plot. This is on by default because
#'   CONSORT 2025 item 26 requires reporting "the number of
#'   participants with available data at each time point", and because
#'   a longitudinal figure with a silently shrinking denominator hides
#'   attrition. Set to FALSE to suppress. See `sample_size_opts` for
#'   placement, including a numbers-below-axis table.
#' @param sample_size_opts List. Options for sample size label appearance.
#'   Key option: position = "point" (default, labels next to points) or
#'   "table" (color-coded table below x-axis). See [generate_plot()]
#'   for all available options.
#' @param theme Character. Predefined publication theme with matching colors.
#'   Options: "bw", "nejm", "nature", "lancet", "jama", "science", "jco",
#'   "fda", or "default". Applies both typography/layout AND, where one
#'   exists, the journal-specific color palette. Defaults to `NULL`,
#'   which resolves to `"nejm"` under `clinical_mode`, `"nature"` under
#'   `publication_ready`, and otherwise to `"bw"`. Pass an explicit value
#'   to override the mode defaults.
#' @param publication_ready Logical. If TRUE, applies publication-ready
#'   defaults: the `"nature"` theme (unless `theme` is given
#'   explicitly), a 95% confidence interval, and sample-size
#'   annotations.
#' @param statistical_annotations Logical. If TRUE, adds p-values and significance
#'   indicators to the plots.
#' @param test_method Character. Testing approach for group comparisons:
#'   "parametric" (t-test / ANOVA, the default), "nonparametric"
#'   (Wilcoxon rank-sum / Kruskal-Wallis), or "mmrm" (mixed model
#'   for repeated measures with emmeans contrasts; requires the
#'   mmrm and emmeans packages).
#' @param p_adjust_method Character. Multiple comparison correction passed
#'   to [stats::p.adjust()]. Default is "BH" (Benjamini-Hochberg). Use
#'   "none" to disable adjustment.
#' @param cov_struct Character. Covariance structure for MMRM (only used
#'   when test_method = "mmrm"). Options: "auto" (unstructured for
#'   <= 10 timepoints, compound symmetry otherwise, with automatic
#'   fallback on convergence failure), "us" (unstructured), "cs"
#'   (compound symmetry), "ar1", "ar1h" (heterogeneous AR(1)),
#'   "toep" (Toeplitz), "toeph" (heterogeneous Toeplitz), "ad"
#'   (ante-dependence), "sp_exp" (spatial exponential). Default
#'   is "auto".
#' @param reference_lines List of reference line specifications. Each should be a 
#'   list with 'value', 'axis' ("x"/"y"), 'color', 'linetype', etc.
#' @param ribbon_alpha Numeric. Transparency level for ribbon/band error representations.
#'   Values from 0 (fully transparent) to 1 (fully opaque). Default is 0.2.
#' @param ribbon_fill Character. Custom fill color for ribbons. If NULL, uses group colors.
#' @param contrast_display Optional character string controlling
#'   whether and how the between-group contrasts are reported.
#'   Requires `statistical_annotations = TRUE`. Options:
#'   \describe{
#'     \item{`"footnote"`}{Adds the estimate, confidence interval and
#'       p-value for each significant contrast to the caption.}
#'     \item{`"table"`}{Appends a table of all contrasts below the
#'       plot.}
#'     \item{`"panel"`}{Appends a panel plotting each contrast against
#'       time with its confidence interval and a zero reference line.}
#'   }
#'   `NULL` (the default) reports no contrasts. The per-arm error bars
#'   on the main plot describe each group separately and cannot show
#'   the difference between them; CONSORT 2025 item 26 asks for the
#'   effect size and its precision, so prefer one of these when the
#'   figure is making a comparative claim.
#' @param auto_caption Logical. If TRUE (the default), and no
#'   `caption` is supplied, the caption is generated automatically and
#'   states what the error bars or bands represent: a confidence
#'   interval and its level, `+/-1 SE`, the interquartile range, or
#'   the boxplot construction, matching whatever was actually
#'   computed. When `statistical_annotations = TRUE` it also states
#'   the significance thresholds and the multiplicity adjustment.
#'   This is on by default because *Nature* and *Nature Medicine*
#'   require all error bars to be defined in the figure legend, and
#'   *JAMA* and *Science* require the measure of dispersion to be
#'   identified. An explicit `caption` (or `caption2`) always takes
#'   precedence; set `auto_caption = FALSE` to suppress generation.
#'
#' @return A plot object whose class depends on how many panels were
#'   assembled:
#'   * a `ggplot` when `plot_type` is `"obs"` or `"change"`;
#'   * a `patchwork` (which also inherits from `ggplot`) when
#'     `plot_type = "both"`, or when `contrast_display` is `"table"` or
#'     `"panel"` and pairwise contrasts were produced, since the
#'     contrast display is appended as an extra panel.
#'
#'   Because `contrast_display` can change the class independently of
#'   `plot_type`, callers that manipulate the result programmatically
#'   should test with `inherits(x, "patchwork")` rather than assume a
#'   plain `ggplot`. Both classes print and both accept
#'   [ggplot2::ggsave()].
#'
#' @seealso [compute_stats()] for the statistics underlying the plot,
#'   [generate_plot()] for the lower-level renderer,
#'   [parse_formula()] for the accepted formula syntax, and
#'   [save_publication()] to export the result.
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
#' # Plot using mean +/- SE (standard error)
#' lplot(df, measure ~ visit | group, baseline_value = 0,
#'       cluster_var = "subject_id", summary_statistic = "mean_se")
#'
#' # Plot using boxplot summary (quartiles + whiskers)
#' lplot(df, measure ~ visit | group, baseline_value = 0,
#'       cluster_var = "subject_id", summary_statistic = "boxplot")
#'
#' # Customize ribbon appearance
#' lplot(df, measure ~ visit | group, baseline_value = 0,
#'       cluster_var = "subject_id", error_type = "band", 
#'       ribbon_alpha = 0.4, ribbon_fill = "lightblue")
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
  df, form, facet_form = NULL, cluster_var = "subject_id", baseline_value = NULL,
  xlab = "visit", ylab = "measure", ylab2 = "measure change",
  title = "Observed Values", title2 = "Change from Baseline",
  subtitle = "", subtitle2 = "", caption = "", caption2 = "",
  plot_type = "obs", error_type = "bar", jitter_width = 0.15, color_palette = NULL,
  clinical_mode = FALSE, treatment_colors = NULL, confidence_interval = NULL,
  summary_statistic = "mean", show_sample_sizes = TRUE,
  sample_size_opts = list(),
  theme = NULL,
  publication_ready = FALSE, statistical_annotations = FALSE,
  test_method = "parametric", p_adjust_method = "BH", cov_struct = "auto",
  reference_lines = NULL, ribbon_alpha = 0.2, ribbon_fill = NULL,
  contrast_display = NULL, auto_caption = TRUE
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
  
  if (!is.null(contrast_display)) {
    valid_cd <- c("footnote", "table", "panel")
    if (!contrast_display %in% valid_cd) {
      stop(sprintf(
        "Invalid contrast_display '%s'. Must be one of: %s",
        contrast_display, paste(valid_cd, collapse = ", ")
      ))
    }
  }

  # Validate test_method
  valid_test_methods <- c("parametric", "nonparametric", "mmrm")
  if (!test_method %in% valid_test_methods) {
    stop(sprintf("Invalid test_method '%s'. Must be one of: %s",
                 test_method, paste(valid_test_methods, collapse = ", ")))
  }
  if (test_method == "mmrm") {
    if (!requireNamespace("mmrm", quietly = TRUE)) {
      stop("Package 'mmrm' is required for test_method = 'mmrm'. ",
           "Install with: pak::pak('mmrm')")
    }
    if (!requireNamespace("emmeans", quietly = TRUE)) {
      stop("Package 'emmeans' is required for test_method = 'mmrm'. ",
           "Install with: pak::pak('emmeans')")
    }
  }

  # Validate p_adjust_method
  valid_p_methods <- c(
    "holm", "hochberg", "hommel", "bonferroni", "BH", "BY", "fdr", "none"
  )
  if (!p_adjust_method %in% valid_p_methods) {
    stop(sprintf("Invalid p_adjust_method '%s'. Must be one of: %s",
                 p_adjust_method, paste(valid_p_methods, collapse = ", ")))
  }

  # Validate confidence_interval. A value such as 95 (instead of 0.95)
  # otherwise reaches stats::qt() and yields NaN bounds silently.
  if (!is.null(confidence_interval)) {
    if (!is.numeric(confidence_interval) ||
        length(confidence_interval) != 1 ||
        is.na(confidence_interval) ||
        confidence_interval <= 0 || confidence_interval >= 1) {
      stop(sprintf(
        paste0("Invalid confidence_interval '%s'. Must be a single ",
               "number strictly between 0 and 1 (e.g. 0.95, not 95)."),
        paste(confidence_interval, collapse = ", ")
      ))
    }
  }

  # Mode defaults fill in only what the caller left unset. These use
  # missing() rather than unconditional assignment so that an explicit
  # show_sample_sizes = FALSE or statistical_annotations = FALSE is
  # honored: enabling a styling mode must not silently switch on
  # hypothesis testing.
  if (clinical_mode) {
    if (is.null(confidence_interval)) confidence_interval <- 0.95
    if (is.null(treatment_colors)) treatment_colors <- "standard"
    if (missing(show_sample_sizes)) show_sample_sizes <- TRUE
    if (missing(statistical_annotations)) statistical_annotations <- TRUE
    if (is.null(theme)) theme <- "nejm"
  }

  # Apply publication ready defaults
  if (publication_ready) {
    if (is.null(theme)) theme <- "nature"
    if (is.null(confidence_interval)) confidence_interval <- 0.95
    if (missing(show_sample_sizes)) show_sample_sizes <- TRUE
  }

  # Fall back to the plain theme once the modes have had their say.
  if (is.null(theme)) theme <- "bw"


  # Parse formulas
  parsed_form <- parse_formula(form)
  parsed_facet <- if (!is.null(facet_form)) parse_formula(facet_form) else NULL
  
  # Convert parsed_facet to plotting function format
  facet_spec <- NULL
  if (!is.null(parsed_facet)) {
    # For simple ~ variable formulas, treat as column facet
    if (parsed_facet$y == "" && !is.null(parsed_facet$x) && parsed_facet$x != "") {
      facet_spec <- list(facet_x = parsed_facet$x, facet_y = NULL)
    }
    # For row_var ~ col_var formulas, use both
    else if (!is.null(parsed_facet$y) && parsed_facet$y != "" && 
             !is.null(parsed_facet$x) && parsed_facet$x != "") {
      facet_spec <- list(facet_x = parsed_facet$x, facet_y = parsed_facet$y)
    }
    # For more complex facet formulas, use the facets component
    else if (!is.null(parsed_facet$facets) && length(parsed_facet$facets) > 0) {
      facet_spec <- list(
        facet_x = if (length(parsed_facet$facets) >= 1) parsed_facet$facets[1] else NULL,
        facet_y = if (length(parsed_facet$facets) >= 2) parsed_facet$facets[2] else NULL
      )
    }
  }
  
  if (is.null(baseline_value)) {
    baseline_value <- detect_baseline(df[[parsed_form$x]])
  }

  # Compute grouped statistics
  facet_variables <- NULL
  if (!is.null(facet_spec)) {
    facet_variables <- c(facet_spec$facet_x, facet_spec$facet_y)
    facet_variables <- facet_variables[!is.null(facet_variables)]
  }
  
  stats <- compute_stats(
    df = df,
    x_var = parsed_form$x,
    y_var = parsed_form$y,
    group_var = parsed_form$group,
    cluster_var = cluster_var,
    baseline_value = baseline_value,
    confidence_interval = confidence_interval,
    summary_statistic = summary_statistic,
    statistical_tests = statistical_annotations,
    facet_vars = facet_variables,
    test_method = test_method,
    p_adjust_method = p_adjust_method,
    cov_struct = cov_struct
  )
  
  # Prepare stats for change plot
  stats_change <- stats %>%
    dplyr::select(-bound_upper, -bound_lower) %>%
    dplyr::rename(
      bound_lower = bound_lower_change,
      bound_upper = bound_upper_change
    )
  attr(stats_change, "pairwise") <- attr(stats, "pairwise")

  contrast_data <- NULL
  if (!is.null(contrast_display) && statistical_annotations) {
    pw_attr <- attr(stats, "pairwise")
    if (!is.null(pw_attr) && nrow(pw_attr) > 0) {
      contrast_data <- pw_attr
    }
  }

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
    facet = facet_spec,
    color_palette = color_palette,
    reference_lines = reference_lines,
    show_sample_sizes = show_sample_sizes,
    statistical_annotations = statistical_annotations,
    use_boxplot = (summary_statistic == "boxplot"),
    ribbon_alpha = ribbon_alpha,
    ribbon_fill = ribbon_fill,
    bw_print = identical(theme, "bw"),
    sample_size_opts = sample_size_opts,
    contrast_display = if (identical(contrast_display, "footnote"))
      "footnote" else NULL,
    contrast_data = contrast_data,
    summary_statistic = summary_statistic,
    p_adjust_method = p_adjust_method,
    auto_caption = auto_caption
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
    facet = facet_spec,
    color_palette = color_palette,
    reference_lines = reference_lines,
    show_sample_sizes = show_sample_sizes,
    statistical_annotations = statistical_annotations,
    use_boxplot = (summary_statistic == "boxplot"),
    ribbon_alpha = ribbon_alpha,
    ribbon_fill = ribbon_fill,
    bw_print = identical(theme, "bw"),
    sample_size_opts = sample_size_opts,
    contrast_display = if (identical(contrast_display, "footnote"))
      "footnote" else NULL,
    contrast_data = contrast_data,
    summary_statistic = summary_statistic,
    p_adjust_method = p_adjust_method,
    auto_caption = auto_caption
  )

  # Apply publication theme and colors if specified
  if (!is.null(theme)) {
    # Apply theme
    pub_theme <- get_publication_theme(theme)
    fig_obs <- fig_obs + pub_theme
    fig_change <- fig_change + pub_theme
    
    if (theme == "bw" && is.null(color_palette)) {
      n_groups <- length(unique(stats$group))
      grey_vals <- grDevices::grey.colors(n_groups, start = 0, end = 0.6)

      bw_scales <- list(
        ggplot2::scale_color_manual(values = grey_vals),
        ggplot2::scale_fill_manual(values = grey_vals)
      )

      fig_obs <- fig_obs + bw_scales
      fig_change <- fig_change + bw_scales
    } else {
      # Apply matching journal colors if available
      journal_themes <- c(
        "nejm", "nature", "lancet", "jama", "science", "jco"
      )
      if (theme %in% journal_themes && is.null(color_palette)) {
        journal_colors <- clinical_colors(theme)

        fig_obs <- fig_obs +
          ggplot2::scale_color_manual(values = journal_colors) +
          ggplot2::scale_fill_manual(values = journal_colors)

        fig_change <- fig_change +
          ggplot2::scale_color_manual(values = journal_colors) +
          ggplot2::scale_fill_manual(values = journal_colors)
      }
    }
  }
  
  ss_table <- identical(
    sample_size_opts$position %||% "point", "table"
  )
  if (ss_table) {
    n_groups <- length(unique(stats$group))
    table_margin_b <- n_groups * 18 + 30
    table_theme <- ggplot2::theme(
      legend.position = "none",
      plot.margin = ggplot2::margin(
        t = 5.5, r = 5.5, b = table_margin_b, l = 40,
        unit = "pt"
      )
    )
    fig_obs <- fig_obs + table_theme
    fig_change <- fig_change + table_theme
  }

  # Build contrast table if requested
  table_plot <- NULL
  if (identical(contrast_display, "table") &&
      !is.null(contrast_data)) {
    table_plot <- .build_contrast_table_plot(
      contrast_data, parsed_form$x
    )
  }

  panel_plot <- NULL
  if (identical(contrast_display, "panel") &&
      !is.null(contrast_data)) {
    panel_plot <- .build_contrast_panel_plot(
      contrast_data, parsed_form$x
    )
  }

  # Return the requested plots
  if (plot_type == "obs") {
    result <- fig_obs
  } else if (plot_type == "change") {
    result <- fig_change
  } else if (plot_type == "both") {
    result <- fig_obs + fig_change +
      patchwork::plot_layout(ncol = 2, guides = "collect")
    if (!ss_table) {
      result <- result &
        ggplot2::theme(legend.position = "bottom")
    }
  }

  if (!is.null(table_plot)) {
    result <- result / table_plot +
      patchwork::plot_layout(heights = c(4, 1))
  }

  if (!is.null(panel_plot)) {
    result <- result / panel_plot +
      patchwork::plot_layout(heights = c(2, 1))
  }

  result
}
