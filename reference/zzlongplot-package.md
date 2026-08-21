# zzlongplot: Longitudinal Plotting with Clinical Trials Support

Provides a formula interface for defining longitudinal plots with
optional grouping, change-from-baseline panels, and faceting. Includes
specialized support for clinical trials with CDISC variable detection,
regulatory and journal themes, and publication-ready export.

## Details

The core workflow is a single call to
[`lplot()`](https://rgt47.github.io/zzlongplot/reference/lplot.md),
which parses a formula, computes summary statistics, and renders the
plot:

- [`lplot()`](https://rgt47.github.io/zzlongplot/reference/lplot.md):
  the main entry point. Produces the observed plot, the
  change-from-baseline plot, or both combined.

- [`parse_formula()`](https://rgt47.github.io/zzlongplot/reference/parse_formula.md):
  extracts response, time, grouping, and faceting variables from a
  `y ~ x | group` formula.

- [`compute_stats()`](https://rgt47.github.io/zzlongplot/reference/compute_stats.md):
  computes the per-timepoint summary statistics that drive the plot,
  optionally with hypothesis tests.

- [`generate_plot()`](https://rgt47.github.io/zzlongplot/reference/generate_plot.md):
  renders a statistics data frame as a ggplot.

Clinical trial support is provided by
[`suggest_clinical_vars()`](https://rgt47.github.io/zzlongplot/reference/suggest_clinical_vars.md),
[`validate_cdisc_data()`](https://rgt47.github.io/zzlongplot/reference/validate_cdisc_data.md),
and
[`get_cdisc_template()`](https://rgt47.github.io/zzlongplot/reference/get_cdisc_template.md).
Journal and regulatory styling is provided by
[`get_publication_theme()`](https://rgt47.github.io/zzlongplot/reference/get_publication_theme.md)
and the `theme_*()` family. Export helpers are
[`publication_panels()`](https://rgt47.github.io/zzlongplot/reference/publication_panels.md)
and
[`save_publication()`](https://rgt47.github.io/zzlongplot/reference/save_publication.md).

## See also

Useful links:

- <https://github.com/rgt47/zzlongplot>

- Report bugs at <https://github.com/rgt47/zzlongplot/issues>

## Author

**Maintainer**: Ronald G. Thomas <rgthomas@ucsd.edu>
([ORCID](https://orcid.org/0000-0003-1686-4965))

Authors:

- Ronald G. Thomas <rgthomas@ucsd.edu>
  ([ORCID](https://orcid.org/0000-0003-1686-4965))
