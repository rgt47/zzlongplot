#!/usr/bin/env Rscript
# Demonstration of jitter_width parameter for zzlongplot

library(zzlongplot)
library(patchwork)

# Create sample data with multiple groups and overlapping time points
set.seed(123)
demo_data <- data.frame(
  subject_id = rep(1:30, each = 4),
  visit = rep(c(0, 4, 8, 12), times = 30),
  outcome = NA,
  treatment = rep(c("Placebo", "Drug A", "Drug B"), each = 40)
)

# Generate realistic outcome data
for (subj in unique(demo_data$subject_id)) {
  subj_rows <- which(demo_data$subject_id == subj)
  baseline <- 50 + rnorm(1, 0, 8)
  treatment <- demo_data$treatment[subj_rows[1]]
  
  # Different treatment effects
  if (treatment == "Placebo") {
    effects <- c(0, 1, 1.5, 2)
  } else if (treatment == "Drug A") {
    effects <- c(0, 3, 6, 9)
  } else {
    effects <- c(0, 5, 10, 15)
  }
  
  demo_data$outcome[subj_rows] <- baseline + effects + rnorm(4, 0, 4)
}

# Create plots demonstrating different jitter_width values
cat("Creating demonstration plots...\n")

# Plot 1: No jitter (default overlap)
p1 <- lplot(demo_data, 
           outcome ~ visit | treatment,
           cluster_var = "subject_id",
           baseline_value = 0,
           jitter_width = 0,
           title = "No Jitter (jitter_width = 0)",
           xlab = "Week",
           ylab = "Outcome")

# Plot 2: Small jitter
p2 <- lplot(demo_data,
           outcome ~ visit | treatment, 
           cluster_var = "subject_id",
           baseline_value = 0,
           jitter_width = 0.1,
           title = "Small Jitter (jitter_width = 0.1)",
           xlab = "Week", 
           ylab = "Outcome")

# Plot 3: Larger jitter for better separation
p3 <- lplot(demo_data,
           outcome ~ visit | treatment,
           cluster_var = "subject_id", 
           baseline_value = 0,
           jitter_width = 0.3,
           title = "Larger Jitter (jitter_width = 0.3)",
           xlab = "Week",
           ylab = "Outcome")

# Plot 4: Error bands instead of bars (no jitter needed)
p4 <- lplot(demo_data,
           outcome ~ visit | treatment,
           cluster_var = "subject_id",
           baseline_value = 0,
           error_type = "band", 
           title = "Error Bands (no jitter needed)",
           xlab = "Week",
           ylab = "Outcome")

# Combine plots for comparison
combined_plot <- (p1 + p2) / (p3 + p4)

# Print summary
cat("Demonstration complete!\n")
cat("The plots show:\n")
cat("- Top left: Overlapping error bars (hard to distinguish groups)\n") 
cat("- Top right: Small jitter (slight separation)\n")
cat("- Bottom left: Larger jitter (clear separation)\n")
cat("- Bottom right: Error bands (alternative to error bars)\n")
cat("\nRecommendation: Use jitter_width = 0.1-0.2 for most cases with multiple groups\n")