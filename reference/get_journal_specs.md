# Get Journal Specifications

Returns formatting specifications for a specific journal.

## Usage

``` r
get_journal_specs(journal)
```

## Arguments

- journal:

  Character string specifying journal name.

## Value

A list of 11 elements describing the journal's figure requirements:
`name` (display name), `single_column_mm` and `double_column_mm` (figure
widths), `max_height_mm`, `min_dpi` and `preferred_dpi`, `font_size`
(points), `font_family`, `formats` (character vector of accepted file
extensions), `color_mode` (e.g. `"RGB"` or `"CMYK"`), and `notes` (free
text).

Any element is `NA` when the journal does not publish that
specification. `NA` means "not stated by the journal", never "unknown to
this package": no value here is inferred or assumed. The *New England
Journal of Medicine*, for instance, publishes accepted formats but no
width, height, type size, or color mode, because it redraws every
accepted figure in its own house style.
[`save_publication()`](https://rgt47.github.io/zzlongplot/reference/save_publication.md)
substitutes a general print default for any `NA` it needs and reports
having done so.

## See also

[`list_journals()`](https://rgt47.github.io/zzlongplot/reference/list_journals.md)
for all journals at once, and
[`save_publication()`](https://rgt47.github.io/zzlongplot/reference/save_publication.md)
which applies these specifications.

Other publication export:
[`list_journals()`](https://rgt47.github.io/zzlongplot/reference/list_journals.md),
[`publication_panels()`](https://rgt47.github.io/zzlongplot/reference/publication_panels.md),
[`save_publication()`](https://rgt47.github.io/zzlongplot/reference/save_publication.md)

## Examples

``` r
nature_specs <- get_journal_specs("nature")
print(nature_specs$preferred_dpi)
#> [1] 600
```
