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
#' @export
get_colorblind_palette <- function(n = 8, type = "qualitative") {
  # Check for RColorBrewer package
  if (!requireNamespace("RColorBrewer", quietly = TRUE)) {
    warning("RColorBrewer package not available. Using default ggplot2 colors.")
    return(NULL)
  }
  
  # Select palette type
  palette_name <- switch(
    type,
    qualitative = "Dark2",
    sequential = "Blues",
    diverging = "RdBu",
    "Dark2"  # Default to qualitative
  )
  
  # Get maximum colors for the palette
  max_colors <- RColorBrewer::brewer.pal.info[palette_name, "maxcolors"]
  
  # Generate colors
  if (n <= max_colors) {
    colors <- RColorBrewer::brewer.pal(n, palette_name)
  } else {
    # If more colors needed than available, interpolate
    colors <- grDevices::colorRampPalette(
      RColorBrewer::brewer.pal(max_colors, palette_name)
    )(n)
  }
  
  return(colors)
}