library(testthat)
library(zzlongplot)

# Mock data for testing
df_cont <- data.frame(
  subject_id = rep(1:10, each = 3),
  visit = rep(c(0, 1, 2), times = 10),
  measure = rnorm(30, mean = 50, sd = 10),
  group = rep(c("A", "B"), length.out = 30)
)

df_cat <- data.frame(
  subject_id = rep(1:10, each = 3),
  visit = rep(c("baseline", "month1", "month2"), times = 10),
  measure = rnorm(30, mean = 50, sd = 10),
  group = rep(c("A", "B"), length.out = 30)
)

# Helper formula for testing
form <- measure ~ visit | group

test_that("lplot generates a ggplot object for continuous x variable", {
  plot <- lplot(df_cont, form, baseline_value = 0, plot_type = "obs")
  expect_s3_class(plot, "ggplot")
})

test_that("lplot generates a ggplot object for categorical x variable", {
  plot <- lplot(df_cat, form, baseline_value = "baseline", plot_type = "obs")
  expect_s3_class(plot, "ggplot")
})

test_that("lplot returns both plots when plot_type is 'both'", {
  plot <- lplot(df_cont, form, baseline_value = 0, plot_type = "both")
  expect_s3_class(plot, "patchwork")
})

test_that("lplot fails with invalid plot_type", {
  expect_error(lplot(df_cont, form, baseline_value = 0, plot_type = "invalid"), 
               "Invalid plot_type")
})

test_that("parse_formula extracts y, x, and group variables", {
  parsed <- parse_formula(measure ~ visit | group)
  expect_equal(parsed$y, "measure")
  expect_equal(parsed$x, "visit")
  expect_equal(parsed$group, "group")
})

test_that("parse_formula works with faceting", {
  parsed <- parse_formula(measure ~ visit | group ~ site)
  expect_equal(parsed$facets, "site")
})

test_that("compute_stats handles continuous x variables correctly", {
  stats <- compute_stats(df_cont, "visit", "measure", "group", "subject_id", 0)
  expect_true("mean_value" %in% colnames(stats))
  expect_true("change_mean" %in% colnames(stats))
})

test_that("compute_stats handles categorical x variables correctly", {
  stats <- compute_stats(df_cat, "visit", "measure", "group", "subject_id", "baseline")
  expect_true("mean_value" %in% colnames(stats))
  expect_true("change_mean" %in% colnames(stats))
})

test_that("compute_stats adds is_continuous column", {
  stats <- compute_stats(df_cont, "visit", "measure", "group", "subject_id", 0)
  expect_true("is_continuous" %in% colnames(stats))
})

test_that("compute_stats calculates changes correctly", {
  df <- data.frame(
    subject_id = c(1, 1, 1),
    visit = c(0, 1, 2),
    measure = c(50, 55, 60)
  )
  stats <- compute_stats(df, "visit", "measure", NULL, "subject_id", 0)
  expect_equal(stats$change_mean[1], 0)
  expect_equal(stats$change_mean[2], 5)
})

test_that("generate_plot creates a ggplot object for observed values", {
  stats <- compute_stats(df_cont, "visit", "measure", "group", "subject_id", 0)
  plot <- generate_plot(stats, "visit", "mean_value", "group", "bar", "Visit", 
                        "Measure", "Title", "Subtitle", "Caption", NULL)
  expect_s3_class(plot, "ggplot")
})

test_that("generate_plot creates a ggplot object for change values", {
  stats <- compute_stats(df_cont, "visit", "measure", "group", "subject_id", 0)
  plot <- generate_plot(stats, "visit", "change_mean", "group", "bar", "Visit", 
                        "Change", "Title", "Subtitle", "Caption", NULL)
  expect_s3_class(plot, "ggplot")
})

test_that("generate_plot handles faceting correctly", {
  stats <- compute_stats(df_cont, "visit", "measure", "group", "subject_id", 0)
  facet <- list(facet_y = "group", facet_x = NULL)
  plot <- generate_plot(stats, "visit", "mean_value", "group", "bar", "Visit", 
                        "Measure", "Title", "Subtitle", "Caption", facet)
  expect_s3_class(plot, "ggplot")
})

test_that("generate_plot handles bands as error type", {
  stats <- compute_stats(df_cont, "visit", "measure", "group", "subject_id", 0)
  plot <- generate_plot(stats, "visit", "mean_value", "group", "band", "Visit", 
                        "Measure", "Title", "Subtitle", "Caption", NULL)
  expect_s3_class(plot, "ggplot")
})

test_that("lplot fails if data is missing required columns", {
  df_missing <- df_cont[, -which(names(df_cont) == "visit")]
  expect_error(
    lplot(df_missing, measure ~ visit | group, baseline_value = 0), 
    "The following required columns are missing from the data frame: visit"
  )
})

test_that("compute_stats fails if baseline_value is not in data", {
  expect_error(
    compute_stats(df_cont, "visit", "measure", "group", "subject_id", 999),
    "The baseline value '999' is not present in the x variable 'visit'"
  )
})

test_that("parse_formula handles single-variable formulas", {
  parsed <- parse_formula(measure ~ visit)
  expect_equal(parsed$group, NULL)
  expect_equal(parsed$facets, NULL)
})

test_that("generate_plot includes axis labels", {
  stats <- compute_stats(df_cont, "visit", "measure", "group", "subject_id", 0)
  plot <- generate_plot(stats, "visit", "mean_value", "group", "bar", "X Label", 
                        "Y Label", "Title", "Subtitle", "Caption", NULL)
  expect_true("X Label" %in% plot$labels$x)
  expect_true("Y Label" %in% plot$labels$y)
})

test_that("lplot works with multiple grouping variables", {
  df_multi <- df_cont
  df_multi$group2 <- rep(c("X", "Y"), length.out = nrow(df_multi))
  form_multi <- measure ~ visit | group + group2
  plot <- lplot(df_multi, form_multi, baseline_value = 0, plot_type = "obs")
  expect_s3_class(plot, "ggplot")
})

test_that("color palette can be specified", {
  colors <- c("red", "blue")
  plot <- lplot(df_cont, form, baseline_value = 0, plot_type = "obs", color_palette = colors)
  expect_s3_class(plot, "ggplot")
})

test_that("get_colorblind_palette returns correct number of colors", {
  skip_if_not_installed("RColorBrewer")
  colors <- get_colorblind_palette(n = 5)
  expect_equal(length(colors), 5)
})
