# List Available Publication Journals

Lists all available journal specifications with their key requirements.

## Usage

``` r
list_journals(detailed = FALSE)
```

## Arguments

- detailed:

  Logical. If TRUE, shows detailed specifications.

## Value

Data frame of journal specifications.

## Examples

``` r
list_journals()
#>         journal                            name single_column_mm
#> nature   nature                          Nature               90
#> science science                         Science               85
#> nejm       nejm New England Journal of Medicine               85
#> cell       cell                            Cell               85
#> fda         fda                  FDA Regulatory              100
#> ema         ema                  EMA Regulatory              100
#>         double_column_mm preferred_dpi font_size
#> nature               180           600         8
#> science              178           600         7
#> nejm                 170           600         8
#> cell                 178           600         8
#> fda                  200           600        10
#> ema                  200           600        10
list_journals(detailed = TRUE)
#>         journal                            name single_column_mm
#> nature   nature                          Nature               90
#> science science                         Science               85
#> nejm       nejm New England Journal of Medicine               85
#> cell       cell                            Cell               85
#> fda         fda                  FDA Regulatory              100
#> ema         ema                  EMA Regulatory              100
#>         double_column_mm preferred_dpi font_size max_height_mm
#> nature               180           600         8           170
#> science              178           600         7           170
#> nejm                 170           600         8           200
#> cell                 178           600         8           234
#> fda                  200           600        10           250
#> ema                  200           600        10           250
#>                     formats                               notes
#> nature       pdf, eps, tiff   Nature Publishing Group standards
#> science pdf, eps, tiff, png      AAAS Science journal standards
#> nejm         tiff, eps, pdf      Clinical publication standards
#> cell         pdf, eps, tiff                Cell Press standards
#> fda               pdf, tiff FDA regulatory submission standards
#> ema               pdf, tiff EMA regulatory submission standards
```
