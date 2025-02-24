#' @title Flexible Plotting of Observed and Change Values with Grouping and Faceting
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
#' @export
NULL

# Declare global variables to avoid R CMD check notes
#' @noRd
utils::globalVariables(c(
  "change", "standard_deviation", "sample_size", "change_sd", 
  "mean_value", "standard_error", "change_mean", "change_se", 
  "bound_lower", "bound_upper"
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
#' @param color_palette Optional vector of colors to use for groups. If NULL, 
#'   default ggplot colors are used.
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
#' @export
lplot <- function(
  df, form, facet_form = NULL, cluster_var = "subject_id", baseline_value = "baseline",
  xlab = "visit", ylab = "measure", ylab2 = "measure change",
  title = "Observed Values", title2 = "Change from Baseline",
  subtitle = "", subtitle2 = "", caption = "", caption2 = "",
  plot_type = "obs", error_type = "bar", color_palette = NULL
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
    baseline_value = baseline_value
  )
  
  # Prepare stats for change plot
  stats_change <- stats %>%
    dplyr::select(-bound_upper, -bound_lower) %>%
    dplyr::select(
      dplyr::everything(), 
      bound_lower = bound_lower_change, 
      bound_upper = bound_upper_change
    )
  
  # Generate the observed and change plots
  fig_obs <- generate_plot(
    stats = stats, 
    x_var = parsed_form$x, 
    y_var = "mean_value", 
    group_var = "group",
    error_type = error_type, 
    xlab = xlab, 
    ylab = ylab, 
    title = title, 
    subtitle = subtitle, 
    caption = caption, 
    facet = parsed_facet,
    color_palette = color_palette
  )
  
  fig_change <- generate_plot(
    stats = stats_change, 
    x_var = parsed_form$x, 
    y_var = "change_mean", 
    group_var = "group",
    error_type = error_type, 
    xlab = xlab, 
    ylab = ylab2, 
    title = title2, 
    subtitle = subtitle2, 
    caption = caption2, 
    facet = parsed_facet,
    color_palette = color_palette
  )
  
  # Return the requested plots
  if (plot_type == "obs") {
    return(fig_obs)
  } else if (plot_type == "change") {
    return(fig_change)
  } else if (plot_type == "both") {
    return(fig_obs + fig_change + patchwork::plot_layout(ncol = 2))
  }
}

#' Parse Formula Components for Longitudinal Plotting
#' 
#' @description
#' Parses an R formula object into its constituent components for use in longitudinal 
#' plotting functions. This function extracts variables for plotting observed values
#' and changes over time, with optional grouping and faceting specifications.
#' 
#' @param formula An R formula object. The formula can have the following forms:
#'   * `y ~ x` (simple x-y relationship)
#'   * `y ~ x | group` (with grouping)
#'   * `y ~ x | group ~ facet` (with grouping and single facet)
#'   * `y ~ x | group ~ facet1 + facet2` (with grouping and multiple facets)
#'
#' @return A list with four components:
#'   * `y`: character string, the dependent variable name (e.g., measure value)
#'   * `x`: character string, the independent variable name (typically time or visit)
#'   * `group`: character string or NULL, the grouping variable name if specified
#'   * `facets`: character vector or NULL, the faceting variable name(s) if specified
#'
#' @details
#' The function processes formula components in the following order:
#' 1. Extracts the y-variable (dependent variable) from the left-hand side of the first '~'
#' 2. Extracts the x-variable (typically time/visit) from before the '|' on the right-hand side
#' 3. If present, extracts the grouping variable after the '|'
#' 4. If present, extracts faceting variables after the second '~'
#' 
#' Multiple faceting variables should be separated by '+'. The function is designed
#' to work with both continuous and categorical x-variables, supporting the flexible
#' plotting capabilities of the zzlongplot package.
#'
#' @examples
#' # Simple longitudinal measurement
#' parse_formula(score ~ visit)
#' 
#' # With treatment group
#' parse_formula(score ~ visit | treatment)
#' 
#' # With treatment group and site facet
#' parse_formula(score ~ visit | treatment ~ site)
#' 
#' # With treatment group and multiple facets
#' parse_formula(score ~ visit | treatment ~ site + gender)
#' 
#' @export
parse_formula <- function(formula) {
  if (!inherits(formula, "formula")) {
    stop("Input must be a formula object")
  }
  
  # Convert the formula to a character string
  formula_text <- deparse(formula)
  
  # Split into parts using ~
  parts <- strsplit(formula_text, "~")[[1]]
  y_var <- trimws(parts[1])
  
  # Get the middle part (between first and second ~)
  middle_part <- trimws(parts[2])
  
  # Split middle part by |
  middle_parts <- strsplit(middle_part, "\\|")[[1]]
  x_var <- trimws(middle_parts[1])
  
  # Initialize group and facet variables
  group_var <- NULL
  facet_vars <- NULL
  
  # If there's a part after |, get group
  if (length(middle_parts) > 1) {
    group_var <- trimws(middle_parts[2])
  }
  
  # If there's a third part in original split, those are facets
  if (length(parts) > 2) {
    facet_part <- trimws(parts[3])
    facet_vars <- trimws(strsplit(facet_part, "\\+")[[1]])
  }
  
  # Return parsed components
  list(
    y = y_var,
    x = x_var,
    group = group_var,
    facets = facet_vars
  )
}

#' @title Compute Summary Statistics for Longitudinal Data
#' 
#' @description
#' Computes summary statistics for observed and change values in longitudinal data,
#' supporting both continuous and categorical x-axis variables.
#' 
#' @param df A data frame containing the data to be plotted.
#' @param x_var The independent variable (x-axis) name.
#' @param y_var The dependent variable (y-axis) name.
#' @param group_var Grouping variable for data (optional).
#' @param cluster_var Cluster variable for within-subject grouping (subject ID).
#' @param baseline_value Baseline value for calculating changes.
#' 
#' @return A data frame containing the computed statistics with columns:
#'   * Original x and group variables
#'   * mean_value: Mean of y values
#'   * change_mean: Mean of change from baseline
#'   * sample_size: Number of observations
#'   * standard_deviation: Standard deviation of y values
#'   * change_sd: Standard deviation of change values
#'   * standard_error: Standard error of mean
#'   * change_se: Standard error of change mean
#'   * bound_lower/bound_upper: Lower/upper bounds for error bars (mean ± SE)
#'   * bound_lower_change/bound_upper_change: Bounds for change value error bars
#'   * group: Factor combining all grouping variables
#'   * is_continuous: Boolean indicating if x is continuous
#' 
#' @examples
#' df <- data.frame(
#'   subject_id = rep(1:10, each = 3),
#'   visit = rep(c(0, 1, 2), times = 10),
#'   measure = rnorm(30, mean = 50, sd = 10),
#'   group = rep(c("A", "B"), length.out = 30)
#' )
#' # Compute statistics with visit as x variable, measure as y variable,
#' # grouped by treatment group, with subject_id as the cluster variable
#' stats <- compute_stats(df, "visit", "measure", "group", "subject_id", 0)
#' head(stats)
#' 
#' @export
compute_stats <- function(df, x_var, y_var, group_var, cluster_var, baseline_value) {
  # Parse group into individual components
  groups <- if (!is.null(group_var)) strsplit(group_var, "\\s*\\+\\s*")[[1]] else NULL
  
  # Validate that required columns are present in the data frame
  required_cols <- c(x_var, y_var, cluster_var, groups)
  required_cols <- required_cols[!is.null(required_cols)]
  missing_cols <- setdiff(required_cols, names(df))
  
  if (length(missing_cols) > 0) {
    stop(paste("The following required columns are missing from the data frame:", 
               paste(missing_cols, collapse = ", ")))
  }
  
  # Check if baseline_value exists in the x variable
  if (!baseline_value %in% df[[x_var]]) {
    stop(sprintf("The baseline value '%s' is not present in the x variable '%s'.", 
                 baseline_value, x_var))
  }
  
  # Check if the x variable is continuous
  is_continuous <- is.numeric(df[[x_var]])
  
  # Convert x to a factor if it is categorical
  if (!is_continuous) {
    df <- df %>%
      dplyr::mutate(
        dplyr::across(
          dplyr::all_of(x_var), 
          ~ factor(., levels = c(baseline_value, setdiff(unique(.), baseline_value)))
        )
      )
  }
  
  # Add the change column, grouped by the cluster_var
  df <- df %>%
    dplyr::group_by(.data[[cluster_var]]) %>%
    dplyr::mutate(
      change = .data[[y_var]] - .data[[y_var]][.data[[x_var]] == baseline_value][1]
    ) %>%
    dplyr::ungroup()
  
  # Group by x and any group variables
  if (!is.null(groups)) {
    group_cols <- c(groups, x_var)
    df <- df %>% dplyr::group_by(dplyr::across(dplyr::all_of(group_cols)))
  } else {
    df <- df %>% dplyr::group_by(.data[[x_var]])
  }
  
  # Summarize the data
  result <- df %>%
    dplyr::summarize(
      mean_value = mean(.data[[y_var]], na.rm = TRUE),
      change_mean = mean(change, na.rm = TRUE),
      sample_size = dplyr::n(),
      standard_deviation = stats::sd(.data[[y_var]], na.rm = TRUE),
      change_sd = stats::sd(change, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    dplyr::mutate(
      standard_error = standard_deviation / sqrt(sample_size),
      change_se = change_sd / sqrt(sample_size),
      bound_lower = mean_value - standard_error,
      bound_upper = mean_value + standard_error,
      bound_lower_change = change_mean - change_se,
      bound_upper_change = change_mean + change_se,
      group = if (!is.null(groups)) interaction(!!!syms(groups)) else "all",
      is_continuous = is_continuous
    )
  
  return(result)
}

#' Generate Custom ggplot2 Visualization for Longitudinal Data
#'
#' @description
#' Creates customizable visualizations using `ggplot2` for longitudinal data.
#' Supports dynamic axis scaling, optional grouping, faceting, and error visualization
#' with ribbons or error bars.
#'
#' @param stats A data frame containing the data to be plotted. Must include the columns 
#'   specified in `x_var`, `y_var`, and optionally `group_var`, `bound_lower`, 
#'   and `bound_upper` for error visualization.
#' @param x_var A string specifying the column name for the x-axis variable.
#' @param y_var A string specifying the column name for the y-axis variable.
#' @param group_var A string specifying the column name for the grouping variable.
#' @param error_type A string specifying the error type. Use `"bar"` for error bars or 
#'   `"band"` for ribbons.
#' @param xlab A string for the x-axis label.
#' @param ylab A string for the y-axis label.
#' @param title A string for the plot title.
#' @param subtitle A string for the plot subtitle.
#' @param caption A string for the plot caption.
#' @param facet A list specifying faceting variables. Use `facet_x` for columns 
#'   and `facet_y` for rows. Both are optional.
#' @param color_palette Optional vector of colors to use. If NULL, default ggplot 
#'   colors are used.
#'
#' @return A `ggplot` object representing the visualization.
#' 
#' @examples
#' library(ggplot2)
#' data <- data.frame(
#'   x = rep(1:10, each = 2),
#'   mean_value = c(1:10, 2:11),
#'   group = rep(c("A", "B"), 10),
#'   bound_lower = c(0.8 * (1:10), 1:10),
#'   bound_upper = c(1.2 * (1:10), 2:11),
#'   is_continuous = TRUE
#' )
#'
#' # Create a plot with error bands
#' plot <- generate_plot(
#'   stats = data,
#'   x_var = "x",
#'   y_var = "mean_value",
#'   group_var = "group",
#'   error_type = "band",
#'   xlab = "Time",
#'   ylab = "Measurement",
#'   title = "Example Plot"
#' )
#' print(plot)
#'
#' @export
generate_plot <- function(
  stats, 
  x_var, 
  y_var, 
  group_var = NULL, 
  error_type = "bar", 
  xlab = NULL, 
  ylab = NULL, 
  title = NULL, 
  subtitle = NULL, 
  caption = NULL, 
  facet = NULL,
  color_palette = NULL
) {
  # Set x-axis scale based on whether x is continuous
  x_scale <- if (stats$is_continuous[1]) {
    ggplot2::scale_x_continuous
  } else {
    ggplot2::scale_x_discrete
  }
  
  # Conditionally create the plot based on whether grouping is used
  if (!is.null(group_var) && group_var %in% names(stats)) {
    # Plot with grouping
    plot <- ggplot2::ggplot(
      stats, 
      ggplot2::aes(
        x = .data[[x_var]],
        y = .data[[y_var]],
        group = .data[[group_var]],
        color = .data[[group_var]],
        fill = .data[[group_var]]
      )
    )
  } else {
    # Plot without grouping
    plot <- ggplot2::ggplot(
      stats, 
      ggplot2::aes(
        x = .data[[x_var]],
        y = .data[[y_var]]
      )
    )
  }
  
  # Add line layer
  plot <- plot + ggplot2::geom_line()
  
  # Add error representation based on type
  if (error_type == "bar") {
    plot <- plot + ggplot2::geom_errorbar(
      ggplot2::aes(
        ymin = .data[["bound_lower"]], 
        ymax = .data[["bound_upper"]]
      ),
      width = 0.2, 
      color = "black", 
      alpha = 0.3
    )
  } else {
    plot <- plot + ggplot2::geom_ribbon(
      ggplot2::aes(
        ymin = .data[["bound_lower"]], 
        ymax = .data[["bound_upper"]],
        color = NULL
      ), 
      alpha = 0.2
    )
  }
  
  # Add labels
  plot <- plot + 
    ggplot2::xlab(xlab) +
    ggplot2::ylab(ylab) +
    ggplot2::labs(title = title, subtitle = subtitle, caption = caption)
  
  # Apply custom colors if provided
  if (!is.null(color_palette)) {
    plot <- plot + ggplot2::scale_color_manual(values = color_palette) +
      ggplot2::scale_fill_manual(values = color_palette)
  }
  
  # Add theme
  plot <- plot + 
    ggplot2::theme_bw() +
    ggplot2::theme(legend.position = "bottom")
  
  # Add faceting if specified
  if (!is.null(facet)) {
    plot <- plot + ggplot2::facet_grid(
      rows = if (!is.null(facet$facet_y)) ggplot2::vars(.data[[facet$facet_y]]) else NULL,
      cols = if (!is.null(facet$facet_x)) ggplot2::vars(.data[[facet$facet_x]]) else NULL
    )
  }
  
  return(plot)
}

#' Create a Color-Blind Friendly Palette
#'
#' @description
#' Generates a colorblind-friendly palette for use in plots.
#'
#' @param n The number of colors to generate. Default is 8.
#' @param type The type of palette. Options are "qualitative" (for categorical data), 
#'   "sequential" (for numeric data), or "diverging" (for data with a meaningful zero).
#'   Default is "qualitative".
#'
#' @return A character vector of hex color codes.
#'
#' @details
#' The function uses the ColorBrewer palettes through the RColorBrewer package.
#' For qualitative data, it uses the "Dark2" palette which is colorblind-friendly.
#' For sequential data, it uses the "Blues" palette.
#' For diverging data, it uses the "RdBu" palette.
#'
#' @examples
#' # Get 4 colors for categorical groups
#' colors <- get_colorblind_palette(4)
#'
#' # Use in a plot
#' df <- data.frame(
#'   x = 1:20,
#'   y = rnorm(20),
#'   group = rep(letters[1:4], each = 5)
#' )
#' library(ggplot2)
#' ggplot(df, aes(x, y, color = group)) +
#'   geom_line() +
#'   scale_color_manual(values = colors)
#'
#' @export
get_colorblind_palette <- function(n = 8, type = "qualitative") {
  # Check for RColorBrewer package
  if (!requireNamespace("RColorBrewer", quietly = TRUE)) {
    warning("RColorBrewer package not available. Using default ggplot2 colors.")
    return(NULL)
  }
  
  # Select palette type
  palette_name <- switch(
    type,
    qualitative = "Dark2",
    sequential = "Blues",
    diverging = "RdBu",
    "Dark2"  # Default to qualitative
  )
  
  # Get maximum colors for the palette
  max_colors <- RColorBrewer::brewer.pal.info[palette_name, "maxcolors"]
  
  # Generate colors
  if (n <= max_colors) {
    colors <- RColorBrewer::brewer.pal(n, palette_name)
  } else {
    # If more colors needed than available, interpolate
    colors <- grDevices::colorRampPalette(
      RColorBrewer::brewer.pal(max_colors, palette_name)
    )(n)
  }
  
  return(colors)
}
