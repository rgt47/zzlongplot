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
#'   * mean_value: Mean/median of y values (depending on summary_statistic)
#'   * change_mean: Mean/median of change from baseline
#'   * sample_size: Number of observations
#'   * standard_deviation: SD of y values (for mean) or IQR (for median)
#'   * change_sd: SD of change values (for mean) or IQR (for median)
#'   * standard_error: Standard error of mean/median
#'   * change_se: Standard error of change mean/median
#'   * bound_lower/bound_upper: Lower/upper bounds (CI/SE for mean, Q1/Q3 for median)
#'   * bound_lower_change/bound_upper_change: Bounds for change values
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
#' @param confidence_interval Numeric. Confidence level (e.g., 0.95 for 95% CI).
#'   If specified, calculates confidence intervals instead of standard error.
#' @param summary_statistic Character. Type of summary statistic: "mean" (mean ± CI/SE), 
#'   "mean_se" (mean ± SE), "median" (median + IQR), or "boxplot" (quartiles + whiskers).
#' @param show_sample_sizes Logical. If TRUE, includes sample sizes in output.
#' @param statistical_tests Logical. If TRUE, performs statistical comparisons.
#'
#' @import dplyr
#' @export
compute_stats <- function(df, x_var, y_var, group_var, cluster_var, baseline_value, 
                         confidence_interval = NULL, summary_statistic = "mean",
                         show_sample_sizes = FALSE, statistical_tests = FALSE) {
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
  
  # Summarize the data based on summary_statistic
  if (summary_statistic %in% c("mean", "mean_se")) {
    # Mean-based summaries
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
        change_se = change_sd / sqrt(sample_size)
      )
  } else if (summary_statistic == "median") {
    # Median-based summaries
    result <- df %>%
      dplyr::summarize(
        mean_value = stats::median(.data[[y_var]], na.rm = TRUE),
        change_mean = stats::median(change, na.rm = TRUE),
        sample_size = dplyr::n(),
        q25_value = stats::quantile(.data[[y_var]], 0.25, na.rm = TRUE),
        q75_value = stats::quantile(.data[[y_var]], 0.75, na.rm = TRUE),
        q25_change = stats::quantile(change, 0.25, na.rm = TRUE),
        q75_change = stats::quantile(change, 0.75, na.rm = TRUE),
        .groups = "drop"
      ) %>%
      dplyr::mutate(
        standard_deviation = q75_value - q25_value,  # IQR
        change_sd = q75_change - q25_change,         # IQR for change
        standard_error = standard_deviation / sqrt(sample_size),  # Approximate SE from IQR
        change_se = change_sd / sqrt(sample_size)
      )
  } else if (summary_statistic == "boxplot") {
    # Boxplot summaries (quartiles + whiskers)
    result <- df %>%
      dplyr::summarize(
        mean_value = stats::median(.data[[y_var]], na.rm = TRUE),  # Median as center
        change_mean = stats::median(change, na.rm = TRUE),
        sample_size = dplyr::n(),
        q25_value = stats::quantile(.data[[y_var]], 0.25, na.rm = TRUE),
        q75_value = stats::quantile(.data[[y_var]], 0.75, na.rm = TRUE),
        q25_change = stats::quantile(change, 0.25, na.rm = TRUE),
        q75_change = stats::quantile(change, 0.75, na.rm = TRUE),
        # Calculate whiskers (1.5 * IQR rule)
        iqr_value = q75_value - q25_value,
        iqr_change = q75_change - q25_change,
        whisker_lower = pmax(min(.data[[y_var]], na.rm = TRUE), q25_value - 1.5 * iqr_value),
        whisker_upper = pmin(max(.data[[y_var]], na.rm = TRUE), q75_value + 1.5 * iqr_value),
        whisker_lower_change = pmax(min(change, na.rm = TRUE), q25_change - 1.5 * iqr_change),
        whisker_upper_change = pmin(max(change, na.rm = TRUE), q75_change + 1.5 * iqr_change),
        .groups = "drop"
      ) %>%
      dplyr::mutate(
        standard_deviation = iqr_value,  # Use IQR as spread measure
        change_sd = iqr_change,
        standard_error = iqr_value / sqrt(sample_size),
        change_se = iqr_change / sqrt(sample_size)
      )
  }
  
  result <- result %>%
    dplyr::mutate(
      # Calculate bounds based on summary statistic type
      bound_lower = if (summary_statistic %in% c("mean", "mean_se")) {
        if (summary_statistic == "mean" && !is.null(confidence_interval)) {
          mean_value - stats::qt((1 + confidence_interval) / 2, df = sample_size - 1) * standard_error
        } else {
          mean_value - standard_error
        }
      } else if (summary_statistic == "median") {
        if (!is.null(confidence_interval)) {
          mean_value - 1.57 * standard_error  # Approximate CI for median
        } else {
          q25_value  # IQR
        }
      } else if (summary_statistic == "boxplot") {
        whisker_lower  # Whisker
      } else {
        mean_value - standard_error
      },
      bound_upper = if (summary_statistic %in% c("mean", "mean_se")) {
        if (summary_statistic == "mean" && !is.null(confidence_interval)) {
          mean_value + stats::qt((1 + confidence_interval) / 2, df = sample_size - 1) * standard_error
        } else {
          mean_value + standard_error
        }
      } else if (summary_statistic == "median") {
        if (!is.null(confidence_interval)) {
          mean_value + 1.57 * standard_error  # Approximate CI for median
        } else {
          q75_value  # IQR
        }
      } else if (summary_statistic == "boxplot") {
        whisker_upper  # Whisker
      } else {
        mean_value + standard_error
      },
      bound_lower_change = if (summary_statistic %in% c("mean", "mean_se")) {
        if (summary_statistic == "mean" && !is.null(confidence_interval)) {
          change_mean - stats::qt((1 + confidence_interval) / 2, df = sample_size - 1) * change_se
        } else {
          change_mean - change_se
        }
      } else if (summary_statistic == "median") {
        if (!is.null(confidence_interval)) {
          change_mean - 1.57 * change_se  # Approximate CI for median
        } else {
          q25_change  # IQR
        }
      } else if (summary_statistic == "boxplot") {
        whisker_lower_change  # Whisker
      } else {
        change_mean - change_se
      },
      bound_upper_change = if (summary_statistic %in% c("mean", "mean_se")) {
        if (summary_statistic == "mean" && !is.null(confidence_interval)) {
          change_mean + stats::qt((1 + confidence_interval) / 2, df = sample_size - 1) * change_se
        } else {
          change_mean + change_se
        }
      } else if (summary_statistic == "median") {
        if (!is.null(confidence_interval)) {
          change_mean + 1.57 * change_se  # Approximate CI for median
        } else {
          q75_change  # IQR
        }
      } else if (summary_statistic == "boxplot") {
        whisker_upper_change  # Whisker
      } else {
        change_mean + change_se
      },
      
      # Add confidence level info
      ci_level = if (!is.null(confidence_interval)) confidence_interval else NA,
      
      group = if (!is.null(groups)) interaction(!!!syms(groups)) else "all",
      is_continuous = is_continuous
    ) |>
    dplyr::filter(!is.na(mean_value))
  
  # Add statistical tests if requested
  if (statistical_tests && !is.null(groups) && length(groups) == 1) {
    result <- add_statistical_tests(result, df, x_var, y_var, groups[1], cluster_var)
  }
  
  return(result)
}

#' Add Statistical Tests to Summary Statistics
#'
#' @description
#' Internal function to add statistical comparisons between groups.
#'
#' @param stats_df Summary statistics data frame.
#' @param original_df Original data frame.
#' @param x_var X variable name.
#' @param y_var Y variable name. 
#' @param group_var Group variable name.
#' @param cluster_var Cluster variable name.
#'
#' @return Enhanced statistics data frame with p-values.
#'
#' @keywords internal
add_statistical_tests <- function(stats_df, original_df, x_var, y_var, group_var, cluster_var) {
  
  # Get unique x values and groups
  x_values <- unique(stats_df[[x_var]])
  groups <- unique(stats_df[[group_var]])
  
  # Initialize p-value columns
  stats_df$p_value <- NA
  stats_df$p_adj <- NA
  stats_df$significance <- NA
  
  # For each x value, perform group comparisons
  for (x_val in x_values) {
    # Get data for this x value
    x_data <- original_df[original_df[[x_var]] == x_val, ]
    
    if (length(groups) == 2) {
      # Two-group comparison (t-test)
      group1_data <- x_data[x_data[[group_var]] == groups[1], ][[y_var]]
      group2_data <- x_data[x_data[[group_var]] == groups[2], ][[y_var]]
      
      if (length(group1_data) > 1 && length(group2_data) > 1) {
        test_result <- tryCatch({
          stats::t.test(group1_data, group2_data)
        }, error = function(e) NULL)
        
        if (!is.null(test_result)) {
          # Add p-value to both groups for this x value
          stats_df[stats_df[[x_var]] == x_val, "p_value"] <- test_result$p.value
        }
      }
      
    } else if (length(groups) > 2) {
      # Multi-group comparison (ANOVA)
      test_data <- x_data[, c(y_var, group_var)]
      test_data <- test_data[complete.cases(test_data), ]
      
      if (nrow(test_data) > length(groups)) {
        test_result <- tryCatch({
          stats::aov(stats::as.formula(paste(y_var, "~", group_var)), data = test_data)
        }, error = function(e) NULL)
        
        if (!is.null(test_result)) {
          anova_summary <- summary(test_result)
          p_val <- anova_summary[[1]][["Pr(>F)"]][1]
          
          # Add p-value to all groups for this x value
          stats_df[stats_df[[x_var]] == x_val, "p_value"] <- p_val
        }
      }
    }
  }
  
  # Adjust p-values for multiple comparisons
  stats_df$p_adj <- stats::p.adjust(stats_df$p_value, method = "BH")
  
  # Add significance levels
  stats_df$significance <- ifelse(is.na(stats_df$p_adj), "",
                                 ifelse(stats_df$p_adj < 0.001, "***",
                                       ifelse(stats_df$p_adj < 0.01, "**",
                                             ifelse(stats_df$p_adj < 0.05, "*", "ns"))))
  
  return(stats_df)
}