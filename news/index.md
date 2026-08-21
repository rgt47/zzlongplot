# Changelog

## zzlongplot 0.2.0

Initial public release.

### Statistical corrections

These change numerical output. Figures produced with earlier development
versions should be regenerated.

- [`compute_stats()`](https://rgt47.github.io/zzlongplot/reference/compute_stats.md)
  no longer reports a `ci_level` when the plotted bounds are not a
  confidence interval. Previously, `summary_statistic = "mean_se"` drew
  +/-1 standard error bars while recording the requested
  `confidence_interval`, so the automatic plot caption labeled them as a
  confidence interval. `ci_level` is now `NA` for `"mean_se"` and
  `"boxplot"`, and the caption falls back to `"+/-1 SE"`.

- The median interval now responds to `confidence_interval`. It
  previously used a hard-coded multiplier corresponding to a 95% boxplot
  notch regardless of the level requested, so
  `confidence_interval = 0.99` silently returned a 95% interval. The
  interval is now a normal approximation scaled to the requested level,
  which also makes the default 95% interval slightly wider than before.

- Multiplicity adjustment no longer counts each test once per group. The
  omnibus p-value for a timepoint is broadcast across that timepoint’s
  group rows, and [`p.adjust()`](https://rdrr.io/r/stats/p.adjust.html)
  was applied to the broadcast column, inflating the correction by the
  number of groups. Adjustment is now performed over the distinct tests.
  This affected `p_adjust_method` values `"bonferroni"`, `"holm"`,
  `"hochberg"`, `"hommel"`, and `"BY"`; the default `"BH"` was
  unaffected because it is invariant under uniform duplication.

### Bug fixes

- `lplot(publication_ready = TRUE)` and `lplot(clinical_mode = TRUE)`
  now actually apply their themes. The `theme` argument defaulted to
  `"bw"`, so the `is.null(theme)` branches that select `"nature"` and
  `"nejm"` were unreachable. `theme` now defaults to `NULL` and resolves
  to `"bw"` after the mode defaults are applied. Passing `theme`
  explicitly still overrides both modes.

- `clinical_mode = TRUE` no longer overrides an explicit
  `show_sample_sizes = FALSE` or `statistical_annotations = FALSE`.
  Enabling a styling mode no longer silently switches on hypothesis
  testing.

- [`assign_treatment_colors()`](https://rgt47.github.io/zzlongplot/reference/assign_treatment_colors.md)
  no longer returns `NA` colors and `NA` names when given a single
  treatment group. A `2:n` index counted down for `n = 1`.

- `%||%` is now defined internally. It is a base R function only since
  4.4.0, and is exported by neither ggplot2 nor dplyr, so the package
  did not work on the R 4.1-4.3 range that `DESCRIPTION` declares.

- Replaced the deprecated `size` argument with `linewidth` in all
  [`element_line()`](https://ggplot2.tidyverse.org/reference/element.html)
  and
  [`element_rect()`](https://ggplot2.tidyverse.org/reference/element.html)
  calls across the theme functions. Building any plot previously emitted
  two ggplot2 deprecation warnings advising users to file a bug report.

- [`publication_panels()`](https://rgt47.github.io/zzlongplot/reference/publication_panels.md)
  now honors its documented `spacing` argument, which was accepted and
  ignored.

### Input validation

- [`compute_stats()`](https://rgt47.github.io/zzlongplot/reference/compute_stats.md)
  validates its own arguments. It is exported, so
  [`lplot()`](https://rgt47.github.io/zzlongplot/reference/lplot.md)’s
  guards were bypassable: an unrecognized `test_method` silently fell
  through to the parametric test, and an unrecognized
  `summary_statistic` failed with `object 'result' not found`.

- [`lplot()`](https://rgt47.github.io/zzlongplot/reference/lplot.md) and
  [`compute_stats()`](https://rgt47.github.io/zzlongplot/reference/compute_stats.md)
  reject a `confidence_interval` outside `(0, 1)`. Passing `95` instead
  of `0.95` previously produced NaN bounds with only a warning from
  [`stats::qt()`](https://rdrr.io/r/stats/TDist.html).

- [`get_colorblind_palette()`](https://rgt47.github.io/zzlongplot/reference/get_colorblind_palette.md)
  and
  [`clinical_colors()`](https://rgt47.github.io/zzlongplot/reference/clinical_colors.md)
  validate `n`, and
  [`get_colorblind_palette()`](https://rgt47.github.io/zzlongplot/reference/get_colorblind_palette.md)
  validates `type` instead of silently falling back to the qualitative
  palette. `get_colorblind_palette(2)` now returns two colors rather
  than three.

- [`publication_panels()`](https://rgt47.github.io/zzlongplot/reference/publication_panels.md)
  checks that `plots` is a non-empty list of ggplot objects, and that
  `spacing` is non-negative.

### Documentation

- Added a package-level topic, so
  [`?zzlongplot`](https://rgt47.github.io/zzlongplot/reference/zzlongplot-package.md)
  now resolves.
- Added `@family` cross-references for the theme, color, CDISC, and
  publication-export function groups.
- Completed the `@return` documentation for
  [`compute_stats()`](https://rgt47.github.io/zzlongplot/reference/compute_stats.md)
  (which omitted `ci_level` and the `"pairwise"` attribute),
  [`lplot()`](https://rgt47.github.io/zzlongplot/reference/lplot.md),
  [`validate_cdisc_data()`](https://rgt47.github.io/zzlongplot/reference/validate_cdisc_data.md),
  [`suggest_clinical_vars()`](https://rgt47.github.io/zzlongplot/reference/suggest_clinical_vars.md),
  [`get_journal_specs()`](https://rgt47.github.io/zzlongplot/reference/get_journal_specs.md),
  [`list_journals()`](https://rgt47.github.io/zzlongplot/reference/list_journals.md),
  [`publication_panels()`](https://rgt47.github.io/zzlongplot/reference/publication_panels.md),
  [`apply_clinical_colors()`](https://rgt47.github.io/zzlongplot/reference/apply_clinical_colors.md),
  and
  [`apply_publication_style()`](https://rgt47.github.io/zzlongplot/reference/apply_publication_style.md).
- Corrected documented defaults that disagreed with the code
  (`jitter_width`, `sample_size_opts$gap`,
  `sample_size_opts$row_height`).
- Removed `\dontrun{}` from three examples that run correctly, and
  redirected the
  [`save_publication()`](https://rgt47.github.io/zzlongplot/reference/save_publication.md)
  example to [`tempdir()`](https://rdrr.io/r/base/tempfile.html) instead
  of the working directory.
- Corrected the README, which referenced a nonexistent
  `get_clinical_theme()` function, a nonexistent `visit_windows`
  argument, and a nonexistent `theme = "ema"` value, and which omitted
  `cluster_var` from its CDISC examples.
- The feature roadmap is no longer shipped as a vignette. It described
  unimplemented features and accounted for most of the package’s
  installed size.
