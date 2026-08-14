#' @keywords internal
#' @aliases zzlongplot-package
#'
#' @details
#' The core workflow is a single call to [lplot()], which parses a
#' formula, computes summary statistics, and renders the plot:
#'
#' - [lplot()]: the main entry point. Produces the observed plot, the
#'   change-from-baseline plot, or both combined.
#' - [parse_formula()]: extracts response, time, grouping, and faceting
#'   variables from a `y ~ x | group` formula.
#' - [compute_stats()]: computes the per-timepoint summary statistics
#'   that drive the plot, optionally with hypothesis tests.
#' - [generate_plot()]: renders a statistics data frame as a ggplot.
#'
#' Clinical trial support is provided by [suggest_clinical_vars()],
#' [validate_cdisc_data()], and [get_cdisc_template()]. Journal and
#' regulatory styling is provided by [get_publication_theme()] and the
#' `theme_*()` family. Export helpers are [publication_panels()] and
#' [save_publication()].
#'
#' @import dplyr ggplot2 patchwork
#' @importFrom stats complete.cases setNames
"_PACKAGE"

# Declare global variables to avoid R CMD check notes for the bare
# column names used inside dplyr verbs.
utils::globalVariables(c(
  "change", "standard_deviation", "sample_size", "change_sd",
  "mean_value", "standard_error", "change_mean", "change_se",
  "bound_lower", "bound_upper", "bound_lower_change", "bound_upper_change",
  "q25_value", "q75_value", "q25_change", "q75_change",
  "iqr_value", "iqr_change", "whisker_lower", "whisker_upper",
  "whisker_lower_change", "whisker_upper_change"
))

# `%||%` entered base R in 4.4.0, but DESCRIPTION declares a floor of
# 4.1.0 and neither ggplot2 nor dplyr exports it. Define it here so the
# declared floor is honest.
`%||%` <- function(x, y) if (is.null(x)) y else x
