## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 8,
  fig.height = 6
)

## ----setup--------------------------------------------------------------------
library(zzlongplot)
library(ggplot2)
library(dplyr)

## ----cdisc-data---------------------------------------------------------------
# Create CDISC-compliant dataset
set.seed(456)

cdisc_data <- expand.grid(
  USUBJID = paste0("STUDY001-001-", sprintf("%03d", 1:50)),
  AVISITN = c(0, 1, 2, 3, 4, 5)  # Baseline + 5 visits
) %>%
  mutate(
    # Subject identifier (shortened)
    SUBJID = sub("STUDY001-", "", USUBJID),
    
    # Visit information  
    VISIT = case_when(
      AVISITN == 0 ~ "Baseline",
      AVISITN == 1 ~ "Week 2", 
      AVISITN == 2 ~ "Week 4",
      AVISITN == 3 ~ "Week 8",
      AVISITN == 4 ~ "Week 12", 
      AVISITN == 5 ~ "Week 16"
    ),
    
    # Treatment assignments
    TRT01P = rep(c("Placebo", "Drug A 5mg", "Drug A 10mg", "Drug A 20mg"), 
                 length.out = n()),
    TRT01A = TRT01P,  # Assume planned = actual for simplicity
    
    # Population flags
    SAFFL = "Y",
    FASFL = "Y",
    
    # Analysis values - simulate depression rating scale (lower = better)
    AVAL = case_when(
      TRT01P == "Placebo" ~ pmax(0, rnorm(n(), mean = 20 + AVISITN * 0.5, sd = 5)),
      TRT01P == "Drug A 5mg" ~ pmax(0, rnorm(n(), mean = 20 - AVISITN * 1, sd = 4.5)),
      TRT01P == "Drug A 10mg" ~ pmax(0, rnorm(n(), mean = 20 - AVISITN * 2, sd = 4)),
      TRT01P == "Drug A 20mg" ~ pmax(0, rnorm(n(), mean = 20 - AVISITN * 3, sd = 4))
    ),
    
    # Parameter information
    PARAM = "Hamilton Depression Rating Scale Total Score",
    PARAMCD = "HAMDTOT"
  ) %>%
  # Calculate change from baseline
  group_by(USUBJID) %>%
  mutate(
    BASE = AVAL[AVISITN == 0],
    CHG = ifelse(AVISITN == 0, NA, AVAL - BASE),
    PCHG = ifelse(AVISITN == 0, NA, (AVAL - BASE) / BASE * 100)
  ) %>%
  ungroup() %>%
  arrange(USUBJID, AVISITN)

head(cdisc_data, 10)

## ----basic-cdisc--------------------------------------------------------------
# Automatic CDISC recognition
p1 <- lplot(
  cdisc_data,
  form = AVAL ~ AVISITN | TRT01P,
  cluster_var = "USUBJID",  # Uses USUBJID (standard)
  baseline_value = 0,
  xlab = "Analysis Visit",
  ylab = "HAMD Total Score",
  title = "Depression Severity Over Time"
)

print(p1)

## ----visit-names--------------------------------------------------------------
# Using CDISC visit names
p2 <- lplot(
  cdisc_data, 
  form = AVAL ~ VISIT | TRT01P,
  cluster_var = "USUBJID",
  baseline_value = "Baseline",
  xlab = "Study Visit", 
  ylab = "HAMD Total Score",
  title = "Depression Severity by Visit"
)

print(p2)

## ----change-baseline----------------------------------------------------------
# Using pre-calculated CHG values
cdisc_chg <- cdisc_data %>% filter(AVISITN > 0)  # Exclude baseline for CHG

p3 <- lplot(
  cdisc_chg,
  form = CHG ~ AVISITN | TRT01P,
  cluster_var = "USUBJID", 
  baseline_value = 1,  # First post-baseline visit
  xlab = "Analysis Visit",
  ylab = "Change from Baseline (HAMD)",
  title = "Change in Depression Severity"
)

print(p3)

## ----suggest-vars, eval=FALSE-------------------------------------------------
# # Auto-detect CDISC variables (when implemented)
# suggestions <- suggest_clinical_vars(cdisc_data)
# print(suggestions)
# 
# #> CDISC Variables Detected:
# #> ========================
# #> Subject ID: USUBJID (primary), SUBJID (alternate)
# #> Visit: AVISITN (numeric), VISIT (character)
# #> Analysis Value: AVAL
# #> Change from Baseline: CHG
# #> Treatment: TRT01P (planned), TRT01A (actual)
# #> Population Flags: SAFFL, FASFL
# #>
# #> Suggested Formula: AVAL ~ AVISITN | TRT01P
# #> Cluster Variable: USUBJID
# #> Baseline Visit: AVISITN = 0

## ----validate-cdisc, eval=FALSE-----------------------------------------------
# # Check CDISC compliance (when implemented)
# compliance <- validate_cdisc_data(cdisc_data)
# print(compliance)
# 
# #> CDISC Compliance Report:
# #> =======================
# #> ✓ Subject identifiers present (USUBJID, SUBJID)
# #> ✓ Visit variables present (AVISITN, VISIT)
# #> ✓ Analysis value present (AVAL)
# #> ✓ Treatment variable present (TRT01P)
# #> ✓ Population flags present (SAFFL, FASFL)
# #> ✓ Change from baseline calculated (CHG)
# #> ! Missing PCHG (percent change from baseline)
# #>
# #> Overall Compliance: 95%

## ----adam-required------------------------------------------------------------
# Add ADaM required variables
cdisc_adam <- cdisc_data %>%
  mutate(
    STUDYID = "STUDY001",
    SITEID = substr(SUBJID, 1, 3)  # Extract site from SUBJID
  )

# Verify required variables
required_vars <- c("USUBJID", "SUBJID", "STUDYID")
cat("Required ADaM variables present:", 
    all(required_vars %in% names(cdisc_adam)), "\n")

## ----adam-flags---------------------------------------------------------------
# Population-specific analysis
fasfl_data <- cdisc_adam %>% filter(FASFL == "Y")

p4 <- lplot(
  fasfl_data,
  form = AVAL ~ AVISITN | TRT01P, 
  cluster_var = "USUBJID",
  baseline_value = 0,
  clinical_mode = TRUE,
  title = "Primary Analysis (Full Analysis Set)",
  subtitle = "FASFL = 'Y' Population"
)

print(p4)

## ----adam-traceability, eval=FALSE--------------------------------------------
# # Add traceability variables (example)
# cdisc_trace <- cdisc_adam %>%
#   mutate(
#     # Source dataset references
#     SRCDOM = "QS",        # Source domain (Questionnaires)
#     SRCVAR = "QSSTRESN",  # Source variable
#     SRCSEQ = row_number() # Source sequence
#   )

## ----terminology--------------------------------------------------------------
# CDISC controlled terminology for treatments
treatment_mapping <- c(
  "Placebo" = "Placebo",
  "Drug A 5mg" = "COMPOUND-A 5 MG", 
  "Drug A 10mg" = "COMPOUND-A 10 MG",
  "Drug A 20mg" = "COMPOUND-A 20 MG"
)

cdisc_terminology <- cdisc_adam %>%
  mutate(
    TRT01P_STD = recode(TRT01P, !!!treatment_mapping)
  )

p5 <- lplot(
  cdisc_terminology,
  form = AVAL ~ AVISITN | TRT01P_STD,
  cluster_var = "USUBJID",
  baseline_value = 0,
  clinical_mode = TRUE,
  title = "Efficacy Analysis - Standard Terminology"
)

print(p5)

## ----missing-data-------------------------------------------------------------
# Add some missing data patterns
cdisc_missing <- cdisc_adam %>%
  mutate(
    # Simulate missing data (dropout pattern)
    AVAL = ifelse(
      AVISITN >= 3 & runif(n()) < 0.1 * (AVISITN - 2), 
      NA, 
      AVAL
    )
  )

# Plot showing missing data impact
p6 <- lplot(
  cdisc_missing,
  form = AVAL ~ AVISITN | TRT01P,
  cluster_var = "USUBJID", 
  baseline_value = 0,
  clinical_mode = TRUE,
  title = "Analysis with Missing Data",
  subtitle = "Observed Cases Only"
)

print(p6)

## ----standard-names-----------------------------------------------------------
# Good: CDISC standard names
good_plot <- lplot(
  cdisc_data,
  form = AVAL ~ AVISITN | TRT01P,
  cluster_var = "USUBJID",
  baseline_value = 0
)

# Avoid: Non-standard names
# bad_plot <- lplot(data, score ~ week | treatment, cluster_var = "id")

## ----population-flags---------------------------------------------------------
# Safety population analysis
safety_data <- cdisc_adam %>% filter(SAFFL == "Y")

# Full analysis set
fas_data <- cdisc_adam %>% filter(FASFL == "Y") 

cat("Safety Population N =", length(unique(safety_data$USUBJID)), "\n")
cat("Full Analysis Set N =", length(unique(fas_data$USUBJID)), "\n")

## ----parameters---------------------------------------------------------------
# Check parameter consistency
params <- cdisc_data %>%
  select(PARAM, PARAMCD) %>%
  distinct()

print(params)

# Use parameter in titles
p7 <- lplot(
  cdisc_data,
  form = AVAL ~ AVISITN | TRT01P,
  cluster_var = "USUBJID",
  baseline_value = 0,
  clinical_mode = TRUE,
  title = paste("Analysis of", unique(cdisc_data$PARAM))
)

print(p7)

## ----baseline-definition------------------------------------------------------
# Baseline should be clearly identified
baseline_info <- cdisc_data %>%
  filter(AVISITN == 0) %>%
  summarise(
    n_subjects = n_distinct(USUBJID),
    baseline_visit = unique(VISIT)
  )

cat("Baseline Definition:", baseline_info$baseline_visit, "\n")
cat("Subjects with Baseline:", baseline_info$n_subjects, "\n")

## ----quality-checks-----------------------------------------------------------
# Check for CDISC compliance issues
qc_results <- cdisc_data %>%
  summarise(
    # Check for missing required variables
    has_usubjid = "USUBJID" %in% names(.),
    has_avisitn = "AVISITN" %in% names(.),
    has_aval = "AVAL" %in% names(.),
    has_trt01p = "TRT01P" %in% names(.),
    
    # Check for data completeness
    missing_aval = sum(is.na(AVAL)),
    missing_chg = sum(is.na(CHG)),
    
    # Check visit structure
    baseline_visits = sum(AVISITN == 0),
    max_visit = max(AVISITN, na.rm = TRUE)
  )

print(qc_results)

## ----regulatory-checklist-----------------------------------------------------
# Regulatory submission checklist
checklist <- list(
  "USUBJID present" = "USUBJID" %in% names(cdisc_data),
  "AVISITN standardized" = is.numeric(cdisc_data$AVISITN),
  "Treatment coded" = "TRT01P" %in% names(cdisc_data),  
  "Population flags" = all(c("SAFFL", "FASFL") %in% names(cdisc_data)),
  "CHG calculated" = "CHG" %in% names(cdisc_data),
  "Parameters defined" = "PARAM" %in% names(cdisc_data)
)

# Print checklist
for(item in names(checklist)) {
  status <- ifelse(checklist[[item]], "✓", "✗")
  cat(status, item, "\n")
}

