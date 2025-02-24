utils::globalVariables(c(
  "cng", "sd", "N", "cng_sd", "mn", "se", "cng_mn", "cng_se", "bl", "bu"
))
#' @title Flexible Plotting of Observed and Change Values with Grouping and Faceting
#'
#' @description These functions provide a flexible framework for generating observed
#' and change plots using a data frame, accommodating both continuous and 
#' categorical variables for the x-axis. They handle baseline (`zeroval`) 
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
#' @param df A data frame containing the data to be plotted.
#' @param form A formula specifying the variables for the x-axis, grouping, and 
#'   y-axis. Format: `y ~ x | group`.
#' @param facet_form A formula specifying the variables for faceting. Format: 
#'   `facet_y ~ facet_x`. Default is `NULL`.
#' @param clustervar A character string specifying the name of the cluster 
#'   variable for grouping within subjects.
#' @param zeroval The baseline value of the x variable, used to calculate changes.
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
#' @param ytype Type of plot to return. Options are `"obs"` (observed values), 
#'   `"cng"` (change values), or `"both"` for combined plots.
#' @param etype Type of error representation. Options are `"bar"` (error bars) or 
#'   `"band"` (error ribbons).
#'
#' @return A ggplot2 object or a combination of objects representing the requested 
#'   plots.
#'
#' @examples
#' # Continuous x variable
#' df <- data.frame(
#'   rid = rep(1:10, each = 3),
#'   visit = rep(c(0, 1, 2), times = 10),
#'   measure = rnorm(30, mean = 50, sd = 10),
#'   group = rep(c("A", "B"), length.out = 30)
#' )
#' lplot(df, measure ~ visit | group, zeroval = 0)
#'
#' # Categorical x variable
#' df <- data.frame(
#'   rid = rep(1:10, each = 3),
#'   visit = rep(c("baseline", "month1", "month2"), times = 10),
#'   measure = rnorm(30, mean = 50, sd = 10),
#'   group = rep(c("A", "B"), length.out = 30)
#' )
#' lplot(df, measure ~ visit | group, zeroval = "baseline")
#'
#' @import dplyr ggplot2 patchwork
#' @export
lplot <- function(
  df, form, facet_form = NULL, clustervar = "rid", zeroval = "bl",
  xlab = "visit", ylab = "measure", ylab2 = "measure change",
  title = "measure", title2 = "measure change",
  subtitle = "", subtitle2 = "", caption = "", caption2 = "",
  ytype = "obs", etype = "bar"
) {
  # Parse formulas
  parsed_form <- parse_formula(form)
  parsed_facet <- if (!is.null(facet_form)) parse_formula(facet_form) else NULL
  
  # Compute grouped statistics
  stats <- compute_stats(
    df, parsed_form$x, parsed_form$y, parsed_form$group, clustervar, zeroval
  )
  
 stats_cng = stats  |> select(-bu, -bl)  |> 
   select(everything(), bl = bl_cng, bu = bu_cng) 
  # Generate the observed and change plots
  fig_obs <- generate_plot(
    stats, parsed_form$x, "mn", "grp", etype, xlab, ylab, title, subtitle, caption, parsed_facet
  )
  fig_cng <- generate_plot(
    stats_cng, parsed_form$x, "cng_mn", "grp", etype, xlab, ylab2, title2, subtitle2, caption2, parsed_facet
  )
  
  # Return the requested plots
  if (ytype == "obs") {
    return(fig_obs)
  } else if (ytype == "cng") {
    return(fig_cng)
  } else if (ytype == "both") {
    return(fig_obs + fig_cng + patchwork::plot_layout(ncol = 2))
  } else {
    stop("Invalid `ytype`. Choose from 'obs', 'cng', or 'both'.")
  }
}

#' Parse Formula Components for Longitudinal Plotting
#' 
#' @description
#' Parses an R formula object into its constituent components for use in longitudinal 
#' plotting functions. This function is primarily used internally by `lplot()` to 
#' extract variables for plotting observed values and changes over time, with optional 
#' grouping and faceting specifications.
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
#' # Using more specific variable names
#' parse_formula(Blood.Pressure ~ Week | Drug.Group ~ Center + Age.Group)
#'
#' @seealso 
#' [lplot()], [compute_stats()], [generate_plot()]
#'
#' @section Package Internal:
#' This function is primarily used internally by [lplot()] but is exported
#' for use in custom applications of the formula parsing system.
#'
#' @keywords internal
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
#' Computes summary statistics for observed and change values, supporting both
#' continuous and categorical x-axis variables.
#' 
#' @param df A data frame containing the data to be plotted.
#' @param x The independent variable (x-axis).
#' @param y The dependent variable (y-axis).
#' @param group Grouping variable for data.
#' @param clustervar Cluster variable for within-subject grouping.
#' @param zeroval Baseline value for calculating changes.
#' 
#' @return A data frame containing the computed statistics.
#' 
#' @examples
#' df <- data.frame(
#'   rid = rep(1:10, each = 3),
#'   visit = rep(c(0, 1, 2), times = 10),
#'   measure = rnorm(30, mean = 50, sd = 10),
#'   group = rep(c("A", "B"), length.out = 30)
#' )
#' compute_stats(df, "visit", "measure", "group", "rid", 0)
#' 
#' @export
compute_stats <- function(df, x, y, group, clustervar, zeroval) {
  # Parse group into individual components
  groups <- if (!is.null(group)) strsplit(group, "\\s*\\+\\s*")[[1]] else NULL
  
  # Validate that required columns are present in the data frame
  required_cols <- c(x, y, clustervar, groups)
  missing_cols <- setdiff(required_cols, names(df))
  if (length(missing_cols) > 0) {
    stop(paste("The following required columns are missing from the data frame:", 
               paste(missing_cols, collapse = ", ")))
  }
  
  # Check if zeroval exists in the x variable
  if (!zeroval %in% df[[x]]) {
    stop(paste("The value of zeroval ('", zeroval, "') is not present in the x variable ('", x, "').", sep = ""))
  }
  
  # Check if the x variable is continuous
  is_continuous <- is.numeric(df[[x]])
  
  # Convert x to a factor if it is categorical
  df <- df %>%
    dplyr::mutate(
      across(all_of(x), ~ if (is_continuous) . else factor(., levels = c(zeroval, setdiff(unique(.), zeroval))))
    )
  
  # Add the change (cng) column, grouped by the clustervar
  df <- df %>%
    dplyr::group_by(.data[[clustervar]]) %>%
    dplyr::mutate(
      cng = .data[[y]] - .data[[y]][.data[[x]] == zeroval][1]
    )
  
  # Adjust grouping logic to handle multiple grouping variables
  if (!is.null(groups)) {
    df <- df %>%
      dplyr::group_by(across(all_of(c(groups, x))))
  } else {
    df <- df %>%
      dplyr::group_by(.data[[x]])
  }
  
  # Summarize the data
  df <- df %>%
    dplyr::summarize(
      mn = mean(.data[[y]], na.rm = TRUE),
      cng_mn = mean(cng, na.rm = TRUE),
      N = dplyr::n(),
      sd = sd(.data[[y]], na.rm = TRUE),
      cng_sd = sd(cng, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    dplyr::mutate(
      se = sd / sqrt(N),
      cng_se = cng_sd / sqrt(N),
      bl = mn - se,
      bu = mn + se,
      bl_cng = cng_mn - cng_se,
      bu_cng = cng_mn + cng_se,
      grp = if (!is.null(groups)) interaction(!!!syms(groups)) else NULL,
      is_continuous = is_continuous
    )
  return(df)
}
#' Generate Custom ggplot2 Visualization
#'
#' This function creates customizable visualizations using `ggplot2`. It supports 
#' dynamic axis scaling, optional grouping, faceting, and error visualization 
#' with ribbons or error bars.
#'
#' @param stats A data frame containing the data to be plotted. Must include the columns 
#'   specified in `x`, `y`, and optionally `grp`, `bl`, and `bu` for error visualization.
#' @param x A string specifying the column name for the x-axis variable.
#' @param y A string specifying the column name for the y-axis variable.
#' @param grp A string specifying the column name for the grouping variable (optional).
#' @param etype A string specifying the error type. Use `"bar"` for error bars or 
#'   any other value for ribbons.
#' @param xlab A string for the x-axis label.
#' @param ylab A string for the y-axis label.
#' @param title A string for the plot title.
#' @param subtitle A string for the plot subtitle.
#' @param caption A string for the plot caption.
#' @param facet A list specifying faceting variables. Use `facet_x` for columns 
#'   and `facet_y` for rows. Both are optional.
#'
#' @return A `ggplot` object.
#' @export
#'
#' @examples
#' library(ggplot2)
#' data <- data.frame(
#'   x = rep(1:10, each = 2),
#'   y = c(1:10, 2:11),
#'   grp = rep(c("A", "B"), 10),
#'   bl = c(0.8 * (1:10), 1:10),
#'   bu = c(1.2 * (1:10), 2:11),
#'   is_continuous = TRUE
#' )
#'
#' facet_settings <- list(facet_x = NULL, facet_y = "grp")
#'
#' plot <- generate_plot(
#'   stats = data,
#'   x = "x",
#'   y = "y",
#'   grp = "grp",
#'   etype = "ribbon",
#'   xlab = "X-axis Label",
#'   ylab = "Y-axis Label",
#'   title = "Plot Title",
#'   subtitle = "Subtitle Here",
#'   caption = "Caption Here",
#'   facet = facet_settings
#' )
#' print(plot)
generate_plot <- function(stats, x, y, grp, etype, xlab, ylab, title, subtitle, caption, facet) {
  scale_x <- if (stats$is_continuous[1]) {
    ggplot2::scale_x_continuous
  } else {
    ggplot2::scale_x_discrete
  }
  plot <- ggplot2::ggplot(stats, ggplot2::aes(
    x = .data[[x]], 
    y = .data[[y]], 
    group = if (!is.null(grp)) .data[[grp]] else NULL,
    color = if (!is.null(grp)) .data[[grp]] else NULL,
    fill = if (!is.null(grp)) .data[[grp]] else NULL
  )) +
    # ggplot2::geom_line(ggplot2::aes(linetype = if (!is.null(grp)) .data[[grp]] else NULL)) +
    ggplot2::geom_line(ggplot2::aes(linetype = 'solid')) +
    {
      if (etype == "bar") {
        ggplot2::geom_errorbar(ggplot2::aes(ymin = bl, ymax = bu), width = 0.2, color = "black", alpha = 0.3)
      } else {
        ggplot2::geom_ribbon(ggplot2::aes(ymin = bl, ymax = bu), alpha = 0.2)
      }
    } +
    ggplot2::xlab(xlab) +  # Fix: Explicitly set x-axis label
    ggplot2::ylab(ylab) +  # Explicitly set y-axis label
    ggplot2::labs(title = title, subtitle = subtitle, caption = caption) +
    ggplot2::theme_bw() +
    ggplot2::theme(legend.position = "bottom")
  if (!is.null(facet)) {
    plot <- plot + ggplot2::facet_grid(
      rows = if (!is.null(facet$facet_y)) vars(.data[[facet$facet_y]]) else NULL,
      cols = if (!is.null(facet$facet_x)) vars(.data[[facet$facet_x]]) else NULL
    )
  }
  plot
}
