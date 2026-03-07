# CLAUDE.md - zzlongplot

This file provides guidance to Claude Code when working with this repository.

## Project Overview

**zzlongplot** is an R package for longitudinal data visualization with
specialized support for clinical trials and CDISC compliance. The package
provides a formula-based interface for creating publication-quality plots of
repeated measurements over time.

## Key Features

- Formula-based interface: `lplot(data, y ~ x | group)`
- Observed value plots and change-from-baseline visualizations
- Support for continuous and categorical time variables
- Uncertainty representation via error bars or confidence ribbons
- Sample size annotations with customizable placement and appearance
- Black-and-white print theme (`theme = "bw"`) with linetype/shape differentiation
- Clinical trial themes and CDISC compliance
- Faceting support for exploring interactions

## Package Structure

```
zzlongplot/
├── R/                    # Package functions
├── man/                  # Documentation (roxygen2 generated)
├── tests/testthat/       # Unit tests
├── vignettes/            # Package vignettes
│   ├── zzlongplot_introduction.Rmd
│   ├── sample-size-annotations.Rmd
│   ├── clinical-trials.Rmd
│   ├── cdisc-compliance.Rmd
│   ├── publication-themes.Rmd
│   ├── quickstart.Rmd
│   └── feature-enhancement-roadmap.Rmd
├── analysis/             # Research compendium (zzcollab)
│   ├── data/
│   ├── scripts/
│   └── report/
├── DESCRIPTION           # Package metadata
├── NAMESPACE             # Exports
├── Dockerfile            # Reproducible environment
├── Makefile              # Development commands
└── renv.lock             # Package dependencies
```

## Core Functions

| Function | Purpose |
|:---------|:--------|
| `lplot()` | Main function (plot_type: "obs", "change", "both") |
| `compute_stats()` | Summary statistics for longitudinal data |
| `generate_plot()` | Low-level ggplot2 plot builder |
| `parse_formula()` | Parse `y ~ x | group` formulas |
| `theme_bw_print()` | Black-and-white print theme |
| `theme_nature()` | Nature journal theme |
| `theme_nejm()` | NEJM journal theme |
| `theme_fda()` | FDA regulatory theme |
| `get_publication_theme()` | Theme dispatcher by name |

## Development Commands

```bash
make r              # Enter Docker container
make test           # Run tests
make check          # R CMD check
make docker-build   # Build Docker image
```

## Dependencies

- ggplot2: Plot generation
- dplyr: Data manipulation
- patchwork: Combining plots
- RColorBrewer: Color palettes

## Coding Standards

- Use native R pipe `|>` (R 4.1+)
- Use `<-` for assignment
- Follow snake_case naming
- roxygen2 documentation for all exports
- testthat (edition 3) for testing

## Clinical Trial Features

The package includes specialized support for clinical trials:

- CDISC-compliant variable naming
- Regulatory submission themes
- FDA/EMA publication standards
- Safety and efficacy plot templates

## Testing

```r
# Run all tests
devtools::test()

# Run specific test file
testthat::test_file("tests/testthat/test-lplot.R")
```

## Author

Ronald (Ryy) G. Thomas (rgthomas@ucsd.edu)
