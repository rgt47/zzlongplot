#' Publication-Ready Plot Export Functions
#'
#' @description
#' Functions for exporting plots in publication-ready formats with journal-specific
#' specifications for dimensions, resolution, and formatting.
#'
#' @details
#' These functions automatically apply the correct specifications for major
#' scientific journals and regulatory agencies, ensuring plots meet submission
#' requirements without manual formatting.

# Journal specifications database
.journal_specs <- list(
  
  nature = list(
    name = "Nature",
    single_column_mm = 90,
    double_column_mm = 180, 
    max_height_mm = 170,
    min_dpi = 600,
    preferred_dpi = 600,
    font_size = 8,
    font_family = "sans",
    formats = c("pdf", "eps", "tiff"),
    color_mode = "RGB",
    notes = "Nature Publishing Group standards"
  ),
  
  science = list(
    name = "Science",
    single_column_mm = 85,
    double_column_mm = 178,
    max_height_mm = 170,
    min_dpi = 300,
    preferred_dpi = 600,
    font_size = 7,
    font_family = "sans", 
    formats = c("pdf", "eps", "tiff", "png"),
    color_mode = "RGB",
    notes = "AAAS Science journal standards"
  ),
  
  nejm = list(
    name = "New England Journal of Medicine",
    single_column_mm = 85,
    double_column_mm = 170,
    max_height_mm = 200,
    min_dpi = 600,
    preferred_dpi = 600,
    font_size = 8,
    font_family = "sans",
    formats = c("tiff", "eps", "pdf"),
    color_mode = "RGB",
    notes = "Clinical publication standards"
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
  
  fda = list(
    name = "FDA Regulatory",
    single_column_mm = 100,
    double_column_mm = 200,
    max_height_mm = 250,
    min_dpi = 600,
    preferred_dpi = 600,
    font_size = 10,
    font_family = "sans",
    formats = c("pdf", "tiff"),
    color_mode = "RGB",
    notes = "FDA regulatory submission standards"
  ),
  
  ema = list(
    name = "EMA Regulatory", 
    single_column_mm = 100,
    double_column_mm = 200,
    max_height_mm = 250,
    min_dpi = 600,
    preferred_dpi = 600,
    font_size = 10,
    font_family = "sans",
    formats = c("pdf", "tiff"),
    color_mode = "RGB",
    notes = "EMA regulatory submission standards"
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
#' @param width_mm Numeric. Plot width in millimeters. 
#'   If NULL, uses journal's single column width.
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
#' # Save for Nature journal
#' save_publication(p, "figure1.pdf", journal = "nature")
#' 
#' # Save with panel label for multi-panel figure
#' save_publication(p, "figure1a.pdf", journal = "nature", 
#'                  panel_label = "A", column_type = "single")
#' 
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
  
  # Set width based on column type
  if (is.null(width_mm)) {
    width_mm <- if (column_type == "single") {
      specs$single_column_mm
    } else {
      specs$double_column_mm
    }
  }
  
  # Set DPI
  if (is.null(dpi)) {
    dpi <- specs$preferred_dpi
  } else if (dpi < specs$min_dpi) {
    warning(sprintf("DPI %d is below %s minimum of %d DPI", 
                    dpi, specs$name, specs$min_dpi))
  }
  
  # Add panel label if specified
  if (!is.null(panel_label) && add_label_to_plot) {
    plot <- plot + 
      ggplot2::annotation_custom(
        ggplot2::ggplotGrob(
          ggplot2::ggplot() + 
            ggplot2::annotate("text", x = 0, y = 0, label = panel_label, 
                             size = specs$font_size * 1.5, fontface = "bold") +
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
    
    # Ensure within journal limits
    if (height_mm > specs$max_height_mm) {
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
#' @param spacing Numeric. Spacing between panels.
#'
#' @return A combined plot object (patchwork or equivalent).
#'
#' @examples
#' \dontrun{
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
#' # Save the combined figure
#' save_publication(fig, "figure1.pdf", journal = "nature", column_type = "double")
#' }
#' 
#' @export
publication_panels <- function(plots, labels = NULL, layout = "horizontal",
                               ncol = NULL, nrow = NULL, shared_legend = FALSE,
                               legend_position = "bottom", label_size = 12,
                               label_face = "bold", spacing = 0.02) {
  
  if (!requireNamespace("patchwork", quietly = TRUE)) {
    stop("patchwork package required for multi-panel figures. Install with: install.packages('patchwork')")
  }
  
  # Validate inputs
  if (!is.list(plots)) {
    stop("plots must be a list of ggplot objects")
  }
  
  n_plots <- length(plots)
  
  # Generate labels if not provided
  if (is.null(labels)) {
    labels <- LETTERS[1:n_plots]
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
  
  # Apply spacing
  if (layout %in% c("horizontal", "vertical")) {
    combined <- combined + patchwork::plot_layout(
      heights = if (layout == "vertical") rep(1, n_plots) else NULL,
      widths = if (layout == "horizontal") rep(1, n_plots) else NULL
    )
  }
  
  return(combined)
}

#' Get Journal Specifications
#'
#' @description
#' Returns formatting specifications for a specific journal.
#'
#' @param journal Character string specifying journal name.
#'
#' @return List containing journal specifications.
#'
#' @examples
#' nature_specs <- get_journal_specs("nature")
#' print(nature_specs$preferred_dpi)
#' 
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
#' @return Data frame of journal specifications.
#'
#' @examples
#' list_journals()
#' list_journals(detailed = TRUE)
#' 
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