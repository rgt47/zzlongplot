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

List containing journal specifications.

## Examples

``` r
nature_specs <- get_journal_specs("nature")
print(nature_specs$preferred_dpi)
#> [1] 600
```
