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
#' @import dplyr
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
    ) |>
    dplyr::filter(!is.na(mean_value))
  
  return(result)
}