# The numbers a reader takes off one of these figures are the centre
# and the error bar, so the arithmetic behind them is asserted here
# against its definition rather than against the implementation.

mk <- function(n, mu = 10, sd = 2) {
  data.frame(subject_id = seq_len(n), visit = factor("v1"),
             arm = factor("a"), y = stats::rnorm(n, mu, sd))
}

set.seed(4)
d <- mk(40)

# "mean" with a level: the Student t interval.
r <- compute_stats(d, "visit", "y", "arm", baseline_value = "v1",
                   confidence_interval = 0.95, summary_statistic = "mean")
n <- nrow(d)
se <- stats::sd(d$y) / sqrt(n)
expect_equal(r$mean_value[1], mean(d$y), info = "centre is the mean")
expect_equal(r$standard_error[1], se, info = "SE is sd/sqrt(n)")
expect_equal(r$bound_lower[1],
             mean(d$y) - stats::qt(0.975, n - 1) * se,
             info = "lower bound is the t interval")
expect_equal(r$bound_upper[1],
             mean(d$y) + stats::qt(0.975, n - 1) * se,
             info = "upper bound is the t interval")
expect_equal(r$ci_level[1], 0.95, info = "the level is reported")

# "mean_se" draws one standard error and is not a confidence interval,
# so it must not advertise a level: captions are built from ci_level.
r2 <- compute_stats(d, "visit", "y", "arm", baseline_value = "v1",
                    summary_statistic = "mean_se")
expect_equal(r2$bound_upper[1] - r2$mean_value[1], se,
  info = "mean_se draws exactly one standard error")
expect_true(is.na(r2$ci_level[1]),
  info = "mean_se reports no confidence level")

# The median interval uses sigma ~ IQR/1.349 and the median's
# asymptotic SE of 1.2533 sigma/sqrt(n). Assert the multiplier, and
# separately that the interval actually covers at close to its nominal
# rate on normal data.
r3 <- compute_stats(d, "visit", "y", "arm", baseline_value = "v1",
                    confidence_interval = 0.95,
                    summary_statistic = "median")
iqr <- unname(diff(stats::quantile(d$y, c(0.25, 0.75))))
mult <- stats::qnorm(0.975) * 1.2533 / 1.349
expect_equal(r3$bound_upper[1] - r3$mean_value[1],
             mult * iqr / sqrt(n),
  info = "the median half-width is qnorm * 1.2533/1.349 * IQR/sqrt(n)")

set.seed(21)
hit <- replicate(400, {
  rr <- compute_stats(mk(120), "visit", "y", "arm", baseline_value = "v1",
                      confidence_interval = 0.95,
                      summary_statistic = "median")
  rr$bound_lower[1] <= 10 && rr$bound_upper[1] >= 10
})
expect_true(abs(mean(hit) - 0.95) < 0.04,
  info = "the median interval covers near its nominal rate at n = 120")

# Multiplicity adjustment must be the one requested.
set.seed(11)
m <- 60
dd <- data.frame(
  subject_id = rep(seq_len(m), each = 3),
  visit = factor(rep(c("v1", "v2", "v3"), times = m),
                 levels = c("v1", "v2", "v3")),
  arm = factor(rep(c("a", "b"), each = 3, length.out = 3 * m)),
  y = stats::rnorm(3 * m, 10, 2))
dd$y[dd$arm == "b" & dd$visit == "v3"] <-
  dd$y[dd$arm == "b" & dd$visit == "v3"] + 2
for (meth in c("none", "BH", "bonferroni", "holm")) {
  pw <- attr(compute_stats(dd, "visit", "y", "arm", baseline_value = "v1",
                           statistical_tests = TRUE,
                           p_adjust_method = meth), "pairwise")
  expect_equal(pw$p_adj, stats::p.adjust(pw$p_value, meth),
    info = paste("p_adj is", meth, "applied to p_value"))
}

# quantile() names its result "75%", and the subtraction that forms the
# IQR kept that name, so the spread, the standard error and both
# plotted bounds came back labelled "75%" for the median and boxplot
# summaries. The values were right; the labels were not, and they rode
# into anything built from these columns.
for (stat in c("median", "boxplot")) {
  rr <- compute_stats(d, "visit", "y", "arm", baseline_value = "v1",
                      confidence_interval = 0.95,
                      summary_statistic = stat)
  for (cl in c("standard_deviation", "standard_error",
               "bound_lower", "bound_upper")) {
    expect_null(names(rr[[cl]]),
      info = paste(stat, cl, "carries no stray quantile name"))
  }
}
