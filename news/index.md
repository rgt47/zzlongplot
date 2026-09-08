# Changelog

## zzlongplot 0.5.0

### New

- `facet_labeller` gives the panel strips display names, as a function
  or a
  [`ggplot2::labeller()`](https://ggplot2.tidyverse.org/reference/labeller.html).
  Previously `facet_form` took bare variable names with no labeller, so
  the only way to control strip text was to encode it in the factor
  levels of the analysis data, which then carried display strings into
  every other use of that column.

- `facet_type` selects
  [`facet_wrap()`](https://ggplot2.tidyverse.org/reference/facet_wrap.html)
  as well as
  [`facet_grid()`](https://ggplot2.tidyverse.org/reference/facet_grid.html).
  Faceting was always a grid; a single faceting variable with more than
  a few levels wants a ribbon. Under `"wrap"` a two-sided `facet_form`
  contributes both of its terms to the wrap.

- `point_size` and `line_width` set the size of the plotted points and
  the width of the connecting lines. Both default to `NULL`, leaving
  ggplot2’s own defaults untouched, so no existing figure changes.

### Documentation

- [`vignette("sample-size-annotations")`](https://rgt47.github.io/zzlongplot/articles/sample-size-annotations.md)
  documents the table layout (`position = "table"`) and its
  `show_group_labels`, `legend` and `region` options, the behavior under
  faceting, and the full option reference, which had been missing every
  table-mode option.

- [`vignette("formula-interface")`](https://rgt47.github.io/zzlongplot/articles/formula-interface.md)
  documents `facet_type` and `facet_labeller`, and why a labeller is
  preferable to recoding the factor levels of the analysis data.

- [`vignette("publication-themes")`](https://rgt47.github.io/zzlongplot/articles/publication-themes.md)
  documents `bw_print` as an argument independent of the theme, and
  `base_size`.

- [`vignette("customizing-combined-plots")`](https://rgt47.github.io/zzlongplot/articles/customizing-combined-plots.md)
  gains a section on preferring an argument to post-composition, and
  warns that adding a complete theme resets the margin and legend
  settings the sample-size table depends on.

- `README` lists the presentation arguments, and
  [`?lplot`](https://rgt47.github.io/zzlongplot/reference/lplot.md)
  gains examples for each of them.

## zzlongplot 0.4.0

### New

- `x_breaks` sets the axis break positions, dispatching to
  [`scale_x_continuous()`](https://ggplot2.tidyverse.org/reference/scale_continuous.html)
  or
  [`scale_x_discrete()`](https://ggplot2.tidyverse.org/reference/scale_discrete.html)
  according to the x variable. Previously the only way to name the
  breaks was to add a scale to the returned plot.

- `legend_title` titles the group legend, and the default changed. The
  grouping column is renamed to `group` internally, and that name
  reached the legend, so a plot of `y ~ week | arm` was headed `group`.
  It now uses the grouping variable’s own name from the formula, here
  `arm`. The title is applied to the color, fill, linetype and shape
  guides together, since retitling only color splits one key into two
  whenever `bw_print` is in effect.

- `bw_print` is now an argument of
  [`lplot()`](https://rgt47.github.io/zzlongplot/reference/lplot.md)
  rather than a consequence of the theme. Mapping linetype and shape to
  the group in addition to color is what keeps a figure legible in
  grayscale and to readers with a color vision deficiency; it was
  previously reachable only through `theme = "bw"`, so choosing a
  journal theme silently dropped it. The default is unchanged (`TRUE`
  under `"bw"`, `FALSE` otherwise), and it can now be set either way
  under any theme.

## zzlongplot 0.3.0

### Corrections

These change what existing code draws. Figures produced with 0.2.0
should be regenerated.

- The sample-size table (`sample_size_opts$position = "table"`) reported
  the wrong counts under faceting. It built its rows without the facet
  columns and resolved each count with a first-match lookup, so the
  first panel’s sample sizes were recycled into every other panel. A
  faceted figure with unequal panel sizes therefore stated sample sizes
  that were not its own. The table now carries the facet columns through
  and reports each panel’s counts.

- Error bars ignored `color_palette`. Both
  [`geom_errorbar()`](https://ggplot2.tidyverse.org/reference/geom_linerange.html)
  branches in
  [`generate_plot()`](https://rgt47.github.io/zzlongplot/reference/generate_plot.md)
  set `color = "black", alpha = 0.3` as fixed aesthetics, so bars
  rendered gray no matter how the series were colored, and no
  caller-side scale could reach them. They now inherit the group color.
  Pass `error_opts = list(colour = "black", alpha = 0.3)` to restore the
  previous appearance exactly.

- [`compute_stats()`](https://rgt47.github.io/zzlongplot/reference/compute_stats.md)
  silently overwrote a `y` variable named `change`. The
  change-from-baseline column was created under that literal name before
  the summary was taken, so a caller plotting their own column called
  `change` was summarizing the package’s, not theirs. Where the caller’s
  baseline value was non-zero the reported mean was wrong. The
  intermediate is now held under a reserved name.

### New

- `error_type = "line"` draws uncapped ranges via
  [`ggplot2::geom_linerange()`](https://ggplot2.tidyverse.org/reference/geom_linerange.html),
  alongside the existing `"bar"` and `"band"`. It also leaves zero-width
  intervals invisible, where a capped bar still draws its cap: relevant
  at a baseline visit where change is zero for every subject.

- `error_opts` controls the appearance of the `"bar"` and `"line"`
  layers: `colour`, `alpha`, `linewidth`, and `width` (cap width).

- `base_size` on
  [`lplot()`](https://rgt47.github.io/zzlongplot/reference/lplot.md)
  forwards a base type size to the publication theme. Previously the
  only way to match a document’s type size was to add a complete theme
  to the returned plot, which also discarded the margin and legend
  settings the sample-size table relies on.

- `sample_size_opts` gains three options for `position = "table"`:
  `show_group_labels` (default `TRUE`) to suppress the per-row group
  names; `legend` (`"none"`, the default, or `"keep"`) to control legend
  suppression independently of the table, which the previous code
  bundled together; and `region` (`"margin"`, the default, or `"panel"`)
  to choose between reserving plot margin beneath the panel and
  expanding the y scale to take the rows in.

- The group labels on the sample-size table are drawn once, in the first
  panel, rather than repeated in every panel.

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
