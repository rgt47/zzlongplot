# Detect Baseline Value from Visit Variable

Identifies a likely baseline value from a vector of visit codes. For
numeric vectors, returns the minimum value. For character/factor
vectors, matches against common baseline labels (case-insensitive):
'baseline', 'bl', 'base', 'screening', 'scr', 'day 0', 'week 0', 'visit
1', 'v1', 'pre'. Exactly one match must be found; zero or multiple
matches produce an error.

## Usage

``` r
detect_baseline(x)
```

## Arguments

- x:

  A vector of visit codes (numeric, character, or factor).

## Value

A single baseline value.
