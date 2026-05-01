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

plot <- generate_plot(stats, "visit", "mean_value", "group", "bar", "Visit",
  "Measure", "Title", "Subtitle", "Caption", NULL)
expect_inherits(plot, "ggplot", info = "generate_plot creates ggplot for observed")

plot <- generate_plot(stats, "visit", "change_mean", "group", "bar", "Visit",
  "Change", "Title", "Subtitle", "Caption", NULL)
expect_inherits(plot, "ggplot", info = "generate_plot creates ggplot for change")

facet <- list(facet_y = "group", facet_x = NULL)
plot <- generate_plot(stats, "visit", "mean_value", "group", "bar", "Visit",
  "Measure", "Title", "Subtitle", "Caption", facet)
expect_inherits(plot, "ggplot", info = "generate_plot handles faceting")

plot <- generate_plot(stats, "visit", "mean_value", "group", "band", "Visit",
  "Measure", "Title", "Subtitle", "Caption", NULL)
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

