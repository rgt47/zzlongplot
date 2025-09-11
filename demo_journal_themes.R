#!/usr/bin/env Rscript
# Demonstration of enhanced theme parameter with automatic journal colors

library(zzlongplot)
library(patchwork)

# Create comprehensive clinical trial dataset
set.seed(123)
n_subjects <- 60
n_visits <- 4

demo_data <- data.frame(
  subject_id = rep(1:n_subjects, each = n_visits),
  visit = rep(c(0, 4, 8, 12), times = n_subjects),
  treatment = rep(c("Placebo", "Drug 10mg", "Drug 20mg"), each = n_visits * 20)
)

# Generate realistic clinical outcomes
cat("Creating clinical trial demonstration data...\n")

for (subj in unique(demo_data$subject_id)) {
  subj_rows <- which(demo_data$subject_id == subj)
  treatment <- demo_data$treatment[subj_rows[1]]
  
  # Baseline efficacy score
  baseline <- 60 + rnorm(1, 0, 8)
  
  # Treatment-specific efficacy improvements
  if (treatment == "Placebo") {
    effects <- c(0, 2, 3, 4)  # Small placebo effect
  } else if (treatment == "Drug 10mg") {
    effects <- c(0, 8, 12, 15)  # Moderate dose effect
  } else {  # Drug 20mg
    effects <- c(0, 12, 18, 22)  # High dose effect
  }
  
  # Generate data with some variability
  demo_data$efficacy[subj_rows] <- baseline + effects + rnorm(4, 0, 6)
  
  # Safety outcome (lower is better)
  demo_data$safety[subj_rows] <- 100 - (effects * 0.3) + rnorm(4, 0, 4)
}

cat("Generating plots with different journal themes...\n")

# 1. NEJM - Complete journal styling with one parameter
cat("Creating NEJM-styled plot...\n")
p_nejm <- lplot(demo_data, 
               efficacy ~ visit | treatment,
               cluster_var = "subject_id",
               baseline_value = 0,
               theme = "nejm",  # Auto-applies NEJM theme + colors
               title = "Efficacy Analysis",
               subtitle = "NEJM Theme with Official Colors",
               xlab = "Week",
               ylab = "Efficacy Score")

# 2. Nature - Complete journal styling  
cat("Creating Nature-styled plot...\n")
p_nature <- lplot(demo_data,
                 efficacy ~ visit | treatment,
                 cluster_var = "subject_id", 
                 baseline_value = 0,
                 theme = "nature",  # Auto-applies Nature theme + colors
                 title = "Efficacy Analysis", 
                 subtitle = "Nature Theme with Official Colors",
                 xlab = "Week",
                 ylab = "Efficacy Score")

# 3. Lancet - Complete journal styling
cat("Creating Lancet-styled plot...\n")
p_lancet <- lplot(demo_data,
                 efficacy ~ visit | treatment,
                 cluster_var = "subject_id",
                 baseline_value = 0, 
                 theme = "lancet",  # Auto-applies Lancet theme + colors
                 title = "Efficacy Analysis",
                 subtitle = "Lancet Theme with Official Colors", 
                 xlab = "Week",
                 ylab = "Efficacy Score")

# 4. JAMA - Complete journal styling
cat("Creating JAMA-styled plot...\n")
p_jama <- lplot(demo_data,
               efficacy ~ visit | treatment,
               cluster_var = "subject_id",
               baseline_value = 0,
               theme = "jama",  # Auto-applies JAMA theme + colors
               title = "Efficacy Analysis",
               subtitle = "JAMA Theme with Official Colors",
               xlab = "Week", 
               ylab = "Efficacy Score")

# 5. Science - Complete journal styling
cat("Creating Science-styled plot...\n")
p_science <- lplot(demo_data,
                  efficacy ~ visit | treatment,
                  cluster_var = "subject_id",
                  baseline_value = 0,
                  theme = "science",  # Auto-applies Science theme + colors
                  title = "Efficacy Analysis",
                  subtitle = "Science Theme with Official Colors",
                  xlab = "Week",
                  ylab = "Efficacy Score")

# 6. JCO - Complete journal styling
cat("Creating JCO-styled plot...\n")
p_jco <- lplot(demo_data,
              efficacy ~ visit | treatment, 
              cluster_var = "subject_id",
              baseline_value = 0,
              theme = "jco",  # Auto-applies JCO theme + colors
              title = "Efficacy Analysis",
              subtitle = "JCO Theme with Official Colors",
              xlab = "Week",
              ylab = "Efficacy Score")

# Create comparison grid
cat("Combining plots for comparison...\n")
journal_comparison <- (p_nejm + p_nature) / (p_lancet + p_jama) / (p_science + p_jco)

# Demonstrate override capability
cat("Testing theme with color override...\n")
p_override <- lplot(demo_data,
                   efficacy ~ visit | treatment,
                   cluster_var = "subject_id", 
                   baseline_value = 0,
                   theme = "nejm",  # NEJM typography
                   color_palette = "clinical",  # Override with clinical colors
                   title = "Efficacy Analysis",
                   subtitle = "NEJM Theme + Clinical Colors (Override)",
                   xlab = "Week",
                   ylab = "Efficacy Score")

# Print summary
cat("Journal theme demonstration complete!\n")
cat("\nFeatures demonstrated:\n")
cat("✓ One-parameter journal styling (theme + colors)\n")
cat("✓ Six major medical journals supported\n")
cat("✓ Official journal color palettes from ggsci\n")
cat("✓ Automatic color application with themes\n")
cat("✓ Color override capability maintained\n")
cat("✓ Publication-ready typography and layout\n")

cat("\nUsage examples:\n")
cat("lplot(data, form, theme = 'nejm')    # Complete NEJM styling\n")
cat("lplot(data, form, theme = 'nature')  # Complete Nature styling\n")
cat("lplot(data, form, theme = 'nejm', color_palette = 'clinical')  # Override colors\n")

cat("\nSupported journal themes:\n")
cat("- nejm: New England Journal of Medicine\n")
cat("- nature: Nature Publishing Group\n") 
cat("- lancet: The Lancet\n")
cat("- jama: Journal of the American Medical Association\n")
cat("- science: Science (AAAS)\n")
cat("- jco: Journal of Clinical Oncology\n")