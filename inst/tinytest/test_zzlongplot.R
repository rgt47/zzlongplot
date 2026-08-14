library(zzlongplot)

`%||%` <- function(a, b) if (is.null(a)) b else a

set.seed(42)
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

form <- measure ~ visit | group

# --- lplot() ---

plot <- lplot(df_cont, form, baseline_value = 0, plot_type = "obs")
expect_inherits(plot, "ggplot", info = "lplot generates ggplot for continuous x")

plot <- lplot(df_cat, form, baseline_value = "baseline", plot_type = "obs")
expect_inherits(plot, "ggplot", info = "lplot generates ggplot for categorical x")

plot <- lplot(df_cont, form, baseline_value = 0, plot_type = "both")
expect_inherits(plot, "patchwork", info = "lplot returns patchwork for plot_type='both'")

expect_error(
  lplot(df_cont, form, baseline_value = 0, plot_type = "invalid"),
  "Invalid plot_type"
)

# --- parse_formula() ---

parsed <- parse_formula(measure ~ visit | group)
expect_equal(parsed$y, "measure")
expect_equal(parsed$x, "visit")
expect_equal(parsed$group, "group")

parsed <- parse_formula(measure ~ visit | group ~ site)
expect_equal(parsed$facets, "site", info = "parse_formula supports faceting")

parsed <- parse_formula(measure ~ visit)
expect_null(parsed$group, info = "single-variable formula has NULL group")
expect_null(parsed$facets, info = "single-variable formula has NULL facets")

# --- compute_stats() ---

stats <- compute_stats(df_cont, "visit", "measure", "group", "subject_id", 0)
expect_true("mean_value" %in% colnames(stats),
  info = "compute_stats continuous: mean_value column exists")
expect_true("change_mean" %in% colnames(stats),
  info = "compute_stats continuous: change_mean column exists")

stats <- compute_stats(df_cat, "visit", "measure", "group", "subject_id", "baseline")
expect_true("mean_value" %in% colnames(stats),
  info = "compute_stats categorical: mean_value column exists")
expect_true("change_mean" %in% colnames(stats),
  info = "compute_stats categorical: change_mean column exists")

stats <- compute_stats(df_cont, "visit", "measure", "group", "subject_id", 0)
expect_true("is_continuous" %in% colnames(stats),
  info = "compute_stats adds is_continuous column")

df_single <- data.frame(
  subject_id = c(1, 1, 1),
  visit = c(0, 1, 2),
  measure = c(50, 55, 60)
)
stats <- compute_stats(df_single, "visit", "measure", NULL, "subject_id", 0)
expect_equal(stats$change_mean[1], 0, info = "baseline change is 0")
expect_equal(stats$change_mean[2], 5, info = "change from baseline is correct")

expect_error(
  compute_stats(df_cont, "visit", "measure", "group", "subject_id", 999),
  "The baseline value '999' is not present in the x variable 'visit'"
)

# --- generate_plot() ---

stats <- compute_stats(df_cont, "visit", "measure", "group", "subject_id", 0)

# Named arguments throughout: the 6th formal is jitter_width, so the
# positional forms these replaced were silently shifting every label by
# one position and asserting nothing that would catch it.
plot <- generate_plot(stats, x_var = "visit", y_var = "mean_value",
  group_var = "group", error_type = "bar", xlab = "Visit",
  ylab = "Measure", title = "Title", subtitle = "Subtitle",
  caption = "Caption", facet = NULL)
expect_inherits(plot, "ggplot", info = "generate_plot creates ggplot for observed")
expect_equal(plot$labels$x, "Visit", info = "observed plot x label")
expect_equal(plot$labels$y, "Measure", info = "observed plot y label")
expect_equal(plot$labels$title, "Title", info = "observed plot title")
expect_equal(plot$labels$subtitle, "Subtitle", info = "observed plot subtitle")
expect_equal(plot$labels$caption, "Caption", info = "observed plot caption")

plot <- generate_plot(stats, x_var = "visit", y_var = "change_mean",
  group_var = "group", error_type = "bar", xlab = "Visit",
  ylab = "Change", title = "Title", subtitle = "Subtitle",
  caption = "Caption", facet = NULL)
expect_inherits(plot, "ggplot", info = "generate_plot creates ggplot for change")
expect_equal(plot$labels$y, "Change", info = "change plot y label")

facet <- list(facet_y = "group", facet_x = NULL)
plot <- generate_plot(stats, x_var = "visit", y_var = "mean_value",
  group_var = "group", error_type = "bar", xlab = "Visit",
  ylab = "Measure", title = "Title", subtitle = "Subtitle",
  caption = "Caption", facet = facet)
expect_inherits(plot, "ggplot", info = "generate_plot handles faceting")

plot <- generate_plot(stats, x_var = "visit", y_var = "mean_value",
  group_var = "group", error_type = "band", xlab = "Visit",
  ylab = "Measure", title = "Title", subtitle = "Subtitle",
  caption = "Caption", facet = NULL)
expect_inherits(plot, "ggplot", info = "generate_plot handles band error type")

plot <- generate_plot(stats, "visit", "mean_value", "group", "bar", 0.1,
  "X Label", "Y Label", "Title", "Subtitle", "Caption", NULL)
expect_true("X Label" %in% plot$labels$x, info = "x axis label set correctly")
expect_true("Y Label" %in% plot$labels$y, info = "y axis label set correctly")

# --- Integration tests ---

df_missing <- df_cont[, -which(names(df_cont) == "visit")]
expect_error(
  lplot(df_missing, measure ~ visit | group, baseline_value = 0),
  "The following required columns are missing from the data frame: visit"
)

df_multi <- df_cont
df_multi$group2 <- rep(c("X", "Y"), length.out = nrow(df_multi))
form_multi <- measure ~ visit | group + group2
plot <- lplot(df_multi, form_multi, baseline_value = 0, plot_type = "obs")
expect_inherits(plot, "ggplot", info = "lplot works with multiple grouping variables")

colors <- c("red", "blue")
plot <- lplot(df_cont, form, baseline_value = 0, plot_type = "obs",
  color_palette = colors)
expect_inherits(plot, "ggplot", info = "color palette can be specified")

if (requireNamespace("RColorBrewer", quietly = TRUE)) {
  colors <- get_colorblind_palette(n = 5)
  expect_equal(length(colors), 5,
    info = "get_colorblind_palette returns correct number of colors")
}

# --- zzlongplot:::detect_baseline() ---

expect_equal(zzlongplot:::detect_baseline(c(0, 1, 2, 3)), 0,
  info = "detect_baseline returns min for numeric")

expect_equal(zzlongplot:::detect_baseline(c(5, 10, 15)), 5,
  info = "detect_baseline returns min for numeric without 0")

expect_equal(zzlongplot:::detect_baseline(c("bl", "m03", "m06")), "bl",
  info = "detect_baseline detects 'bl'")

expect_equal(zzlongplot:::detect_baseline(c("BL", "W4", "W8")), "BL",
  info = "detect_baseline detects 'BL' (case-insensitive)")

expect_equal(zzlongplot:::detect_baseline(c("baseline", "month1", "month2")), "baseline",
  info = "detect_baseline detects 'baseline'")

expect_equal(zzlongplot:::detect_baseline(c("screening", "week4", "week8")), "screening",
  info = "detect_baseline detects 'screening'")

expect_equal(zzlongplot:::detect_baseline(c("day 0", "day 7", "day 14")), "day 0",
  info = "detect_baseline detects 'day 0'")

expect_equal(zzlongplot:::detect_baseline(c("pre", "post", "followup")), "pre",
  info = "detect_baseline detects 'pre'")

expect_error(zzlongplot:::detect_baseline(c("week4", "week8", "week12")),
  "no common baseline code detected",
  info = "detect_baseline errors when no match found")

expect_error(zzlongplot:::detect_baseline(c("bl", "baseline", "month1")),
  "multiple candidate baseline codes",
  info = "detect_baseline errors on multiple matches")

# --- lplot() with baseline auto-detection ---

expect_message(
  lplot(df_cont, form, plot_type = "obs"),
  "baseline_value not specified",
  info = "lplot messages when auto-detecting baseline"
)

df_bl <- data.frame(
  subject_id = rep(1:5, each = 3),
  visit = rep(c("bl", "m03", "m06"), times = 5),
  measure = rnorm(15, mean = 50, sd = 10),
  group = rep(c("A", "B"), length.out = 15)
)
plot <- lplot(df_bl, measure ~ visit | group, plot_type = "obs")
expect_inherits(plot, "ggplot",
  info = "lplot auto-detects 'bl' as baseline")

# --- summary_statistic variants ---

stats_mean <- compute_stats(df_cont, 'visit', 'measure', 'group',
  'subject_id', 0, summary_statistic = 'mean',
  confidence_interval = 0.95)
expect_true(all(stats_mean$bound_upper >= stats_mean$mean_value),
  info = "mean+CI: upper bound >= center")
expect_true(all(stats_mean$bound_lower <= stats_mean$mean_value),
  info = "mean+CI: lower bound <= center")
expect_equal(unique(stats_mean$ci_level), 0.95,
  info = "ci_level recorded on stats")

stats_se <- compute_stats(df_cont, 'visit', 'measure', 'group',
  'subject_id', 0, summary_statistic = 'mean_se')
expect_true('standard_error' %in% names(stats_se),
  info = "mean_se: standard_error present")

stats_med <- compute_stats(df_cont, 'visit', 'measure', 'group',
  'subject_id', 0, summary_statistic = 'median')
expect_true(all(c('q25_value', 'q75_value') %in% names(stats_med)),
  info = "median: quartile columns present")

stats_bx <- compute_stats(df_cont, 'visit', 'measure', 'group',
  'subject_id', 0, summary_statistic = 'boxplot')
expect_true(all(c('whisker_lower', 'whisker_upper') %in% names(stats_bx)),
  info = "boxplot: whisker columns present")
expect_true(all(stats_bx$whisker_upper >= stats_bx$q75_value),
  info = "boxplot: upper whisker extends beyond Q3")

plot_bx <- lplot(df_cont, form, baseline_value = 0,
  summary_statistic = 'boxplot', plot_type = 'obs')
expect_inherits(plot_bx, 'ggplot',
  info = "boxplot summary renders")

plot_med <- lplot(df_cont, form, baseline_value = 0,
  summary_statistic = 'median', plot_type = 'obs')
expect_inherits(plot_med, 'ggplot',
  info = "median summary renders")

# --- error_type = band with custom ribbon ---

plot_rib <- lplot(df_cont, form, baseline_value = 0,
  error_type = 'band', ribbon_alpha = 0.3,
  ribbon_fill = 'lightblue', plot_type = 'obs')
expect_inherits(plot_rib, 'ggplot',
  info = "custom ribbon fill/alpha renders")

# --- statistical_annotations (parametric, 2 groups) ---

set.seed(1)
df2 <- data.frame(
  subject_id = rep(1:20, each = 3),
  visit = rep(c(0, 1, 2), times = 20),
  measure = c(rnorm(30, 50, 5), rnorm(30, 55, 5)),
  group = rep(c('A', 'B'), each = 30)
)
stats_t <- compute_stats(df2, 'visit', 'measure', 'group',
  'subject_id', 0, statistical_tests = TRUE,
  test_method = 'parametric')
expect_true('p_value' %in% names(stats_t),
  info = "parametric: p_value column added")
expect_true('significance' %in% names(stats_t),
  info = "parametric: significance column added")
pw_attr <- attr(stats_t, 'pairwise')
expect_false(is.null(pw_attr),
  info = "parametric: pairwise attribute set")
expect_true(all(c('x_val', 'group1', 'group2', 'estimate',
  'lower_cl', 'upper_cl', 'p_value', 'p_adj',
  'significance') %in% names(pw_attr)),
  info = "parametric pairwise has expected columns")

plot_sig <- lplot(df2, measure ~ visit | group, baseline_value = 0,
  statistical_annotations = TRUE, plot_type = 'obs')
expect_inherits(plot_sig, 'ggplot',
  info = "plot with parametric significance renders")

# --- nonparametric test method ---

stats_np <- compute_stats(df2, 'visit', 'measure', 'group',
  'subject_id', 0, statistical_tests = TRUE,
  test_method = 'nonparametric')
expect_true('p_value' %in% names(stats_np),
  info = "nonparametric: p_value column added")
pw_np <- attr(stats_np, 'pairwise')
expect_false(is.null(pw_np),
  info = "nonparametric: pairwise attribute set")
expect_true(all(is.na(pw_np$estimate)),
  info = "nonparametric: estimate is NA by design")

# --- 3+ groups: omnibus + pairwise contrasts ---

set.seed(2)
df3 <- data.frame(
  subject_id = rep(1:30, each = 3),
  visit = rep(c(0, 1, 2), times = 30),
  measure = c(rnorm(30, 50, 5), rnorm(30, 55, 5),
    rnorm(30, 60, 5)),
  group = rep(c('A', 'B', 'C'), each = 30)
)
stats3 <- compute_stats(df3, 'visit', 'measure', 'group',
  'subject_id', 0, statistical_tests = TRUE,
  test_method = 'parametric')
pw3 <- attr(stats3, 'pairwise')
expect_equal(length(unique(paste(pw3$group1, pw3$group2))), 3,
  info = "3 groups produce 3 pairwise contrasts per timepoint")

plot3 <- lplot(df3, measure ~ visit | group, baseline_value = 0,
  statistical_annotations = TRUE, plot_type = 'obs')
expect_inherits(plot3, 'ggplot',
  info = "3-group plot with brackets renders")

# --- p_adjust_method validation ---

expect_error(
  lplot(df2, measure ~ visit | group, baseline_value = 0,
    statistical_annotations = TRUE, p_adjust_method = 'bogus'),
  'Invalid p_adjust_method'
)

expect_error(
  lplot(df2, measure ~ visit | group, baseline_value = 0,
    test_method = 'unknown'),
  'Invalid test_method'
)

# --- .p_to_stars internal ---

stars <- zzlongplot:::.p_to_stars(
  c(0.0001, 0.005, 0.03, 0.2, NA))
expect_equal(stars, c('***', '**', '*', 'ns', ''),
  info = ".p_to_stars maps p-values to codes")

# --- .filter_vs_reference internal ---

pw_mock <- data.frame(
  x_val = 1, group1 = c('Placebo', 'Placebo', 'Drug A'),
  group2 = c('Drug A', 'Drug B', 'Drug B'),
  estimate = c(1, 2, 1), lower_cl = c(0, 1, 0),
  upper_cl = c(2, 3, 2), p_value = c(0.01, 0.02, 0.5),
  p_adj = c(0.01, 0.02, 0.5),
  significance = c('*', '*', 'ns'),
  stringsAsFactors = FALSE
)
filt <- zzlongplot:::.filter_vs_reference(pw_mock)
expect_equal(nrow(filt), 2,
  info = ".filter_vs_reference keeps only vs-Placebo contrasts")

pw_noref <- data.frame(
  x_val = 1, group1 = 'Drug A', group2 = 'Drug B',
  estimate = 1, lower_cl = 0, upper_cl = 2,
  p_value = 0.5, p_adj = 0.5, significance = 'ns',
  stringsAsFactors = FALSE
)
expect_equal(nrow(zzlongplot:::.filter_vs_reference(pw_noref)), 1,
  info = ".filter_vs_reference: no ref -> unchanged")

# --- .abbrev_group internal ---

expect_equal(zzlongplot:::.abbrev_group('Drug A'), 'DA',
  info = ".abbrev_group: two-word -> initials")
expect_equal(zzlongplot:::.abbrev_group('Placebo'), 'Plac',
  info = ".abbrev_group: single word -> first 4 chars")

# --- .format_p internal ---

expect_equal(zzlongplot:::.format_p(0.0001), 'p<0.001')
expect_equal(zzlongplot:::.format_p(0.042), 'p=0.042')
expect_equal(zzlongplot:::.format_p(NA_real_), 'p=NA')

# --- contrast_display = footnote / table ---

plot_fn <- lplot(df2, measure ~ visit | group, baseline_value = 0,
  statistical_annotations = TRUE,
  contrast_display = 'footnote', plot_type = 'obs')
expect_inherits(plot_fn, 'ggplot',
  info = "contrast_display='footnote' renders")
expect_true(nzchar(plot_fn$labels$caption %||% ''),
  info = "footnote added to caption")

plot_tb <- lplot(df2, measure ~ visit | group, baseline_value = 0,
  statistical_annotations = TRUE,
  contrast_display = 'table', plot_type = 'obs')
expect_inherits(plot_tb, 'patchwork',
  info = "contrast_display='table' returns patchwork (plot + table)")

expect_error(
  lplot(df2, measure ~ visit | group, baseline_value = 0,
    contrast_display = 'bogus'),
  'Invalid contrast_display'
)

# --- publication themes ---

for (th in c('bw', 'nejm', 'nature', 'lancet',
  'jama', 'science', 'jco')) {
  p <- lplot(df_cont, form, baseline_value = 0,
    theme = th, plot_type = 'obs')
  expect_inherits(p, 'ggplot',
    info = sprintf("theme='%s' renders", th))
}

# --- sample size annotations ---

plot_ssp <- lplot(df_cont, form, baseline_value = 0,
  show_sample_sizes = TRUE,
  sample_size_opts = list(position = 'point', size = 3),
  plot_type = 'obs')
expect_inherits(plot_ssp, 'ggplot',
  info = "sample_size position='point' renders")

plot_sst <- lplot(df_cont, form, baseline_value = 0,
  show_sample_sizes = TRUE,
  sample_size_opts = list(position = 'table'),
  plot_type = 'obs')
expect_inherits(plot_sst, 'ggplot',
  info = "sample_size position='table' renders")

# --- reference lines ---

plot_ref <- lplot(df_cont, form, baseline_value = 0,
  reference_lines = list(
    list(value = 50, axis = 'y', color = 'red',
      linetype = 'dashed'),
    list(value = 1, axis = 'x', color = 'blue')
  ),
  plot_type = 'obs')
expect_inherits(plot_ref, 'ggplot',
  info = "reference_lines (y and x) render")

# --- clinical_mode defaults ---

clin <- data.frame(
  USUBJID = rep(paste0('S', 1:15), each = 3),
  AVISITN = rep(c(0, 1, 2), times = 15),
  AVAL = rnorm(45, 50, 5),
  TRT01P = rep(c('Placebo', 'Drug A', 'Drug B'), length.out = 45)
)
plot_clin <- lplot(clin, AVAL ~ AVISITN | TRT01P,
  cluster_var = 'USUBJID', baseline_value = 0,
  clinical_mode = TRUE, plot_type = 'obs')
expect_inherits(plot_clin, 'ggplot',
  info = "clinical_mode produces ggplot")

# --- faceting via facet_form ---

df_facet <- df_cont
df_facet$site <- rep(c('S1', 'S2'), length.out = nrow(df_facet))
plot_facet <- lplot(df_facet, measure ~ visit | group,
  facet_form = ~ site, baseline_value = 0, plot_type = 'obs')
expect_inherits(plot_facet, 'ggplot',
  info = "facet_form ~ site renders")

# --- parse_formula: multiple facets & edge cases ---

parsed_multi <- parse_formula(y ~ x | g ~ s1 + s2)
expect_equal(parsed_multi$facets, c('s1', 's2'),
  info = "parse_formula: multi-facet '+' split")

# --- compute_stats: facet_vars carried through grouping ---

stats_fv <- compute_stats(df_facet, 'visit', 'measure', 'group',
  'subject_id', 0, facet_vars = 'site')
expect_true('site' %in% names(stats_fv),
  info = "compute_stats preserves facet_vars in output")

# --- detect_baseline: numeric message ---

expect_message(zzlongplot:::detect_baseline(c(2, 5, 8)),
  'minimum numeric value',
  info = "detect_baseline messages on numeric")

# --- plot_type = 'change' returns ggplot ---

plot_chg <- lplot(df_cont, form, baseline_value = 0,
  plot_type = 'change')
expect_inherits(plot_chg, 'ggplot',
  info = "plot_type='change' returns single ggplot")

# --- jitter_width validation ---

expect_error(
  lplot(df_cont, form, baseline_value = 0,
    jitter_width = -0.1),
  'jitter_width must be a non-negative numeric'
)

# --- summary_statistic validation ---

expect_error(
  lplot(df_cont, form, baseline_value = 0,
    summary_statistic = 'mode'),
  'Invalid summary_statistic'
)

# --- error_type validation ---

expect_error(
  lplot(df_cont, form, baseline_value = 0, error_type = 'bogus'),
  'Invalid error_type'
)

# --- df / form type validation ---

expect_error(lplot(list(a = 1), form, baseline_value = 0),
  "'df' must be a data frame")

expect_error(lplot(df_cont, 'not a formula', baseline_value = 0),
  "'form' must be a formula object")

expect_error(lplot(df_cont, form, baseline_value = 0,
  facet_form = 'not a formula'),
  "'facet_form' must be a formula object")

# --- cluster_var missing ---

expect_error(
  lplot(df_cont, form, baseline_value = 0,
    cluster_var = 'nonexistent'),
  "Cluster variable 'nonexistent' not found")


# ---------------------------------------------------------------
# Regression tests for defects found in the 2026-08-14 package
# review. Each block names the defect it guards against.
# ---------------------------------------------------------------

# --- ci_level must not claim a level the bounds do not have ---

d_ci <- data.frame(
  subject_id = rep(1:20, each = 3),
  visit = rep(c(0, 1, 2), times = 20),
  measure = rnorm(60, 50, 10),
  group = rep(c('A', 'B'), each = 3, length.out = 60)
)

s_se <- compute_stats(d_ci, x_var = 'visit', y_var = 'measure',
  group_var = 'group', cluster_var = 'subject_id', baseline_value = 0,
  summary_statistic = 'mean_se', confidence_interval = 0.95)
expect_true(all(is.na(s_se$ci_level)),
  info = "mean_se must not report a ci_level: its bars are +/-1 SE")
expect_equal(s_se$bound_upper - s_se$mean_value, s_se$standard_error,
  info = "mean_se bounds are exactly +/-1 standard error")

s_mean <- compute_stats(d_ci, x_var = 'visit', y_var = 'measure',
  group_var = 'group', cluster_var = 'subject_id', baseline_value = 0,
  summary_statistic = 'mean', confidence_interval = 0.95)
expect_equal(unique(s_mean$ci_level), 0.95,
  info = "mean with a level reports that level")
expect_true(all(s_mean$bound_upper - s_mean$mean_value >
                s_se$bound_upper - s_se$mean_value),
  info = "a 95% CI is strictly wider than +/-1 SE")

s_box <- compute_stats(d_ci, x_var = 'visit', y_var = 'measure',
  group_var = 'group', cluster_var = 'subject_id', baseline_value = 0,
  summary_statistic = 'boxplot', confidence_interval = 0.95)
expect_true(all(is.na(s_box$ci_level)),
  info = "boxplot whiskers must not report a ci_level")

# --- median interval must respond to confidence_interval ---

m95 <- compute_stats(d_ci, x_var = 'visit', y_var = 'measure',
  group_var = 'group', cluster_var = 'subject_id', baseline_value = 0,
  summary_statistic = 'median', confidence_interval = 0.95)
m99 <- compute_stats(d_ci, x_var = 'visit', y_var = 'measure',
  group_var = 'group', cluster_var = 'subject_id', baseline_value = 0,
  summary_statistic = 'median', confidence_interval = 0.99)
expect_true(all(m99$bound_upper > m95$bound_upper),
  info = "a 99% median interval is wider than a 95% one")

# --- p-value adjustment counts each test once, not once per group ---

set.seed(7)
n_sub <- 40
d_p <- data.frame(
  subject_id = rep(seq_len(n_sub), each = 3),
  visit = rep(c(0, 1, 2), times = n_sub),
  group = rep(c('A', 'B'), each = 3, length.out = 3 * n_sub)
)
d_p$measure <- rnorm(3 * n_sub, 50, 5) + ifelse(d_p$group == 'B', 8, 0)

s_bonf <- compute_stats(d_p, x_var = 'visit', y_var = 'measure',
  group_var = 'group', cluster_var = 'subject_id', baseline_value = 0,
  statistical_tests = TRUE, test_method = 'parametric',
  p_adjust_method = 'bonferroni')
n_tests <- length(unique(s_bonf$visit))
expect_equal(s_bonf$p_adj, pmin(1, s_bonf$p_value * n_tests),
  info = "Bonferroni multiplier is the number of timepoints, not timepoints x groups")

# --- compute_stats validates its own arguments (it is exported) ---

expect_error(
  compute_stats(d_ci, x_var = 'visit', y_var = 'measure',
    group_var = 'group', cluster_var = 'subject_id', baseline_value = 0,
    statistical_tests = TRUE, test_method = 'bogus'),
  "Invalid test_method")
expect_error(
  compute_stats(d_ci, x_var = 'visit', y_var = 'measure',
    group_var = 'group', cluster_var = 'subject_id', baseline_value = 0,
    summary_statistic = 'mode'),
  "Invalid summary_statistic")
expect_error(
  compute_stats(d_ci, x_var = 'visit', y_var = 'measure',
    group_var = 'group', cluster_var = 'subject_id', baseline_value = 0,
    confidence_interval = 95),
  "Invalid confidence_interval")
expect_error(
  compute_stats('not a data frame', x_var = 'visit', y_var = 'measure',
    group_var = 'group', cluster_var = 'subject_id', baseline_value = 0),
  "must be a data frame")

# --- lplot validates confidence_interval ---

expect_error(
  lplot(d_ci, measure ~ visit | group, cluster_var = 'subject_id',
    baseline_value = 0, confidence_interval = 95),
  "Invalid confidence_interval")

# --- mode defaults do not override explicit user choices ---

p_mode <- lplot(d_ci, measure ~ visit | group, cluster_var = 'subject_id',
  baseline_value = 0, clinical_mode = TRUE,
  statistical_annotations = FALSE, show_sample_sizes = FALSE)
expect_inherits(p_mode, "ggplot",
  info = "clinical_mode honors an explicit statistical_annotations = FALSE")

p_default <- lplot(d_ci, measure ~ visit | group, cluster_var = 'subject_id',
  baseline_value = 0)
p_pub <- lplot(d_ci, measure ~ visit | group, cluster_var = 'subject_id',
  baseline_value = 0, publication_ready = TRUE)
p_clin <- lplot(d_ci, measure ~ visit | group, cluster_var = 'subject_id',
  baseline_value = 0, clinical_mode = TRUE)
expect_false(identical(p_default$theme, p_pub$theme),
  info = "publication_ready actually changes the theme")
expect_false(identical(p_default$theme, p_clin$theme),
  info = "clinical_mode actually changes the theme")
p_explicit <- lplot(d_ci, measure ~ visit | group, cluster_var = 'subject_id',
  baseline_value = 0, clinical_mode = TRUE, theme = 'bw')
expect_equal(p_explicit$theme, p_default$theme,
  info = "an explicit theme overrides the mode default")

# --- assign_treatment_colors with a single group ---

single <- assign_treatment_colors('Placebo')
expect_equal(length(single), 1L,
  info = "one treatment yields exactly one color")
expect_equal(names(single), 'Placebo',
  info = "the single color is named for its treatment")
expect_false(any(is.na(single)), info = "no NA colors")
expect_false(any(is.na(names(single))), info = "no NA names")

two <- assign_treatment_colors(c('Placebo', 'Drug A'))
expect_equal(length(two), 2L, info = "two treatments yield two colors")
expect_equal(sort(names(two)), sort(c('Placebo', 'Drug A')),
  info = "both treatments are named")

# --- palette functions validate n and type ---

expect_error(get_colorblind_palette(0), "positive whole number")
expect_error(get_colorblind_palette(-1), "positive whole number")
expect_error(get_colorblind_palette(3, type = 'banana'), "Invalid type")
expect_equal(length(get_colorblind_palette(2)), 2L,
  info = "n = 2 returns exactly 2 colors, not the brewer floor of 3")
expect_equal(length(get_colorblind_palette(5)), 5L,
  info = "n = 5 returns exactly 5 colors")
expect_error(clinical_colors('treatment', n = 0), "positive whole number")

# --- publication_panels validates its inputs ---

p1 <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) + ggplot2::geom_point()
p2 <- ggplot2::ggplot(mtcars, ggplot2::aes(hp, mpg)) + ggplot2::geom_point()
expect_inherits(publication_panels(list(p1, p2), labels = c('A', 'B')),
  "patchwork", info = "publication_panels combines two ggplots")
expect_error(publication_panels(list(1, 2)), "must be ggplot objects")
expect_error(publication_panels(list()), "non-empty list")
expect_error(publication_panels(list(p1, p2), spacing = -1),
  "non-negative")

# --- journal specification helpers ---

specs <- get_journal_specs('nature')
expect_true(all(c('name', 'single_column_mm', 'double_column_mm',
  'max_height_mm', 'min_dpi', 'preferred_dpi', 'font_size',
  'font_family', 'formats', 'color_mode', 'notes') %in% names(specs)),
  info = "get_journal_specs returns all 11 documented elements")
expect_error(get_journal_specs('banana'), "Unknown journal")

jl <- list_journals()
expect_inherits(jl, "data.frame", info = "list_journals returns a data frame")
expect_true(all(c('journal', 'name', 'single_column_mm', 'double_column_mm',
  'preferred_dpi', 'font_size') %in% names(jl)),
  info = "list_journals has the documented columns")
expect_true(all(c('max_height_mm', 'formats', 'notes') %in%
  names(list_journals(detailed = TRUE))),
  info = "detailed = TRUE adds the documented extra columns")

# --- save_publication round trip ---

out_file <- file.path(tempdir(), 'zzlp_test_figure.pdf')
invisible(save_publication(p1, out_file, journal = 'nature'))
expect_true(file.exists(out_file), info = "save_publication writes the file")
expect_true(file.size(out_file) > 0, info = "the written file is non-empty")
unlink(out_file)
expect_error(save_publication(p1, out_file, journal = 'banana'),
  "Unknown journal")

# --- CDISC helpers ---

cdisc_df <- data.frame(
  USUBJID = rep(paste0('001-', 1:10), each = 4),
  AVISITN = rep(c(0, 1, 2, 3), times = 10),
  AVAL = rnorm(40, 50, 10),
  TRT01P = rep(c('Placebo', 'Active'), length.out = 40)
)

val <- validate_cdisc_data(cdisc_df)
expect_true(all(c('compliance_score', 'score_breakdown', 'issues',
  'recommendations', 'max_possible_score', 'actual_score') %in% names(val)),
  info = "validate_cdisc_data returns all 6 documented elements")
expect_true(val$compliance_score > validate_cdisc_data(df_cont)$compliance_score,
  info = "a CDISC-shaped data frame scores above a non-CDISC one")

sug <- suggest_clinical_vars(cdisc_df, verbose = FALSE)
expect_true(all(c('suggested_formula', 'detected_vars', 'cluster_var',
  'baseline_value', 'warnings') %in% names(sug)),
  info = "suggest_clinical_vars returns all 5 documented elements")
expect_equal(sug$cluster_var, 'USUBJID',
  info = "USUBJID is detected as the cluster variable")
expect_equal(sug$suggested_formula, 'AVAL ~ AVISITN | TRT01P',
  info = "the suggested formula matches the detected variables")

expect_inherits(get_cdisc_template('efficacy'), "character",
  info = "get_cdisc_template returns a character vector")
expect_error(get_cdisc_template('banana'), "Unknown scenario")

# --- themes and styling exports are exercised directly ---

for (th in c('nature', 'science', 'nejm', 'fda', 'lancet', 'jama',
             'jco', 'bw_print')) {
  expect_inherits(get(paste0('theme_', th))(), "theme",
    info = paste0('theme_', th, '() returns a theme object'))
}
expect_inherits(get_publication_theme('nature'), "theme",
  info = "get_publication_theme returns a theme")
expect_error(get_publication_theme('banana'), "Unknown theme")

expect_inherits(apply_publication_style(p1, 'nature'), "ggplot",
  info = "apply_publication_style returns a ggplot")

clin_df <- data.frame(
  visit = rep(1:4, each = 10),
  efficacy = rnorm(40, 50, 10),
  treatment = rep(c('Placebo', 'Drug A'), length.out = 40)
)
pc <- ggplot2::ggplot(clin_df,
  ggplot2::aes(x = visit, y = efficacy, color = treatment)) +
  ggplot2::geom_line()
expect_inherits(apply_clinical_colors(pc, 'treatment'), "ggplot",
  info = "apply_clinical_colors returns a ggplot")
expect_warning(apply_clinical_colors(pc, 'no_such_column'),
  info = "a missing treatment column warns rather than failing silently")
