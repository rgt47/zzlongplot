## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(
  echo = TRUE,
  fig.width = 10, 
  fig.height = 6,
  warning = FALSE,
  message = FALSE,
  comment = "#>"
)

# Load required packages
library(zzlongplot)
library(dplyr)
library(ggplot2)
library(patchwork)

# Resolve namespace conflicts by explicitly preferring dplyr functions
# This helps avoid function naming conflicts like filter(), summarize(), etc.
if(requireNamespace("conflicted", quietly = TRUE)) {
  conflicted::conflict_prefer("filter", "dplyr")
  conflicted::conflict_prefer("lag", "dplyr")
  conflicted::conflict_prefer("summarize", "dplyr")
  conflicted::conflict_prefer("summarise", "dplyr")
} else {
  # If conflicted package is not available, we'll use explicit namespace references
  # in the code (dplyr::filter, etc.)
}

## ----create_continuous_data---------------------------------------------------
# Set seed for reproducibility
set.seed(123)

# Create sample data with continuous time points
continuous_data <- data.frame(
  subject_id = rep(1:50, each = 4),
  visit_time = rep(c(0, 4, 8, 12), times = 50),  # Weeks from baseline
  outcome = NA,  # Will fill this with simulated data
  group = rep(c("Treatment", "Placebo"), each = 2, length.out = 200)
)

# Generate outcome data with treatment effect increasing over time
for (subject in unique(continuous_data$subject_id)) {
  subject_rows <- which(continuous_data$subject_id == subject)
  baseline <- 50 + rnorm(1, 0, 5)  # Baseline value with some variation
  
  is_treatment <- continuous_data$group[subject_rows[1]] == "Treatment"
  
  # Treatment effect increases over time, placebo has minimal effect
  effect_size <- if (is_treatment) c(0, 3, 7, 12) else c(0, 1, 1.5, 2)
  
  # Add individual trajectory with some random noise
  continuous_data$outcome[subject_rows] <- baseline + effect_size + rnorm(4, 0, 3)
}

# Look at the first few rows of our data
head(continuous_data, 8)

## ----create_categorical_data--------------------------------------------------
# Create sample data with categorical time points
categorical_data <- data.frame(
  subject_id = rep(1:50, each = 4),
  visit = rep(c("Baseline", "Month1", "Month3", "Month6"), times = 50),
  score = NA,  # Will fill this with simulated data
  treatment = rep(c("Drug A", "Drug B", "Placebo"), length.out = 50, each = 4),
  site = rep(c("Site 1", "Site 2"), length.out = 200)  # For faceting examples
)

# Generate score data with different treatment effects
for (subject in unique(categorical_data$subject_id)) {
  subject_rows <- which(categorical_data$subject_id == subject)
  baseline <- 25 + rnorm(1, 0, 3)  # Baseline value
  
  # Different effects for different treatments
  treatment_type <- categorical_data$treatment[subject_rows[1]]
  
  if (treatment_type == "Drug A") {
    effect_size <- c(0, 5, 8, 10)  # Strong effect
  } else if (treatment_type == "Drug B") {
    effect_size <- c(0, 4, 5, 7)   # Moderate effect
  } else {
    effect_size <- c(0, 2, 2, 3)   # Weak effect (placebo)
  }
  
  # Add individual trajectory with some random noise
  categorical_data$score[subject_rows] <- baseline + effect_size + rnorm(4, 0, 2)
}

# Look at the first few rows of our data
head(categorical_data, 8)

## ----basic_plot---------------------------------------------------------------
# Basic plot showing outcome over time
lplot(continuous_data, 
      form = outcome ~ visit_time,
      cluster_var = "subject_id",
      baseline_value = 0,
      title = "Outcome Over Time",
      xlab = "Weeks",
      ylab = "Outcome Measure")

## ----group_plot---------------------------------------------------------------
# Plot with grouping by treatment
lplot(continuous_data, 
      form = outcome ~ visit_time | group,
      cluster_var = "subject_id",
      baseline_value = 0,
      title = "Treatment Effect Over Time",
      xlab = "Weeks",
      ylab = "Outcome Measure")

## ----change_plot--------------------------------------------------------------
# Plot both observed values and change from baseline
lplot(continuous_data, 
      form = outcome ~ visit_time | group,
      cluster_var = "subject_id",
      baseline_value = 0,
      plot_type = "both",
      title = "Observed Outcomes",
      title2 = "Change from Baseline",
      xlab = "Weeks",
      ylab = "Outcome Measure",
      ylab2 = "Change in Outcome")

## ----categorical_plot---------------------------------------------------------
# Plot with categorical time points
lplot(categorical_data, 
      form = score ~ visit | treatment,
      cluster_var = "subject_id",
      baseline_value = "Baseline",
      title = "Treatment Comparison",
      xlab = "Visit",
      ylab = "Score")

## ----facet_plot---------------------------------------------------------------
# Plot with faceting by site
lplot(categorical_data, 
      form = score ~ visit | treatment,
      facet_form = ~ site,
      cluster_var = "subject_id",
      baseline_value = "Baseline",
      title = "Treatment Comparison by Site",
      xlab = "Visit",
      ylab = "Score")

## ----error_bands--------------------------------------------------------------
# Using confidence bands instead of error bars
lplot(categorical_data, 
      form = score ~ visit | treatment,
      cluster_var = "subject_id",
      baseline_value = "Baseline",
      error_type = "band",
      title = "Treatment Comparison with Confidence Bands",
      xlab = "Visit",
      ylab = "Score")

## ----color_palette------------------------------------------------------------
# Define a colorblind-friendly palette manually
# These colors are based on the ColorBrewer "Dark2" palette
custom_colors <- c("#1B9E77", "#D95F02", "#7570B3")

# Apply custom colors to the plot
lplot(categorical_data, 
      form = score ~ visit | treatment,
      cluster_var = "subject_id",
      baseline_value = "Baseline",
      color_palette = custom_colors,
      title = "Treatment Comparison with Custom Colors",
      xlab = "Visit",
      ylab = "Score")

## ----multiple_groups----------------------------------------------------------
# First, add a secondary grouping variable to our data
categorical_data$gender <- rep(c("Female", "Male"), length.out = nrow(categorical_data))

# Plot with two grouping variables
lplot(categorical_data, 
      form = score ~ visit | treatment + gender,
      cluster_var = "subject_id",
      baseline_value = "Baseline",
      title = "Treatment by Gender Interaction",
      xlab = "Visit",
      ylab = "Score")

## ----multi_facet--------------------------------------------------------------
# Add another variable for faceting
categorical_data$age_group <- rep(c("Young", "Middle", "Elder"), length.out = nrow(categorical_data))

# Create a plot with multi-dimensional faceting
lplot(categorical_data, 
      form = score ~ visit | treatment,
      facet_form = age_group ~ site,
      cluster_var = "subject_id",
      baseline_value = "Baseline",
      title = "Treatment Effects Across Age Groups and Sites",
      xlab = "Visit",
      ylab = "Score")

## ----custom_baseline----------------------------------------------------------
# Using a non-zero time point as baseline for continuous data
lplot(continuous_data, 
      form = outcome ~ visit_time | group,
      cluster_var = "subject_id",
      baseline_value = 4,  # Using week 4 as baseline instead of week 0
      plot_type = "both",
      title = "Outcomes (Week 4 as Baseline)",
      title2 = "Change from Week 4",
      xlab = "Weeks",
      ylab = "Outcome Measure",
      ylab2 = "Change from Week 4")

## ----clinical_trial-----------------------------------------------------------
# Create a clinical trial dataset
clinical_data <- data.frame(
  subject_id = rep(1:60, each = 5),
  visit_week = rep(c(0, 2, 4, 8, 12), times = 60),
  pain_score = NA,
  responder = NA,  # Will define responders as those with ≥30% improvement
  treatment = rep(c("Active", "Control"), each = 5, length.out = 300),
  site = rep(c("Site A", "Site B", "Site C"), length.out = 300)
)

# Generate pain scores (0-10 scale, higher = worse pain)
for (subject in unique(clinical_data$subject_id)) {
  subject_rows <- which(clinical_data$subject_id == subject)
  baseline <- 7 + rnorm(1, 0, 1)  # Most patients start with severe pain
  
  # Different effects for different treatments
  is_active <- clinical_data$treatment[subject_rows[1]] == "Active"
  
  # Effect sizes (pain reduction)
  if (is_active) {
    effect_size <- c(0, 1, 2, 3, 3.5)  # Stronger pain reduction
  } else {
    effect_size <- c(0, 0.5, 1, 1.2, 1.5)  # Weaker pain reduction
  }
  
  # Add individual trajectory with some random noise
  clinical_data$pain_score[subject_rows] <- pmax(0, baseline - effect_size + rnorm(5, 0, 1))
}

# Calculate responder status (≥30% improvement from baseline)
clinical_data <- clinical_data %>%
  group_by(subject_id) %>%
  mutate(
    baseline_score = pain_score[visit_week == 0],
    pct_improvement = (baseline_score - pain_score) / baseline_score * 100,
    responder = ifelse(pct_improvement >= 30, "Responder", "Non-responder")
  ) %>%
  ungroup()

# Plot pain scores over time
pain_plot <- lplot(clinical_data, 
      form = pain_score ~ visit_week | treatment,
      cluster_var = "subject_id",
      baseline_value = 0,
      title = "Pain Score Over Time",
      xlab = "Week",
      ylab = "Pain Score (0-10)")

# Calculate responder percentages
responder_data <- clinical_data %>%
  dplyr::filter(visit_week > 0) %>%  # Exclude baseline
  group_by(treatment, visit_week) %>%
  summarize(
    n_subjects = n(),
    n_responders = sum(responder == "Responder"),
    pct_responders = n_responders / n_subjects * 100,
    .groups = "drop"
  )

# Create a custom plot for responder rates
responder_plot <- ggplot(responder_data, aes(x = visit_week, y = pct_responders, color = treatment, group = treatment)) +
  geom_line() +
  geom_point(size = 3) +
  labs(title = "Responder Rates (≥30% Improvement)",
       x = "Week",
       y = "Percent of Responders",
       color = "Treatment") +
  theme_bw() +
  theme(legend.position = "bottom")

# Combine the plots using patchwork
pain_plot + responder_plot + patchwork::plot_layout(ncol = 2)

## ----session_info-------------------------------------------------------------
sessionInfo()

