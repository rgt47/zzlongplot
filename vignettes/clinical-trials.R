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

## -----------------------------------------------------------------------------
# Simulate clinical trial data
set.seed(123)
n_subjects <- 60
n_visits <- 5

clinical_data <- expand.grid(
  SUBJID = paste0("001-", sprintf("%03d", 1:n_subjects)),
  AVISITN = 0:4  # Baseline + 4 follow-up visits
) %>%
  mutate(
    TRT01P = rep(c("Placebo", "Drug A 10mg", "Drug A 20mg"), length.out = n()),
    # Simulate efficacy score (higher = better)
    AVAL = case_when(
      TRT01P == "Placebo" ~ rnorm(n(), mean = 45 - AVISITN * 0.5, sd = 8),
      TRT01P == "Drug A 10mg" ~ rnorm(n(), mean = 45 - AVISITN * 1.5, sd = 7),
      TRT01P == "Drug A 20mg" ~ rnorm(n(), mean = 45 - AVISITN * 2.5, sd = 6)
    ),
    VISITN = AVISITN + 1,
    VISIT = case_when(
      AVISITN == 0 ~ "Baseline",
      AVISITN == 1 ~ "Week 4",
      AVISITN == 2 ~ "Week 8", 
      AVISITN == 3 ~ "Week 12",
      AVISITN == 4 ~ "Week 16"
    )
  ) %>%
  arrange(SUBJID, AVISITN)

head(clinical_data)

## ----basic-clinical-----------------------------------------------------------
# Basic clinical plot with observed values
p1 <- lplot(
  clinical_data,
  form = AVAL ~ AVISITN | TRT01P,
  cluster_var = "SUBJID",
  baseline_value = 0,
  xlab = "Visit Number",
  ylab = "Efficacy Score", 
  title = "Efficacy Over Time by Treatment Group"
)

print(p1)

## ----both-plots---------------------------------------------------------------
# Both observed and change plots
p2 <- lplot(
  clinical_data,
  form = AVAL ~ AVISITN | TRT01P,
  cluster_var = "SUBJID", 
  baseline_value = 0,
  plot_type = "both",
  xlab = "Visit Number",
  ylab = "Efficacy Score",
  ylab2 = "Change from Baseline",
  title = "Observed Efficacy",
  title2 = "Change from Baseline"
)

print(p2)

## ----clinical-mode------------------------------------------------------------
# Clinical mode with all clinical defaults
p3 <- lplot(
  clinical_data,
  form = AVAL ~ AVISITN | TRT01P,
  cluster_var = "SUBJID",
  baseline_value = 0,
  clinical_mode = TRUE,
  plot_type = "both",
  title = "Clinical Trial Results",
  title2 = "Change from Baseline"
)

print(p3)

## ----individual-features------------------------------------------------------
# Individual clinical features
p4 <- lplot(
  clinical_data,
  form = AVAL ~ AVISITN | TRT01P,
  cluster_var = "SUBJID",
  baseline_value = 0,
  treatment_colors = "standard",     # Clinical color scheme
  confidence_interval = 0.95,        # 95% CI
  show_sample_sizes = TRUE,          # Show N at each timepoint
  error_type = "bar",               # Error bars (common in clinical)
  title = "Efficacy Analysis - Individual Features"
)

print(p4)

## ----categorical-visits-------------------------------------------------------
# Using categorical visit names
p5 <- lplot(
  clinical_data,
  form = AVAL ~ VISIT | TRT01P,
  cluster_var = "SUBJID",
  baseline_value = "Baseline",
  clinical_mode = TRUE,
  plot_type = "both",
  xlab = "Study Visit",
  title = "Efficacy by Visit",
  title2 = "Change from Baseline"
)

print(p5)

## ----visit-windows------------------------------------------------------------
# Add some visit timing variation
clinical_data_windows <- clinical_data %>%
  mutate(
    VISIT_DAY = case_when(
      AVISITN == 0 ~ 0,
      AVISITN == 1 ~ round(rnorm(n(), 28, 3)),    # Target day 28 ± 3
      AVISITN == 2 ~ round(rnorm(n(), 56, 4)),    # Target day 56 ± 4  
      AVISITN == 3 ~ round(rnorm(n(), 84, 5)),    # Target day 84 ± 5
      AVISITN == 4 ~ round(rnorm(n(), 112, 6))    # Target day 112 ± 6
    )
  )

# Plot with visit windows (when this feature is implemented)
p6 <- lplot(
  clinical_data_windows,
  form = AVAL ~ VISIT_DAY | TRT01P,
  cluster_var = "SUBJID",
  baseline_value = 0,
  clinical_mode = TRUE,
  # visit_windows = list(
  #   "Month 1" = c(21, 35),
  #   "Month 2" = c(49, 63),
  #   "Month 3" = c(77, 91),
  #   "Month 4" = c(105, 119)
  # ),
  xlab = "Study Day",
  title = "Efficacy Over Time (Study Days)"
)

print(p6)

## ----fda-theme, eval=FALSE----------------------------------------------------
# # FDA regulatory theme (when implemented)
# p7 <- lplot(
#   clinical_data,
#   form = AVAL ~ AVISITN | TRT01P,
#   cluster_var = "SUBJID",
#   baseline_value = 0,
#   theme = "fda",
#   plot_type = "both",
#   title = "Figure 1.1: Primary Efficacy Endpoint",
#   title2 = "Figure 1.2: Change from Baseline",
#   caption = "ITT Population, LOCF imputation"
# )
# 
# print(p7)

## ----regulatory-export, eval=FALSE--------------------------------------------
# # Save in regulatory-friendly format
# save_clinical_plot(p7,
#   filename = "Figure_1_1_Primary_Efficacy.png",
#   width = 10, height = 6, dpi = 300,
#   title = "Figure 1.1",
#   footnote = "ITT Population; LOCF imputation applied"
# )

## ----cdisc-detection, eval=FALSE----------------------------------------------
# # Auto-detect CDISC variables and suggest formula
# suggestions <- suggest_clinical_vars(clinical_data)
# print(suggestions)
# #> Suggested formula: AVAL ~ AVISITN | TRT01P
# #> Cluster variable: SUBJID detected
# #> Baseline: AVISITN = 0

## ----clinical-colors, eval=FALSE----------------------------------------------
# # Get clinical color palette
# colors <- clinical_colors(type = "treatment", n = 3)
# print(colors)
# #> [1] "#7F7F7F" "#1F77B4" "#D62728"  # Grey, Blue, Red
# 
# # Use with custom styling
# p8 <- lplot(
#   clinical_data,
#   form = AVAL ~ AVISITN | TRT01P,
#   cluster_var = "SUBJID",
#   baseline_value = 0,
#   color_palette = colors
# )

## ----best-practice-both-------------------------------------------------------
# Best practice: Show both plots
lplot(clinical_data, AVAL ~ AVISITN | TRT01P, 
      cluster_var = "SUBJID", baseline_value = 0,
      plot_type = "both", clinical_mode = TRUE)

## ----best-practice-ci---------------------------------------------------------
# Best practice: 95% confidence intervals
lplot(clinical_data, AVAL ~ AVISITN | TRT01P,
      cluster_var = "SUBJID", baseline_value = 0, 
      confidence_interval = 0.95)

## ----best-practice-n----------------------------------------------------------
# Best practice: Show sample sizes
lplot(clinical_data, AVAL ~ AVISITN | TRT01P,
      cluster_var = "SUBJID", baseline_value = 0,
      show_sample_sizes = TRUE, clinical_mode = TRUE)

## ----best-practice-theme, eval=FALSE------------------------------------------
# # Best practice: Professional themes
# lplot(clinical_data, AVAL ~ AVISITN | TRT01P,
#       cluster_var = "SUBJID", baseline_value = 0,
#       theme = "fda", clinical_mode = TRUE)

