# zzlongplot 0.2.0

Initial public release.

## Statistical corrections

These change numerical output. Figures produced with earlier
development versions should be regenerated.

* `compute_stats()` no longer reports a `ci_level` when the plotted
  bounds are not a confidence interval. Previously,
  `summary_statistic = "mean_se"` drew +/-1 standard error bars while
  recording the requested `confidence_interval`, so the automatic plot
  caption labeled them as a confidence interval. `ci_level` is now `NA`
  for `"mean_se"` and `"boxplot"`, and the caption falls back to
  `"+/-1 SE"`.

* The median interval now responds to `confidence_interval`. It
  previously used a hard-coded multiplier corresponding to a 95%
  boxplot notch regardless of the level requested, so
  `confidence_interval = 0.99` silently returned a 95% interval. The
  interval is now a normal approximation scaled to the requested level,
  which also makes the default 95% interval slightly wider than before.

* Multiplicity adjustment no longer counts each test once per group.
  The omnibus p-value for a timepoint is broadcast across that
  timepoint's group rows, and `p.adjust()` was applied to the broadcast
  column, inflating the correction by the number of groups. Adjustment
  is now performed over the distinct tests. This affected
  `p_adjust_method` values `"bonferroni"`, `"holm"`, `"hochberg"`,
  `"hommel"`, and `"BY"`; the default `"BH"` was unaffected because it
  is invariant under uniform duplication.

## Bug fixes

* `lplot(publication_ready = TRUE)` and `lplot(clinical_mode = TRUE)`
  now actually apply their themes. The `theme` argument defaulted to
  `"bw"`, so the `is.null(theme)` branches that select `"nature"` and
  `"nejm"` were unreachable. `theme` now defaults to `NULL` and
  resolves to `"bw"` after the mode defaults are applied. Passing
  `theme` explicitly still overrides both modes.

* `clinical_mode = TRUE` no longer overrides an explicit
  `show_sample_sizes = FALSE` or `statistical_annotations = FALSE`.
  Enabling a styling mode no longer silently switches on hypothesis
  testing.

* `assign_treatment_colors()` no longer returns `NA` colors and `NA`
  names when given a single treatment group. A `2:n` index counted
  down for `n = 1`.

* `%||%` is now defined internally. It is a base R function only since
  4.4.0, and is exported by neither ggplot2 nor dplyr, so the package
  did not work on the R 4.1-4.3 range that `DESCRIPTION` declares.

* Replaced the deprecated `size` argument with `linewidth` in all
  `element_line()` and `element_rect()` calls across the theme
  functions. Building any plot previously emitted two ggplot2
  deprecation warnings advising users to file a bug report.

* `publication_panels()` now honors its documented `spacing` argument,
  which was accepted and ignored.

## Input validation

* `compute_stats()` validates its own arguments. It is exported, so
  `lplot()`'s guards were bypassable: an unrecognized `test_method`
  silently fell through to the parametric test, and an unrecognized
  `summary_statistic` failed with `object 'result' not found`.

* `lplot()` and `compute_stats()` reject a `confidence_interval`
  outside `(0, 1)`. Passing `95` instead of `0.95` previously produced
  NaN bounds with only a warning from `stats::qt()`.

* `get_colorblind_palette()` and `clinical_colors()` validate `n`, and
  `get_colorblind_palette()` validates `type` instead of silently
  falling back to the qualitative palette. `get_colorblind_palette(2)`
  now returns two colors rather than three.

* `publication_panels()` checks that `plots` is a non-empty list of
  ggplot objects, and that `spacing` is non-negative.

## Documentation

* Added a package-level topic, so `?zzlongplot` now resolves.
* Added `@family` cross-references for the theme, color, CDISC, and
  publication-export function groups.
* Completed the `@return` documentation for `compute_stats()` (which
  omitted `ci_level` and the `"pairwise"` attribute), `lplot()`,
  `validate_cdisc_data()`, `suggest_clinical_vars()`,
  `get_journal_specs()`, `list_journals()`, `publication_panels()`,
  `apply_clinical_colors()`, and `apply_publication_style()`.
* Corrected documented defaults that disagreed with the code
  (`jitter_width`, `sample_size_opts$gap`, `sample_size_opts$row_height`).
* Removed `\dontrun{}` from three examples that run correctly, and
  redirected the `save_publication()` example to `tempdir()` instead of
  the working directory.
* Corrected the README, which referenced a nonexistent
  `get_clinical_theme()` function, a nonexistent `visit_windows`
  argument, and a nonexistent `theme = "ema"` value, and which omitted
  `cluster_var` from its CDISC examples.
* The feature roadmap is no longer shipped as a vignette. It described
  unimplemented features and accounted for most of the package's
  installed size.
