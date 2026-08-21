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

A data frame with one row per supported journal, with row names set to
the journal keys. Columns are `journal` (the key to pass to
[`save_publication()`](https://rgt47.github.io/zzlongplot/reference/save_publication.md)),
`name`, `single_column_mm`, `double_column_mm`, `preferred_dpi`, and
`font_size`. When `detailed = TRUE`, the columns `max_height_mm`,
`formats`, and `notes` are appended.

## See also

[`get_journal_specs()`](https://rgt47.github.io/zzlongplot/reference/get_journal_specs.md)
for the full specification of one journal, and
[`save_publication()`](https://rgt47.github.io/zzlongplot/reference/save_publication.md)
to apply it.

Other publication export:
[`get_journal_specs()`](https://rgt47.github.io/zzlongplot/reference/get_journal_specs.md),
[`publication_panels()`](https://rgt47.github.io/zzlongplot/reference/publication_panels.md),
[`save_publication()`](https://rgt47.github.io/zzlongplot/reference/save_publication.md)

## Examples

``` r
list_journals()
#>         journal                            name single_column_mm
#> nature   nature                          Nature               89
#> science science                         Science               90
#> nejm       nejm New England Journal of Medicine               NA
#> cell       cell                            Cell               85
#> fda         fda                  FDA Regulatory               NA
#> ema         ema                  EMA Regulatory               NA
#>         double_column_mm preferred_dpi font_size
#> nature               183           600         7
#> science              183           600         7
#> nejm                  NA            NA        NA
#> cell                 178           600         8
#> fda                  187           600        12
#> ema                  175           600        12
list_journals(detailed = TRUE)
#>         journal                            name single_column_mm
#> nature   nature                          Nature               89
#> science science                         Science               90
#> nejm       nejm New England Journal of Medicine               NA
#> cell       cell                            Cell               85
#> fda         fda                  FDA Regulatory               NA
#> ema         ema                  EMA Regulatory               NA
#>         double_column_mm preferred_dpi font_size max_height_mm
#> nature               183           600         7           170
#> science              183           600         7            NA
#> nejm                  NA            NA        NA            NA
#> cell                 178           600         8           234
#> fda                  187           600        12           260
#> ema                  175           600        12           259
#>                               formats
#> nature                 pdf, eps, tiff
#> science           pdf, eps, tiff, png
#> nejm    ai, pdf, eps, tiff, psd, jpeg
#> cell                   pdf, eps, tiff
#> fda                               pdf
#> ema                               pdf
#>                                                                                                                                                                                                                                                                                                                                                       notes
#> nature                                                                                                                                                                                                                                        Nature: type 5-7 pt at final size; 89 mm single, 183 mm double column; vector preferred, text must stay live.
#> science                                                                                                                                                                                                                          Science: 2025 guide two-column grid (90/183 mm); type ~5-9 pt; no published maximum height; save R graphics as vector SVG.
#> nejm                                         NEJM prefers Adobe Illustrator or unlocked vector PDF for graphs; EPS, TIFF, PSD and maximum-quality JPEG are accepted but not preferred. 1200 dpi applies to black-and-white line art in BMP. No column width, height, type size or color mode is published; all accepted figures are redrawn in house style.
#> cell                                                                                                                                                                                                                                                                                                                                   Cell Press standards
#> fda           FDA PDF Specifications: print area fits 8.5 x 11 in with 3/4 in binding and 3/8 in other margins, giving 187 x 260 mm usable. Type 9-12 pt, 12 pt Times New Roman for narrative, black. 300 dpi for plotter graphics and 600 dpi for photographs apply to scanned images; submit vector PDF where possible. No figure column grid is defined.
#> ema     EMA defers PDF detail to the ICH PDF specification: print area must fit both A4 and Letter with a 2.5 cm binding margin and 1.0 cm elsewhere, giving 175 x 259 mm usable. Type 9-12 pt, black. Embed all fonts. 300/600 dpi apply to scanned images; submit vector PDF where possible. EMA states no colour mode. No figure column grid is defined.
```
