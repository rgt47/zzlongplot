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
#' @param statistical_tests Logical. If TRUE, performs statistical comparisons.
#' @param facet_vars Character vector. Names of variables to use for faceting (optional).
#' @param test_method Character. Testing approach for group comparisons:
#'   "parametric" (t-test / ANOVA, the default), "nonparametric"
#'   (Wilcoxon rank-sum / Kruskal-Wallis), or "mmrm" (mixed model
#'   for repeated measures with emmeans contrasts; requires the
#'   mmrm and emmeans packages).
#' @param p_adjust_method Character. Multiple comparison correction passed
#'   to [stats::p.adjust()]. Default is "BH" (Benjamini-Hochberg). Use
#'   "none" to disable adjustment.
#' @param cov_struct Character. Covariance structure for MMRM. See
#'   [lplot()] for available options. Default is "auto".
#'
#' @import dplyr
#' @export
compute_stats <- function(df, x_var, y_var, group_var, cluster_var, baseline_value,
                         confidence_interval = NULL, summary_statistic = "mean",
                         statistical_tests = FALSE,
                         facet_vars = NULL, test_method = "parametric",
                         p_adjust_method = "BH", cov_struct = "auto") {
  # Parse group into individual components
  groups <- if (!is.null(group_var)) strsplit(group_var, "\\s*\\+\\s*")[[1]] else NULL
  
  # Validate that required columns are present in the data frame
  required_cols <- c(x_var, y_var, cluster_var, groups, facet_vars)
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
  
  # Group by x and any group variables (including facet variables)
  all_grouping_vars <- c(groups, facet_vars)
  if (!is.null(all_grouping_vars)) {
    group_cols <- c(all_grouping_vars, x_var)
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
        sample_size = sum(!is.na(.data[[y_var]])),
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
        sample_size = sum(!is.na(.data[[y_var]])),
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
        sample_size = sum(!is.na(.data[[y_var]])),
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
    result <- add_statistical_tests(
      result, df, x_var, y_var, groups[1], cluster_var,
      test_method = test_method, p_adjust_method = p_adjust_method,
      cov_struct = cov_struct
    )
  }
  
  return(result)
}

#' Add Statistical Tests to Summary Statistics
#'
#' @description
#' Internal function to add statistical comparisons between groups
#' at each timepoint. Dispatches to pointwise tests (parametric or
#' non-parametric) or a joint MMRM model with emmeans contrasts.
#'
#' @param stats_df Summary statistics data frame.
#' @param original_df Original data frame.
#' @param x_var X variable name.
#' @param y_var Y variable name.
#' @param group_var Group variable name.
#' @param cluster_var Cluster variable name.
#' @param test_method Character. Testing approach: "parametric"
#'   (t-test / ANOVA), "nonparametric" (Wilcoxon rank-sum /
#'   Kruskal-Wallis), or "mmrm" (mixed model for repeated measures
#'   with emmeans contrasts). Default is "parametric".
#' @param p_adjust_method Character. Method for multiple comparison
#'   correction. For pointwise tests, passed to [stats::p.adjust()].
#'   For MMRM, passed to emmeans as the `adjust` argument. Default
#'   is "BH". Use "none" to disable adjustment.
#' @param cov_struct Character. Covariance structure for MMRM.
#'   Default is "auto". See [lplot()] for options.
#'
#' @return Enhanced statistics data frame with p-values.
#'
#' @keywords internal
add_statistical_tests <- function(
  stats_df, original_df, x_var, y_var, group_var, cluster_var,
  test_method = "parametric", p_adjust_method = "BH",
  cov_struct = "auto"
) {

  if (identical(test_method, "mmrm")) {
    return(.add_mmrm_tests(
      stats_df, original_df, x_var, y_var,
      group_var, cluster_var, p_adjust_method, cov_struct
    ))
  }

  x_values <- unique(stats_df[[x_var]])
  groups <- unique(stats_df[[group_var]])

  stats_df$p_value <- NA
  stats_df$p_adj <- NA
  stats_df$significance <- NA

  nonparam <- identical(test_method, "nonparametric")

  pw_list <- list()

  for (x_val in x_values) {
    x_data <- original_df[original_df[[x_var]] == x_val, ]

    if (length(groups) == 2) {
      group1_data <- x_data[x_data[[group_var]] == groups[1], ][[y_var]]
      group2_data <- x_data[x_data[[group_var]] == groups[2], ][[y_var]]

      if (length(group1_data) > 1 && length(group2_data) > 1) {
        test_result <- tryCatch({
          if (nonparam) {
            stats::wilcox.test(group1_data, group2_data)
          } else {
            stats::t.test(group1_data, group2_data)
          }
        }, error = function(e) NULL)

        if (!is.null(test_result)) {
          stats_df[stats_df[[x_var]] == x_val, "p_value"] <-
            test_result$p.value
          est <- if (!nonparam) {
            diff(test_result$estimate)
          } else {
            NA_real_
          }
          ci <- if (!nonparam) test_result$conf.int else c(NA, NA)
          pw_list[[length(pw_list) + 1]] <- data.frame(
            x_val = x_val,
            group1 = as.character(groups[1]),
            group2 = as.character(groups[2]),
            estimate = est,
            lower_cl = ci[1],
            upper_cl = ci[2],
            p_value = test_result$p.value,
            stringsAsFactors = FALSE
          )
        }
      }

    } else if (length(groups) > 2) {
      test_data <- x_data[, c(y_var, group_var)]
      test_data <- test_data[complete.cases(test_data), ]

      if (nrow(test_data) > length(groups)) {
        omnibus_result <- tryCatch({
          if (nonparam) {
            stats::kruskal.test(
              stats::as.formula(paste(y_var, "~", group_var)),
              data = test_data
            )
          } else {
            stats::aov(
              stats::as.formula(paste(y_var, "~", group_var)),
              data = test_data
            )
          }
        }, error = function(e) NULL)

        if (!is.null(omnibus_result)) {
          omnibus_p <- if (nonparam) {
            omnibus_result$p.value
          } else {
            summary(omnibus_result)[[1]][["Pr(>F)"]][1]
          }
          stats_df[stats_df[[x_var]] == x_val, "p_value"] <- omnibus_p
        }

        gpairs <- utils::combn(as.character(groups), 2,
                               simplify = FALSE)
        for (gp in gpairs) {
          g1_data <- x_data[x_data[[group_var]] == gp[1], ][[y_var]]
          g2_data <- x_data[x_data[[group_var]] == gp[2], ][[y_var]]
          if (length(g1_data) > 1 && length(g2_data) > 1) {
            pw_res <- tryCatch({
              if (nonparam) {
                stats::wilcox.test(g1_data, g2_data)
              } else {
                stats::t.test(g1_data, g2_data)
              }
            }, error = function(e) NULL)
            if (!is.null(pw_res)) {
              est <- if (!nonparam) {
                diff(pw_res$estimate)
              } else {
                NA_real_
              }
              ci <- if (!nonparam) pw_res$conf.int else c(NA, NA)
              pw_list[[length(pw_list) + 1]] <- data.frame(
                x_val = x_val, group1 = gp[1], group2 = gp[2],
                estimate = est,
                lower_cl = ci[1],
                upper_cl = ci[2],
                p_value = pw_res$p.value,
                stringsAsFactors = FALSE
              )
            }
          }
        }
      }
    }
  }

  stats_df$p_adj <- stats::p.adjust(
    stats_df$p_value, method = p_adjust_method
  )
  stats_df$significance <- .p_to_stars(stats_df$p_adj)

  if (length(pw_list) > 0) {
    pw_df <- do.call(rbind, pw_list)
    pw_df$p_adj <- stats::p.adjust(pw_df$p_value,
                                    method = p_adjust_method)
    pw_df$significance <- .p_to_stars(pw_df$p_adj)
    attr(stats_df, "pairwise") <- pw_df
  }

  stats_df
}


#' Fit MMRM and extract emmeans contrasts
#'
#' Fits a mixed model for repeated measures using the mmrm package,
#' then extracts pairwise group contrasts at each timepoint via
#' emmeans.
#'
#' @inheritParams add_statistical_tests
#' @param p_adjust_method Adjustment method passed to emmeans.
#' @param cov_struct Covariance structure. "auto" selects
#'   unstructured for <= 10 timepoints, compound symmetry otherwise,
#'   with automatic fallback. Any mmrm-supported structure can be
#'   specified directly: "us", "cs", "ar1", "ar1h", "toep",
#'   "toeph", "ad", "sp_exp".
#'
#' @return Enhanced statistics data frame with MMRM-based p-values.
#'
#' @noRd
.add_mmrm_tests <- function(
  stats_df, original_df, x_var, y_var,
  group_var, cluster_var, p_adjust_method,
  cov_struct = "auto"
) {

  stats_df$p_value <- NA
  stats_df$p_adj <- NA
  stats_df$significance <- NA

  mdat <- original_df[
    complete.cases(original_df[, c(y_var, x_var, group_var, cluster_var)]),
  ]
  mdat[[".time"]] <- factor(mdat[[x_var]])
  mdat[[".group"]] <- factor(mdat[[group_var]])
  mdat[[".subject"]] <- factor(mdat[[cluster_var]])

  n_times <- nlevels(mdat[[".time"]])

  auto_mode <- identical(cov_struct, "auto")
  if (auto_mode) {
    cov_struct <- if (n_times <= 10) "us" else "cs"
  }

  .fit_mmrm <- function(cs) {
    cov_term <- paste0(cs, "(.time | .subject)")
    f <- stats::as.formula(
      paste(y_var, "~ .group * .time +", cov_term)
    )
    mmrm::mmrm(f, data = mdat)
  }

  fallback_order <- if (auto_mode && cov_struct == "us") {
    c("us", "toeph", "ar1h", "cs")
  } else if (auto_mode) {
    c(cov_struct, "cs")
  } else {
    cov_struct
  }

  fit <- NULL
  for (cs in fallback_order) {
    fit <- tryCatch(.fit_mmrm(cs), error = function(e) NULL)
    if (!is.null(fit)) {
      if (cs != fallback_order[1]) {
        message(
          "MMRM: ", fallback_order[1], " covariance failed, ",
          "using ", cs, " instead."
        )
      }
      break
    }
  }

  if (is.null(fit)) {
    warning(
      "MMRM: all covariance structures failed (",
      paste(fallback_order, collapse = ", "), "). ",
      "Returning results without statistical tests."
    )
    return(stats_df)
  }

  emm_adjust <- if (identical(p_adjust_method, "BH")) {
    "fdr"
  } else {
    p_adjust_method
  }

  emm <- emmeans::emmeans(fit, ~ .group | .time, nesting = NULL)
  pw_contrasts <- emmeans::contrast(emm, method = "pairwise",
                                     adjust = emm_adjust)
  contrast_df <- as.data.frame(
    summary(pw_contrasts, infer = c(TRUE, TRUE))
  )

  lcl_col <- grep("lower|lcl", names(contrast_df),
                   ignore.case = TRUE, value = TRUE)[1]
  ucl_col <- grep("upper|ucl", names(contrast_df),
                   ignore.case = TRUE, value = TRUE)[1]
  if (is.na(lcl_col)) lcl_col <- NULL
  if (is.na(ucl_col)) ucl_col <- NULL

  if (length(unique(stats_df[[group_var]])) > 2) {
    joint <- emmeans::joint_tests(fit, by = ".time")
    joint_df <- as.data.frame(joint)
  }

  x_values <- unique(stats_df[[x_var]])
  time_levels <- levels(mdat[[".time"]])
  groups <- unique(stats_df[[group_var]])
  n_groups <- length(groups)

  pw_list <- list()

  for (i in seq_along(time_levels)) {
    tl <- time_levels[i]
    xv <- x_values[match(tl, as.character(x_values))]
    if (is.na(xv)) next

    tp_contrasts <- contrast_df[contrast_df$.time == tl, ]
    if (nrow(tp_contrasts) == 0) next

    if (n_groups == 2) {
      p_val <- tp_contrasts$p.value[1]
      stats_df[stats_df[[x_var]] == xv, "p_value"] <- p_val
      stats_df[stats_df[[x_var]] == xv, "p_adj"] <- p_val
      pair_label <- as.character(tp_contrasts$contrast[1])
      pair_parts <- trimws(strsplit(pair_label, " - ")[[1]])
      pw_list[[length(pw_list) + 1]] <- data.frame(
        x_val = xv,
        group1 = pair_parts[1],
        group2 = pair_parts[2],
        estimate = tp_contrasts$estimate[1],
        lower_cl = if (!is.null(lcl_col))
          tp_contrasts[[lcl_col]][1] else NA_real_,
        upper_cl = if (!is.null(ucl_col))
          tp_contrasts[[ucl_col]][1] else NA_real_,
        p_value = p_val,
        p_adj = p_val,
        stringsAsFactors = FALSE
      )
    } else {
      omnibus_p <- if (exists("joint_df")) {
        jt_row <- joint_df[joint_df$.time == tl, ]
        if (nrow(jt_row) > 0) jt_row$p.value[1] else NA
      } else {
        NA
      }
      stats_df[stats_df[[x_var]] == xv, "p_value"] <- omnibus_p
      stats_df[stats_df[[x_var]] == xv, "p_adj"] <- omnibus_p

      for (r in seq_len(nrow(tp_contrasts))) {
        pair_label <- as.character(tp_contrasts$contrast[r])
        pair_parts <- trimws(strsplit(pair_label, " - ")[[1]])
        pw_list[[length(pw_list) + 1]] <- data.frame(
          x_val = xv,
          group1 = pair_parts[1],
          group2 = pair_parts[2],
          estimate = tp_contrasts$estimate[r],
          lower_cl = if (!is.null(lcl_col))
            tp_contrasts[[lcl_col]][r] else NA_real_,
          upper_cl = if (!is.null(ucl_col))
            tp_contrasts[[ucl_col]][r] else NA_real_,
          p_value = tp_contrasts$p.value[r],
          p_adj = tp_contrasts$p.value[r],
          stringsAsFactors = FALSE
        )
      }
    }
  }

  stats_df$significance <- .p_to_stars(stats_df$p_adj)

  if (length(pw_list) > 0) {
    pw_df <- do.call(rbind, pw_list)
    pw_df$significance <- .p_to_stars(pw_df$p_adj)
    attr(stats_df, "pairwise") <- pw_df
  }

  stats_df
}


#' Convert p-values to significance stars
#'
#' @param p Numeric vector of p-values.
#' @return Character vector of significance codes.
#' @noRd
.p_to_stars <- function(p) {
  ifelse(
    is.na(p), "",
    ifelse(p < 0.001, "***",
      ifelse(p < 0.01, "**",
        ifelse(p < 0.05, "*", "ns")))
  )
}


#' Detect Baseline Value from Visit Variable
#'
#' @description
#' Identifies a likely baseline value from a vector of visit codes.
#' For numeric vectors, returns the minimum value. For character/factor
#' vectors, matches against common baseline labels (case-insensitive):
#' 'baseline', 'bl', 'base', 'screening', 'scr', 'day 0', 'week 0',
#' 'visit 1', 'v1', 'pre'. Exactly one match must be found; zero or
#' multiple matches produce an error.
#'
#' @param x A vector of visit codes (numeric, character, or factor).
#'
#' @return A single baseline value.
#'
#' @keywords internal
detect_baseline <- function(x) {
  if (is.numeric(x)) {
    bl <- min(x, na.rm = TRUE)
    message(sprintf(
      "baseline_value not specified; using %s (minimum numeric value).", bl
    ))
    return(bl)
  }

  vals <- unique(as.character(x))
  patterns <- c(
    "^baseline$", "^bl$", "^base$",
    "^screening$", "^scr$",
    "^day\\s*0$", "^week\\s*0$", "^month\\s*0$",
    "^visit\\s*1$", "^v1$",
    "^pre$"
  )
  combined <- paste(patterns, collapse = "|")
  hits <- vals[grepl(combined, vals, ignore.case = TRUE)]

  if (length(hits) == 0) {
    stop(
      "baseline_value not specified and no common baseline code detected ",
      "in the visit variable. Please set baseline_value explicitly."
    )
  }
  if (length(hits) > 1) {
    stop(sprintf(
      "baseline_value not specified and multiple candidate baseline codes found: %s. ",
      paste(hits, collapse = ", ")
    ), "Please set baseline_value explicitly.")
  }

  message(sprintf("baseline_value not specified; using '%s'.", hits))
  hits
}