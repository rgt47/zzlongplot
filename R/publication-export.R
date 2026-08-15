# Publication-Ready Plot Export Functions
#
# Functions for exporting plots in publication-ready formats with
# journal-specific specifications for dimensions, resolution, and
# formatting. They apply the correct specifications for major scientific
# journals and regulatory agencies without manual formatting.

# Journal specifications database
.journal_specs <- list(
  
  # Widths and the 5-7 pt type range are from Nature's production-stage
  # sources, which agree with each other:
  #   https://www.nature.com/nature/for-authors/final-submission
  #   https://www.nature.com/documents/nature-final-artwork.pdf
  #   https://research-figure-guide.nature.com/figures/preparing-figures-our-specifications/
  # Nature's initial-submission page says 90/180 mm; the three
  # production sources say 89/183 mm, so those are used here.
  # max_height_mm 170 is the usable figure height (page depth is
  # 247 mm, the remainder being reserved for the legend).
  nature = list(
    name = "Nature",
    single_column_mm = 89,
    double_column_mm = 183,
    max_height_mm = 170,
    min_dpi = 300,
    preferred_dpi = 600,
    font_size = 7,
    font_family = "sans",
    formats = c("pdf", "eps", "tiff"),
    color_mode = "RGB",
    notes = paste(
      "Nature: type 5-7 pt at final size; 89 mm single,",
      "183 mm double column; vector preferred, text must stay live."
    )
  ),

  # Science publishes two incompatible column grids. The 2025 author
  # preparation guide uses the two-column grid (9 cm / 18.3 cm), which
  # is what is encoded here:
  #   https://www.science.org/cms/asset/67f37ac8-4d02-4625-8a05-230568cb8323/author_prep_guide_2025.pdf
  # The older three-column grid (5.7 / 12.1 / 18.4 cm) still appears at
  #   https://www.science.org/content/page/instructions-preparing-initial-manuscript
  # Science publishes no maximum figure height, so max_height_mm is NA
  # and no height cap is applied.
  science = list(
    name = "Science",
    single_column_mm = 90,
    double_column_mm = 183,
    max_height_mm = NA_real_,
    min_dpi = 300,
    preferred_dpi = 600,
    font_size = 7,
    font_family = "sans",
    formats = c("pdf", "eps", "tiff", "png"),
    color_mode = "RGB",
    notes = paste(
      "Science: 2025 guide two-column grid (90/183 mm); type ~5-9 pt;",
      "no published maximum height; save R graphics as vector SVG."
    )
  ),
  
  # NEJM's Technical Guidelines for Figures state accepted formats and a
  # single resolution rule (1200 dpi, for black-and-white line art
  # submitted as BMP). They state no column widths, no maximum height,
  # no type size, and no color mode:
  #   https://www.nejm.org/pb-assets/pdfs/Technical-Guidelines-for-Figures-1511366945697.pdf
  #   https://www.nejm.org/author-center/new-manuscripts
  # Those fields are therefore NA rather than invented; save_publication()
  # falls back to general print defaults and says so. NEJM redraws all
  # accepted figures in its own house style, so what matters at
  # submission is a vector file with live text carrying the complete
  # data and labels, not a pixel-faithful rendering.
  nejm = list(
    name = "New England Journal of Medicine",
    single_column_mm = NA_real_,
    double_column_mm = NA_real_,
    max_height_mm = NA_real_,
    min_dpi = NA_real_,
    preferred_dpi = NA_real_,
    font_size = NA_real_,
    font_family = NA_character_,
    formats = c("ai", "pdf", "eps", "tiff", "psd", "jpeg"),
    color_mode = NA_character_,
    notes = paste(
      "NEJM prefers Adobe Illustrator or unlocked vector PDF for graphs;",
      "EPS, TIFF, PSD and maximum-quality JPEG are accepted but not",
      "preferred. 1200 dpi applies to black-and-white line art in BMP.",
      "No column width, height, type size or color mode is published;",
      "all accepted figures are redrawn in house style."
    )
  ),
  
  cell = list(
    name = "Cell",
    single_column_mm = 85,
    double_column_mm = 178,
    max_height_mm = 234,
    min_dpi = 300,
    preferred_dpi = 600,
    font_size = 8,
    font_family = "sans",
    formats = c("pdf", "eps", "tiff"),
    color_mode = "RGB",
    notes = "Cell Press standards"
  ),
  
  # FDA and EMA are regulators, not journals: they specify the
  # submission *document*, not a figure column grid, so there is no
  # single-column width and single_column_mm is NA. The widths below
  # are the usable print area implied by the stated page size and
  # margins, which is the largest a figure can be.
  #
  # FDA, Portable Document Format (PDF) Specifications (incorporated by
  # reference into the eCTD guidance):
  #   https://www.fda.gov/files/drugs/published/Portable-Document-Format-Specifications.pdf
  #   "Set up the print area for pages to fit on a sheet of paper that
  #    is 8.5 inches by 11 inches. A margin of at least 3/4 of an inch
  #    on the left side ... at least 3/8 of an inch on the other sides"
  #    -> 215.9 - 19.05 - 9.525 = 187.3 mm wide, 260.4 mm tall.
  #   "Use font sizes ranging from 9 to 12 point." Times New Roman
  #    12 pt for narrative, 9-10 pt in tables, 10 pt footnotes.
  #   Scanning table: plotter output graphics 300 dpi; photographs
  #    600 dpi. "Black is the recommended font color."
  #   Image colour matching: "for printing, there is more control over
  #    the color by using CMYK ... as opposed to the RGB model."
  fda = list(
    name = "FDA Regulatory",
    single_column_mm = NA_real_,
    double_column_mm = 187,
    max_height_mm = 260,
    min_dpi = 300,
    preferred_dpi = 600,
    font_size = 12,
    font_family = "Times New Roman",
    formats = "pdf",
    color_mode = "CMYK",
    notes = paste(
      "FDA PDF Specifications: print area fits 8.5 x 11 in with 3/4 in",
      "binding and 3/8 in other margins, giving 187 x 260 mm usable.",
      "Type 9-12 pt, 12 pt Times New Roman for narrative, black.",
      "300 dpi for plotter graphics and 600 dpi for photographs apply",
      "to scanned images; submit vector PDF where possible.",
      "No figure column grid is defined."
    )
  ),

  # EMA's Harmonised Technical Guidance for eCTD Submissions in the EU
  # (v4.0) specifies only PDF version, font embedding, tagging and Fast
  # Web View, and defers PDF detail to the ICH specification:
  #   https://esubmission.ema.europa.eu/tiges/docs/eCTD%20Guidance%20v4%200-20160422-final.pdf
  # The operative numbers are therefore ICH's, Specification for PDF
  # Formatted Documents in Regulatory Submissions v1.0, section 2.6:
  #   https://admin.ich.org/sites/default/files/inline-files/Specification_for_PDF_Format_v1_0.pdf
  #   "The print area for pages should fit on both a sheet of A4
  #    (210 x 297 mm) and Letter (8.5" x 11") paper. A sufficient
  #    margin of at least 2.5 cm on the binding edge ... The remaining
  #    margins should be a minimum of 1.0 cm."
  #    -> 210 - 25 - 10 = 175 mm wide; 279.4 - 20 = 259 mm tall.
  #   Section 2.4.1: "You should use font sizes ranging from 9 to 12
  #    points." Section 2.4.2: "The use of a black font colour is
  #    recommended." Same scanning dpi table as FDA.
  ema = list(
    name = "EMA Regulatory",
    single_column_mm = NA_real_,
    double_column_mm = 175,
    max_height_mm = 259,
    min_dpi = 300,
    preferred_dpi = 600,
    font_size = 12,
    font_family = "Times New Roman",
    formats = "pdf",
    color_mode = NA_character_,
    notes = paste(
      "EMA defers PDF detail to the ICH PDF specification: print area",
      "must fit both A4 and Letter with a 2.5 cm binding margin and",
      "1.0 cm elsewhere, giving 175 x 259 mm usable. Type 9-12 pt,",
      "black. Embed all fonts. 300/600 dpi apply to scanned images;",
      "submit vector PDF where possible. EMA states no colour mode.",
      "No figure column grid is defined."
    )
  )
)

#' Save Publication-Ready Plot
#'
#' @description
#' Exports a ggplot object in publication-ready format with automatic application
#' of journal-specific specifications.
#'
#' @param plot A ggplot object to be saved.
#' @param filename Character string specifying the output filename. 
#'   File extension determines format if not specified in format parameter.
#' @param journal Character string specifying journal name. 
#'   Options: "nature", "science", "nejm", "cell", "fda", "ema".
#' @param width_mm Numeric. Plot width in millimeters. If NULL, uses
#'   the journal's column width for `column_type`. When the journal
#'   publishes no width (see [get_journal_specs()]), a general print
#'   default of 90 mm single / 180 mm double is substituted and a
#'   message names it as the package's default rather than the
#'   journal's.
#' @param height_mm Numeric. Plot height in millimeters. 
#'   If NULL, calculated from plot aspect ratio.
#' @param dpi Numeric. Resolution in dots per inch. 
#'   If NULL, uses journal's preferred DPI.
#' @param format Character string specifying file format. 
#'   If NULL, detected from filename extension.
#' @param column_type Character string. Either "single" or "double" for
#'   journal column specifications.
#' @param panel_label Character string. Panel label for multi-panel figures (e.g., "A", "B").
#' @param add_label_to_plot Logical. If TRUE, adds panel label directly to plot.
#' @param ... Additional arguments passed to ggsave().
#'
#' @return Invisible path to saved file.
#'
#' @examples
#' library(ggplot2)
#' 
#' # Create example plot
#' p <- ggplot(mtcars, aes(wt, mpg, color = factor(cyl))) + 
#'   geom_point() + 
#'   theme_nature()
#' 
#' # Save for Nature journal (written to a temporary directory here so
#' # the example does not create files in the working directory)
#' save_publication(p, file.path(tempdir(), "figure1.pdf"),
#'                  journal = "nature")
#'
#' # Save with panel label for multi-panel figure
#' save_publication(p, file.path(tempdir(), "figure1a.pdf"),
#'                  journal = "nature",
#'                  panel_label = "A", column_type = "single")
#'
#' @family publication export
#' @export
save_publication <- function(plot, filename, journal = "nature",
                             width_mm = NULL, height_mm = NULL, dpi = NULL,
                             format = NULL, column_type = "double",
                             panel_label = NULL, add_label_to_plot = FALSE, ...) {
  
  # Validate journal
  if (!journal %in% names(.journal_specs)) {
    stop(sprintf("Unknown journal '%s'. Available journals: %s",
                 journal, paste(names(.journal_specs), collapse = ", ")))
  }
  
  specs <- .journal_specs[[journal]]
  
  # Determine format from filename if not specified
  if (is.null(format)) {
    format <- tools::file_ext(filename)
    if (format == "") {
      format <- "pdf"  # Default format
      filename <- paste0(filename, ".pdf")
    }
  }
  
  # Validate format
  if (!format %in% specs$formats) {
    warning(sprintf("Format '%s' not recommended for %s. Recommended formats: %s",
                    format, specs$name, paste(specs$formats, collapse = ", ")))
  }
  
  # Some journals publish no dimensional specification at all. Rather
  # than invent one, those fields are NA and a general print default is
  # substituted, recorded here so the caller is told which numbers are
  # the journal's and which are ours.
  substituted <- character(0)
  spec_or <- function(value, default, label) {
    if (is.null(value) || length(value) != 1 || is.na(value)) {
      substituted <<- c(substituted, label)
      default
    } else {
      value
    }
  }

  # Set width based on column type
  if (is.null(width_mm)) {
    width_mm <- if (column_type == "single") {
      spec_or(specs$single_column_mm, 90, "column width")
    } else {
      spec_or(specs$double_column_mm, 180, "column width")
    }
  }

  # Set DPI
  if (is.null(dpi)) {
    dpi <- spec_or(specs$preferred_dpi, 600, "resolution")
  } else if (!is.na(specs$min_dpi) && dpi < specs$min_dpi) {
    warning(sprintf("DPI %d is below %s minimum of %d DPI",
                    dpi, specs$name, specs$min_dpi))
  }

  if (length(substituted) > 0) {
    message(sprintf(
      paste0("%s publishes no %s specification; using the package ",
             "default (%d mm wide at %d dpi). Pass width_mm and dpi ",
             "explicitly to override."),
      specs$name, paste(unique(substituted), collapse = " or "),
      round(width_mm), round(dpi)
    ))
  }

  # Add panel label if specified
  if (!is.null(panel_label) && add_label_to_plot) {
    plot <- plot + 
      ggplot2::annotation_custom(
        ggplot2::ggplotGrob(
          ggplot2::ggplot() + 
            ggplot2::annotate("text", x = 0, y = 0, label = panel_label,
                             size = spec_or(specs$font_size, 10,
                                            "type size") * 1.5,
                             fontface = "bold") +
            ggplot2::theme_void()
        ),
        xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf
      )
  }
  
  # Calculate height if not specified (maintain aspect ratio)
  if (is.null(height_mm)) {
    # Get plot build to calculate aspect ratio
    plot_build <- ggplot2::ggplot_build(plot)
    plot_gtable <- ggplot2::ggplot_gtable(plot_build)
    
    # Default to golden ratio if can't calculate
    aspect_ratio <- 1.618  # Golden ratio
    height_mm <- width_mm / aspect_ratio
    
    # Ensure within journal limits. max_height_mm is NA for journals
    # that publish no maximum, in which case no cap is applied.
    if (!is.na(specs$max_height_mm) &&
        height_mm > specs$max_height_mm) {
      height_mm <- specs$max_height_mm
      warning(sprintf("Height adjusted to %s maximum of %d mm",
                      specs$name, specs$max_height_mm))
    }
  }
  
  # Save the plot
  ggplot2::ggsave(
    filename = filename,
    plot = plot,
    width = width_mm,
    height = height_mm,
    units = "mm",
    dpi = dpi,
    device = format,
    ...
  )
  
  # Print summary
  cat(sprintf("Plot saved for %s:\n", specs$name))
  cat(sprintf("  File: %s\n", filename))
  cat(sprintf("  Dimensions: %d x %d mm\n", round(width_mm), round(height_mm)))
  cat(sprintf("  Resolution: %d DPI\n", dpi))
  cat(sprintf("  Format: %s\n", toupper(format)))
  if (!is.null(panel_label)) {
    cat(sprintf("  Panel: %s\n", panel_label))
  }
  
  return(invisible(filename))
}

#' Create Multi-Panel Publication Figure
#'
#' @description
#' Combines multiple plots into a publication-ready multi-panel figure
#' with automatic panel labeling and consistent formatting.
#'
#' @param plots List of ggplot objects to combine.
#' @param labels Character vector of panel labels (e.g., c("A", "B", "C")).
#' @param layout Character string specifying layout: "horizontal", "vertical", or "grid".
#' @param ncol Integer. Number of columns for grid layout.
#' @param nrow Integer. Number of rows for grid layout.
#' @param shared_legend Logical. Whether to use a shared legend.
#' @param legend_position Character string specifying shared legend position.
#' @param label_size Numeric. Size of panel labels.
#' @param label_face Character string. Font face for panel labels ("bold", "italic", etc.).
#' @param spacing Numeric. Margin added around each panel, in `npc`
#'   units (fraction of the panel region). Default `0.02`.
#'
#' @return A `patchwork` object combining `plots`, with class
#'   `c("patchwork", "gg", "ggplot")`. It prints like a ggplot and can
#'   be passed to [save_publication()] or [ggplot2::ggsave()].
#'
#' @seealso [save_publication()] to write the result to a
#'   journal-specified file; [get_publication_theme()] and the
#'   `theme_*()` family for styling the individual panels.
#'
#' @examples
#' library(ggplot2)
#'
#' # Create individual plots
#' p1 <- ggplot(mtcars, aes(wt, mpg)) + geom_point() + theme_nature()
#' p2 <- ggplot(mtcars, aes(hp, mpg)) + geom_point() + theme_nature()
#'
#' # Combine into publication figure
#' fig <- publication_panels(
#'   plots = list(p1, p2),
#'   labels = c("A", "B"),
#'   layout = "horizontal"
#' )
#'
#' # Save the combined figure to a temporary location
#' out <- file.path(tempdir(), "figure1.pdf")
#' save_publication(fig, out, journal = "nature", column_type = "double")
#'
#' @family publication export
#' @export
publication_panels <- function(plots, labels = NULL, layout = "horizontal",
                               ncol = NULL, nrow = NULL, shared_legend = FALSE,
                               legend_position = "bottom", label_size = 12,
                               label_face = "bold", spacing = 0.02) {

  if (!is.list(plots) || length(plots) == 0) {
    stop("'plots' must be a non-empty list of ggplot objects.")
  }
  not_ggplot <- which(!vapply(plots, inherits, logical(1), "ggplot"))
  if (length(not_ggplot) > 0) {
    stop(sprintf(
      "All elements of 'plots' must be ggplot objects; element(s) %s are not.",
      paste(not_ggplot, collapse = ", ")
    ))
  }
  if (!is.numeric(spacing) || length(spacing) != 1 || is.na(spacing) ||
      spacing < 0) {
    stop("'spacing' must be a single non-negative number.")
  }

  n_plots <- length(plots)

  # Generate labels if not provided
  if (is.null(labels)) {
    labels <- LETTERS[seq_len(n_plots)]
  } else if (length(labels) != n_plots) {
    stop("Number of labels must match number of plots")
  }
  
  # Add panel labels to plots
  labeled_plots <- mapply(function(plot, label) {
    plot + 
      ggplot2::labs(tag = label) +
      ggplot2::theme(
        plot.tag = ggplot2::element_text(
          size = label_size, 
          face = label_face,
          hjust = 0, vjust = 1
        ),
        plot.tag.position = c(0.02, 0.98)
      )
  }, plots, labels, SIMPLIFY = FALSE)
  
  # Determine layout
  if (layout == "horizontal") {
    combined <- Reduce(`+`, labeled_plots)
  } else if (layout == "vertical") {
    combined <- Reduce(`/`, labeled_plots)  # patchwork vertical operator
  } else if (layout == "grid") {
    if (is.null(ncol) && is.null(nrow)) {
      # Auto-determine grid dimensions
      ncol <- ceiling(sqrt(n_plots))
      nrow <- ceiling(n_plots / ncol)
    }
    combined <- patchwork::wrap_plots(labeled_plots, ncol = ncol, nrow = nrow)
  } else {
    stop("layout must be 'horizontal', 'vertical', or 'grid'")
  }
  
  # Apply shared legend if requested
  if (shared_legend) {
    combined <- combined + patchwork::plot_layout(guides = "collect") &
      ggplot2::theme(legend.position = legend_position)
  }
  
  # Apply equal panel sizing and the requested inter-panel spacing.
  if (layout %in% c("horizontal", "vertical")) {
    combined <- combined + patchwork::plot_layout(
      heights = if (layout == "vertical") rep(1, n_plots) else NULL,
      widths = if (layout == "horizontal") rep(1, n_plots) else NULL
    )
  }

  combined <- combined &
    ggplot2::theme(
      plot.margin = ggplot2::unit(rep(spacing, 4), "npc")
    )
  
  return(combined)
}

#' Get Journal Specifications
#'
#' @description
#' Returns formatting specifications for a specific journal.
#'
#' @param journal Character string specifying journal name.
#'
#' @return A list of 11 elements describing the journal's figure
#'   requirements: `name` (display name), `single_column_mm` and
#'   `double_column_mm` (figure widths), `max_height_mm`, `min_dpi` and
#'   `preferred_dpi`, `font_size` (points), `font_family`, `formats`
#'   (character vector of accepted file extensions), `color_mode`
#'   (e.g. `"RGB"` or `"CMYK"`), and `notes` (free text).
#'
#'   Any element is `NA` when the journal does not publish that
#'   specification. `NA` means "not stated by the journal", never
#'   "unknown to this package": no value here is inferred or assumed.
#'   The *New England Journal of Medicine*, for instance, publishes
#'   accepted formats but no width, height, type size, or color mode,
#'   because it redraws every accepted figure in its own house style.
#'   [save_publication()] substitutes a general print default for any
#'   `NA` it needs and reports having done so.
#'
#' @seealso [list_journals()] for all journals at once, and
#'   [save_publication()] which applies these specifications.
#'
#' @examples
#' nature_specs <- get_journal_specs("nature")
#' print(nature_specs$preferred_dpi)
#' 
#' @family publication export
#' @export
get_journal_specs <- function(journal) {
  
  if (!journal %in% names(.journal_specs)) {
    stop(sprintf("Unknown journal '%s'. Available journals: %s",
                 journal, paste(names(.journal_specs), collapse = ", ")))
  }
  
  return(.journal_specs[[journal]])
}

#' List Available Publication Journals
#'
#' @description
#' Lists all available journal specifications with their key requirements.
#'
#' @param detailed Logical. If TRUE, shows detailed specifications.
#'
#' @return A data frame with one row per supported journal, with row
#'   names set to the journal keys. Columns are `journal` (the key to
#'   pass to [save_publication()]), `name`, `single_column_mm`,
#'   `double_column_mm`, `preferred_dpi`, and `font_size`. When
#'   `detailed = TRUE`, the columns `max_height_mm`, `formats`, and
#'   `notes` are appended.
#'
#' @seealso [get_journal_specs()] for the full specification of one
#'   journal, and [save_publication()] to apply it.
#'
#' @examples
#' list_journals()
#' list_journals(detailed = TRUE)
#' 
#' @family publication export
#' @export
list_journals <- function(detailed = FALSE) {
  
  journals_df <- data.frame(
    journal = names(.journal_specs),
    name = sapply(.journal_specs, function(x) x$name),
    single_column_mm = sapply(.journal_specs, function(x) x$single_column_mm),
    double_column_mm = sapply(.journal_specs, function(x) x$double_column_mm),
    preferred_dpi = sapply(.journal_specs, function(x) x$preferred_dpi),
    font_size = sapply(.journal_specs, function(x) x$font_size),
    stringsAsFactors = FALSE
  )
  
  if (detailed) {
    journals_df$max_height_mm <- sapply(.journal_specs, function(x) x$max_height_mm)
    journals_df$formats <- sapply(.journal_specs, function(x) paste(x$formats, collapse = ", "))
    journals_df$notes <- sapply(.journal_specs, function(x) x$notes)
  }
  
  return(journals_df)
}
