#!/usr/bin/env Rscript
# Demonstration of summary_statistic parameter for zzlongplot

library(zzlongplot)
library(patchwork)

# Create sample data with different distribution characteristics
set.seed(123)
n_subjects <- 30
n_visits <- 4

demo_data <- data.frame(
  subject_id = rep(1:n_subjects, each = n_visits),
  visit = rep(c(0, 4, 8, 12), times = n_subjects),
  treatment = rep(c("Placebo", "Drug A", "Drug B"), each = n_visits * 10)
)

# Generate data with different distribution characteristics
cat("Creating demonstration data with different distributions...\n")

for (subj in unique(demo_data$subject_id)) {
  subj_rows <- which(demo_data$subject_id == subj)
  treatment <- demo_data$treatment[subj_rows[1]]
  
  # Create different distribution patterns
  if (treatment == "Placebo") {
    # Normal distribution
    baseline <- 50
    effects <- c(0, 1, 2, 3)
    demo_data$outcome_normal[subj_rows] <- baseline + effects + rnorm(4, 0, 5)
    
    # Skewed distribution (using exponential component)
    demo_data$outcome_skewed[subj_rows] <- baseline + effects + rexp(4, rate = 0.2)
    
  } else if (treatment == "Drug A") {
    # Normal distribution with larger effect
    baseline <- 50
    effects <- c(0, 3, 6, 9)
    demo_data$outcome_normal[subj_rows] <- baseline + effects + rnorm(4, 0, 5)
    
    # Skewed distribution
    demo_data$outcome_skewed[subj_rows] <- baseline + effects + rexp(4, rate = 0.15)
    
  } else {  # Drug B
    # Normal distribution with moderate effect
    baseline <- 50
    effects <- c(0, 5, 10, 15)
    demo_data$outcome_normal[subj_rows] <- baseline + effects + rnorm(4, 0, 5)
    
    # Skewed distribution
    demo_data$outcome_skewed[subj_rows] <- baseline + effects + rexp(4, rate = 0.1)
  }
}

cat("Generating plots for normal distribution data...\n")

# Normal distribution: Mean vs Median comparison
p1_mean <- lplot(demo_data, 
                outcome_normal ~ visit | treatment,
                cluster_var = "subject_id",
                baseline_value = 0,
                summary_statistic = "mean",
                confidence_interval = 0.95,
                title = "Normal Data: Mean ± 95% CI",
                xlab = "Week",
                ylab = "Outcome")

p1_median <- lplot(demo_data,
                  outcome_normal ~ visit | treatment,
                  cluster_var = "subject_id", 
                  baseline_value = 0,
                  summary_statistic = "median",
                  title = "Normal Data: Median with IQR",
                  xlab = "Week",
                  ylab = "Outcome")

cat("Generating plots for skewed distribution data...\n")

# Skewed distribution: Mean vs Median comparison  
p2_mean <- lplot(demo_data,
                outcome_skewed ~ visit | treatment,
                cluster_var = "subject_id",
                baseline_value = 0, 
                summary_statistic = "mean",
                confidence_interval = 0.95,
                title = "Skewed Data: Mean ± 95% CI",
                xlab = "Week",
                ylab = "Outcome")

p2_median <- lplot(demo_data,
                  outcome_skewed ~ visit | treatment,
                  cluster_var = "subject_id",
                  baseline_value = 0,
                  summary_statistic = "median", 
                  title = "Skewed Data: Median with IQR",
                  xlab = "Week",
                  ylab = "Outcome")

# Combine plots for comparison
cat("Combining plots for comparison...\n")
combined_plot <- (p1_mean + p1_median) / (p2_mean + p2_median)

# Print summary
cat("Demonstration complete!\n")
cat("The plots show:\n")
cat("- Top row: Normal distribution data (mean and median should be similar)\n")
cat("- Bottom row: Skewed distribution data (median more robust to outliers)\n")
cat("- Left column: Mean ± 95% CI (traditional approach)\n") 
cat("- Right column: Median with IQR (robust approach)\n")
cat("\nWhen to use median:\n")
cat("- Data is skewed or has outliers\n")
cat("- Non-normal distributions\n") 
cat("- When SD > 0.5 * mean (rule of thumb)\n")
cat("- Robust statistics needed\n")