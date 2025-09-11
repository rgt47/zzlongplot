## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 8,
  fig.height = 6,
  fig.align = "center",
  dpi = 150
)

## ----setup, message=FALSE, warning=FALSE--------------------------------------
library(zzlongplot)
library(ggplot2)
library(patchwork)

## ----sample-data--------------------------------------------------------------
# Create comprehensive clinical trial dataset
set.seed(123)
n_subjects <- 90
n_visits <- 4

demo_data <- data.frame(
  subject_id = rep(1:n_subjects, each = n_visits),
  visit = rep(c(0, 4, 8, 12), times = n_subjects),
  treatment = rep(c("Placebo", "Drug 10mg", "Drug 20mg"), each = n_visits * 30)
)

# Generate realistic clinical outcomes
for (subj in unique(demo_data$subject_id)) {
  subj_rows <- which(demo_data$subject_id == subj)
  treatment <- demo_data$treatment[subj_rows[1]]
  
  # Baseline efficacy score
  baseline <- 50 + rnorm(1, 0, 10)
  
  # Treatment-specific efficacy improvements
  if (treatment == "Placebo") {
    effects <- c(0, 2, 3, 4)  # Small placebo effect
  } else if (treatment == "Drug 10mg") {
    effects <- c(0, 8, 14, 18)  # Moderate dose effect
  } else {  # Drug 20mg
    effects <- c(0, 12, 22, 28)  # High dose effect
  }
  
  # Generate data with realistic variability
  demo_data$efficacy[subj_rows] <- baseline + effects + rnorm(4, 0, 8)
}

# Display data structure
str(demo_data)
head(demo_data, 12)

## ----nejm-theme, fig.width=10, fig.height=6-----------------------------------
p_nejm <- lplot(demo_data, 
               efficacy ~ visit | treatment,
               cluster_var = "subject_id",
               baseline_value = 0,
               theme = "nejm",
               title = "Clinical Efficacy Over Time",
               subtitle = "NEJM Theme with Official Colors",
               xlab = "Week",
               ylab = "Efficacy Score (points)")

p_nejm

## ----nature-theme, fig.width=10, fig.height=6---------------------------------
p_nature <- lplot(demo_data,
                 efficacy ~ visit | treatment,
                 cluster_var = "subject_id", 
                 baseline_value = 0,
                 theme = "nature",
                 title = "Clinical Efficacy Over Time",
                 subtitle = "Nature Theme with Official Colors",
                 xlab = "Week",
                 ylab = "Efficacy Score (points)")

p_nature

