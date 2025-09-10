#' CDISC Variable Recognition and Utilities
#'
#' @description
#' Functions to automatically detect and work with CDISC (Clinical Data Interchange
#' Standards Consortium) variable naming conventions commonly used in clinical trials.
#'
#' @details
#' These functions help identify standard CDISC variable names and provide
#' suggestions for proper formula construction in longitudinal clinical trial analysis.

# CDISC Variable Lookup Tables
.cdisc_lookup <- list(
  
  # Subject identifiers
  subject_id = c(
    primary = c("USUBJID", "USUBJID"),
    secondary = c("SUBJID", "SUBJ", "PTNO", "PATIENT")
  ),
  
  # Visit variables
  visit = c(
    numeric = c("AVISITN", "VISITNUM", "VISIT_N", "VISITN"),
    character = c("AVISIT", "VISIT", "VISITC", "AVISITC")
  ),
  
  # Analysis values
  analysis_value = c(
    primary = c("AVAL", "AVALC"),
    secondary = c("VALUE", "RESULT", "SCORE", "MEASURE")
  ),
  
  # Change from baseline
  change = c(
    primary = c("CHG", "CHANGE"),
    percent = c("PCHG", "PCHANGE", "CHGPCT"),
    secondary = c("DIFF", "DELTA")
  ),
  
  # Treatment variables  
  treatment = c(
    planned = c("TRT01P", "TRTPN", "ARM", "ARMCD"),
    actual = c("TRT01A", "TRTAN", "ACTTRT", "ACTARM"),
    reference = c("TRT01PN", "TRT01AN")
  ),
  
  # Population flags
  population = c(
    safety = c("SAFFL", "SAF", "SAFETY"),
    efficacy = c("FASFL", "FAS", "ITT", "ITTFL", "EFFICACY"),
    per_protocol = c("PPSFL", "PP", "PERPROTFL")
  ),
  
  # Parameter information
  parameter = c(
    name = c("PARAM", "PARAMETER", "TEST"),
    code = c("PARAMCD", "PARAMCODE", "TESTCD")
  ),
  
  # Baseline values
  baseline = c(
    value = c("BASE", "BASELINE", "BL", "BLVAL"),
    flag = c("BASEFL", "BLFL", "BASELINE_FL")
  ),
  
  # Study information
  study = c(
    id = c("STUDYID", "STUDY", "PROTOCOL"),
    site = c("SITEID", "SITE", "CENTER", "INVESTIGATOR")
  )
)

#' Suggest Clinical Variables for Formula Construction
#'
#' @description
#' Automatically detects likely CDISC variables in a dataset and suggests
#' appropriate formula syntax for longitudinal plotting.
#'
#' @param data A data frame containing clinical trial data.
#' @param verbose Logical. If TRUE, provides detailed suggestions and warnings.
#'
#' @return A list containing:
#' \itemize{
#'   \item suggested_formula: Recommended formula for lplot
#'   \item detected_vars: List of detected CDISC variables by category
#'   \item cluster_var: Recommended cluster variable (subject ID)
#'   \item baseline_value: Detected baseline visit value
#'   \item warnings: Any data quality or compliance issues
#' }
#'
#' @examples
#' # Clinical trial dataset
#' clinical_data <- data.frame(
#'   USUBJID = paste0("001-", 1:20),
#'   AVISITN = rep(c(0, 1, 2, 3), 5),
#'   AVAL = rnorm(20),
#'   TRT01P = rep(c("Placebo", "Active"), 10)
#' )
#' 
#' suggestions <- suggest_clinical_vars(clinical_data)
#' print(suggestions$suggested_formula)
#' 
#' @export
suggest_clinical_vars <- function(data, verbose = TRUE) {
  
  if (!is.data.frame(data)) {
    stop("Input must be a data frame")
  }
  
  data_names <- names(data)
  detected <- list()
  warnings <- character()
  
  # Detect subject identifiers
  subject_matches <- sapply(.cdisc_lookup$subject_id, function(patterns) {
    intersect(patterns, data_names)
  }, simplify = FALSE)
  
  detected$subject_id <- unlist(subject_matches)
  primary_subject <- subject_matches$primary[1]
  
  if (is.na(primary_subject)) {
    primary_subject <- subject_matches$secondary[1]
    if (!is.na(primary_subject)) {
      warnings <- c(warnings, sprintf("Using non-standard subject ID '%s'. Consider USUBJID.", primary_subject))
    }
  }
  
  # Detect visit variables
  visit_matches <- sapply(.cdisc_lookup$visit, function(patterns) {
    intersect(patterns, data_names)
  }, simplify = FALSE)
  
  detected$visit <- unlist(visit_matches)
  primary_visit <- visit_matches$numeric[1]
  
  if (is.na(primary_visit)) {
    primary_visit <- visit_matches$character[1]
  }
  
  # Detect analysis values
  aval_matches <- sapply(.cdisc_lookup$analysis_value, function(patterns) {
    intersect(patterns, data_names)
  }, simplify = FALSE)
  
  detected$analysis_value <- unlist(aval_matches)
  primary_aval <- aval_matches$primary[1]
  
  if (is.na(primary_aval)) {
    primary_aval <- aval_matches$secondary[1]
    if (!is.na(primary_aval)) {
      warnings <- c(warnings, sprintf("Using non-standard analysis variable '%s'. Consider AVAL.", primary_aval))
    }
  }
  
  # Detect treatment variables
  trt_matches <- sapply(.cdisc_lookup$treatment, function(patterns) {
    intersect(patterns, data_names)
  }, simplify = FALSE)
  
  detected$treatment <- unlist(trt_matches)
  primary_trt <- trt_matches$planned[1]
  
  if (is.na(primary_trt)) {
    primary_trt <- trt_matches$actual[1]
    if (!is.na(primary_trt)) {
      warnings <- c(warnings, "Using actual treatment instead of planned. Consider TRT01P for ITT analysis.")
    }
  }
  
  # Detect change from baseline
  chg_matches <- sapply(.cdisc_lookup$change, function(patterns) {
    intersect(patterns, data_names)
  }, simplify = FALSE)
  
  detected$change <- unlist(chg_matches)
  
  # Detect baseline value
  baseline_value <- NULL
  if (!is.na(primary_visit) && primary_visit %in% data_names) {
    visit_values <- unique(data[[primary_visit]])
    
    # Common baseline patterns
    if (is.numeric(visit_values)) {
      baseline_candidates <- c(0, 1)
      baseline_value <- baseline_candidates[baseline_candidates %in% visit_values][1]
    } else {
      baseline_patterns <- c("baseline", "screening", "bl", "screen", "visit 1", "day 0", "week 0")
      baseline_matches <- visit_values[tolower(visit_values) %in% baseline_patterns]
      baseline_value <- baseline_matches[1]
    }
  }
  
  # Construct suggested formula
  suggested_formula <- NULL
  if (!is.na(primary_aval) && !is.na(primary_visit)) {
    if (!is.na(primary_trt)) {
      suggested_formula <- sprintf("%s ~ %s | %s", primary_aval, primary_visit, primary_trt)
    } else {
      suggested_formula <- sprintf("%s ~ %s", primary_aval, primary_visit)
    }
  }
  
  # Additional quality checks
  if (!is.na(primary_subject) && primary_subject %in% data_names) {
    n_subjects <- length(unique(data[[primary_subject]]))
    n_rows <- nrow(data)
    avg_obs_per_subject <- n_rows / n_subjects
    
    if (avg_obs_per_subject < 2) {
      warnings <- c(warnings, "Dataset appears to have limited longitudinal data (< 2 observations per subject).")
    }
  }
  
  # Check for population flags
  pop_matches <- sapply(.cdisc_lookup$population, function(patterns) {
    intersect(patterns, data_names)
  }, simplify = FALSE)
  
  detected$population <- unlist(pop_matches)
  
  if (length(detected$population) == 0) {
    warnings <- c(warnings, "No population analysis flags detected. Consider adding SAFFL, FASFL.")
  }
  
  # Prepare return object
  result <- list(
    suggested_formula = suggested_formula,
    detected_vars = detected,
    cluster_var = primary_subject,
    baseline_value = baseline_value,
    warnings = warnings
  )
  
  # Print suggestions if verbose
  if (verbose) {
    cat("CDISC Variable Detection Results:\n")
    cat("=================================\n\n")
    
    if (!is.null(suggested_formula)) {
      cat("Suggested Formula:", suggested_formula, "\n")
    } else {
      cat("Could not construct formula. Missing required variables.\n")
    }
    
    if (!is.na(primary_subject)) {
      cat("Cluster Variable:", primary_subject, "\n")
    }
    
    if (!is.null(baseline_value)) {
      cat("Baseline Value:", baseline_value, "\n")
    }
    
    cat("\nDetected Variables:\n")
    for (category in names(detected)) {
      if (length(detected[[category]]) > 0) {
        cat(sprintf("  %s: %s\n", category, paste(detected[[category]], collapse = ", ")))
      }
    }
    
    if (length(warnings) > 0) {
      cat("\nWarnings:\n")
      for (w in warnings) {
        cat(sprintf("  ! %s\n", w))
      }
    }
    
    cat("\n")
  }
  
  return(invisible(result))
}

#' Validate CDISC Data Compliance
#'
#' @description
#' Checks a clinical dataset for compliance with CDISC standards and
#' provides recommendations for improvement.
#'
#' @param data A data frame containing clinical trial data.
#' @param required_vars Character vector of variables that must be present.
#' @param check_population_flags Logical. Whether to check for population flags.
#'
#' @return A list containing compliance score and recommendations.
#'
#' @examples
#' validation <- validate_cdisc_data(clinical_data)
#' print(validation$compliance_score)
#' 
#' @export
validate_cdisc_data <- function(data, 
                                 required_vars = c("USUBJID", "AVISITN", "AVAL"),
                                 check_population_flags = TRUE) {
  
  if (!is.data.frame(data)) {
    stop("Input must be a data frame")
  }
  
  data_names <- names(data)
  issues <- character()
  recommendations <- character()
  score_components <- list()
  
  # Check required variables
  missing_required <- setdiff(required_vars, data_names)
  if (length(missing_required) > 0) {
    issues <- c(issues, sprintf("Missing required variables: %s", 
                               paste(missing_required, collapse = ", ")))
    score_components$required_vars <- 0
  } else {
    score_components$required_vars <- 25
  }
  
  # Check subject identifier standards
  if ("USUBJID" %in% data_names) {
    score_components$subject_id <- 20
  } else if ("SUBJID" %in% data_names) {
    score_components$subject_id <- 15
    recommendations <- c(recommendations, "Consider using USUBJID for unique subject identification")
  } else {
    score_components$subject_id <- 0
    issues <- c(issues, "No standard subject identifier found")
  }
  
  # Check visit variables
  if (any(c("AVISITN", "VISITNUM") %in% data_names)) {
    score_components$visit_vars <- 15
  } else if (any(c("VISIT", "AVISIT") %in% data_names)) {
    score_components$visit_vars <- 10
    recommendations <- c(recommendations, "Consider adding numeric visit variable (AVISITN)")
  } else {
    score_components$visit_vars <- 0
    issues <- c(issues, "No standard visit variable found")
  }
  
  # Check analysis values
  if ("AVAL" %in% data_names) {
    score_components$analysis_values <- 15
  } else {
    score_components$analysis_values <- 0
    issues <- c(issues, "No standard analysis value variable (AVAL) found")
  }
  
  # Check change from baseline
  if (any(c("CHG", "CHANGE") %in% data_names)) {
    score_components$change_vars <- 10
  } else {
    score_components$change_vars <- 5
    recommendations <- c(recommendations, "Consider pre-calculating change from baseline (CHG)")
  }
  
  # Check treatment variables
  if (any(c("TRT01P", "ARM") %in% data_names)) {
    score_components$treatment_vars <- 10
  } else {
    score_components$treatment_vars <- 0
    issues <- c(issues, "No standard treatment variable found")
  }
  
  # Check population flags
  if (check_population_flags) {
    pop_flags <- intersect(c("SAFFL", "FASFL", "PPSFL"), data_names)
    if (length(pop_flags) >= 2) {
      score_components$population_flags <- 5
    } else if (length(pop_flags) == 1) {
      score_components$population_flags <- 3
      recommendations <- c(recommendations, "Consider adding additional population flags (SAFFL, FASFL)")
    } else {
      score_components$population_flags <- 0
      recommendations <- c(recommendations, "Add population analysis flags (SAFFL, FASFL, PPSFL)")
    }
  }
  
  # Calculate overall compliance score
  max_score <- sum(c(25, 20, 15, 15, 10, 10, 5))  # Total possible points
  actual_score <- sum(unlist(score_components), na.rm = TRUE)
  compliance_percentage <- round((actual_score / max_score) * 100)
  
  # Prepare result
  result <- list(
    compliance_score = compliance_percentage,
    score_breakdown = score_components,
    issues = issues,
    recommendations = recommendations,
    max_possible_score = max_score,
    actual_score = actual_score
  )
  
  return(result)
}

#' Get CDISC Variable Suggestions for Common Scenarios
#'
#' @description
#' Provides template variable names for common clinical trial analysis scenarios.
#'
#' @param scenario Character string specifying the analysis scenario.
#'   Options: "efficacy", "safety", "pk" (pharmacokinetics), "biomarker".
#'
#' @return Character vector of recommended variable names.
#'
#' @examples
#' efficacy_vars <- get_cdisc_template("efficacy")
#' safety_vars <- get_cdisc_template("safety")
#' 
#' @export
get_cdisc_template <- function(scenario = "efficacy") {
  
  templates <- list(
    
    efficacy = c(
      "USUBJID",    # Unique subject ID
      "SUBJID",     # Subject ID
      "STUDYID",    # Study ID
      "AVISITN",    # Analysis visit number
      "AVISIT",     # Analysis visit name  
      "AVAL",       # Analysis value
      "CHG",        # Change from baseline
      "BASE",       # Baseline value
      "TRT01P",     # Planned treatment
      "FASFL",      # Full analysis set flag
      "PARAM",      # Parameter name
      "PARAMCD"     # Parameter code
    ),
    
    safety = c(
      "USUBJID", "SUBJID", "STUDYID",
      "AVISITN", "AVISIT",
      "AVAL", "CHG", "BASE",
      "TRT01A",     # Actual treatment
      "SAFFL",      # Safety population flag
      "PARAM", "PARAMCD",
      "ATOXGR",     # Toxicity grade
      "AESEV"       # Adverse event severity
    ),
    
    pk = c(
      "USUBJID", "SUBJID", "STUDYID", 
      "AVISITN", "AVISIT",
      "AVAL", "AVALC",  # Analysis value (numeric and character)
      "TRT01P", "TRT01A",
      "PCSFL",      # PK concentration set flag
      "PARAM", "PARAMCD",
      "PCORRES",    # Original result
      "PCSTRESC",   # Standardized result
      "PCDTC"       # Date/time of collection
    ),
    
    biomarker = c(
      "USUBJID", "SUBJID", "STUDYID",
      "AVISITN", "AVISIT", 
      "AVAL", "CHG", "BASE",
      "TRT01P",
      "FASFL",
      "PARAM", "PARAMCD",
      "LBSTRESC",   # Lab standardized result
      "LBORRES",    # Lab original result  
      "LBNRIND",    # Normal range indicator
      "LBSTNRLO",   # Reference range lower limit
      "LBSTNRHI"    # Reference range upper limit
    )
  )
  
  if (!scenario %in% names(templates)) {
    stop(sprintf("Unknown scenario '%s'. Available: %s", 
                 scenario, paste(names(templates), collapse = ", ")))
  }
  
  return(templates[[scenario]])
}