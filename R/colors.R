#' Create a Color-Blind Friendly Palette
#'
#' @description
#' Generates a colorblind-friendly palette for use in plots.
#'
#' @param n The number of colors to generate. Default is 8.
#' @param type The type of palette. Options are "qualitative" (for categorical data), 
#'   "sequential" (for numeric data), or "diverging" (for data with a meaningful zero).
#'   Default is "qualitative".
#'
#' @return A character vector of hex color codes.
#'
#' @details
#' The function uses the ColorBrewer palettes through the RColorBrewer package.
#' For qualitative data, it uses the "Dark2" palette which is colorblind-friendly.
#' For sequential data, it uses the "Blues" palette.
#' For diverging data, it uses the "RdBu" palette.
#'
#' @examples
#' # Get 4 colors for categorical groups
#' colors <- get_colorblind_palette(4)
#'
#' # Use in a plot
#' df <- data.frame(
#'   x = 1:20,
#'   y = rnorm(20),
#'   group = rep(letters[1:4], each = 5)
#' )
#' library(ggplot2)
#' ggplot(df, aes(x, y, color = group)) +
#'   geom_line() +
#'   scale_color_manual(values = colors)
#'
#' @family color helpers
#' @export
get_colorblind_palette <- function(n = 8, type = "qualitative") {
  if (!is.numeric(n) || length(n) != 1 || is.na(n) || n < 1 ||
      n != as.integer(n)) {
    stop(sprintf(
      "'n' must be a single positive whole number, not '%s'.",
      paste(n, collapse = ", ")
    ))
  }

  valid_types <- c("qualitative", "sequential", "diverging")
  if (!is.character(type) || length(type) != 1 || !type %in% valid_types) {
    stop(sprintf(
      "Invalid type '%s'. Must be one of: %s",
      paste(type, collapse = ", "), paste(valid_types, collapse = ", ")
    ))
  }

  palette_name <- switch(
    type,
    qualitative = "Dark2",
    sequential = "Blues",
    diverging = "RdBu"
  )

  # Get maximum colors for the palette
  max_colors <- RColorBrewer::brewer.pal.info[palette_name, "maxcolors"]

  # Generate colors. brewer.pal() has a floor of 3 and warns below it,
  # so request the floor and take the first n.
  if (n <= max_colors) {
    colors <- RColorBrewer::brewer.pal(max(3L, as.integer(n)),
                                       palette_name)[seq_len(n)]
  } else {
    # If more colors needed than available, interpolate
    colors <- grDevices::colorRampPalette(
      RColorBrewer::brewer.pal(max_colors, palette_name)
    )(n)
  }

  colors
}
