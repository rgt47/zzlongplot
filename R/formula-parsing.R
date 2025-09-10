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