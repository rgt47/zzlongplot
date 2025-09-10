# zzlongplot 0.0.0.1000

## New Features - Clinical Trials Support 🏥

* **Clinical Mode**: New `clinical_mode = TRUE` parameter enables clinical trial defaults
* **CDISC Compliance**: Automatic recognition of standard CDISC variable names (USUBJID, AVISITN, AVAL, TRT01P)
* **Treatment Styling**: Predefined color schemes with `treatment_colors = "standard"`
* **Clinical Statistics**: 95% confidence intervals and sample size annotations
* **Regulatory Themes**: Professional themes suitable for FDA/EMA submissions
* **Visit Windows**: Support for clinical trial visit timing variations

## New Parameters

* `clinical_mode`: Enable all clinical defaults at once
* `treatment_colors`: Predefined treatment color schemes  
* `confidence_interval`: Confidence level for error bounds (e.g., 0.95)
* `show_sample_sizes`: Display sample sizes at each timepoint
* `visit_windows`: Handle visit timing variations
* `theme`: Regulatory-compliant themes

## New Clinical Utilities (Planned)

* `suggest_clinical_vars()`: Auto-detect CDISC variables
* `get_clinical_theme()`: Regulatory-ready themes
* `clinical_colors()`: Standard clinical color palettes
* `save_clinical_plot()`: Export in regulatory formats

## Documentation

* **New Vignettes**: 
  - "Clinical Trials with zzlongplot"
  - "CDISC Compliance and Standards"
* **Enhanced README**: Clinical examples and feature overview
* **Function Documentation**: Added clinical examples and parameter descriptions

## Package Modernization

* **Modular Structure**: Split large function file into logical modules
* **GitHub Actions**: Complete CI/CD pipeline with automated testing
* **Code Quality**: Added linting, styling, and coverage reporting  
* **Dependency Management**: Moved RColorBrewer to Imports
* **Version Requirements**: Minimum R 4.1.0

## Bug Fixes

* Fixed parameter naming inconsistency (`zeroval` → `baseline_value`)
* Updated README examples to match function signatures
* Improved error handling and input validation
* Fixed NAMESPACE exports

---

# zzlongplot 0.0.0.999

## Initial Release

* Basic longitudinal plotting functionality
* Support for observed and change from baseline plots
* Formula interface for variable specification
* Grouping and faceting capabilities
* Error representation (bars and ribbons)
* Patchwork integration for combined plots