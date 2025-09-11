#' Publication-Ready ggplot2 Themes
#'
#' @description
#' Provides professional themes for scientific publications, following
#' specific journal guidelines and regulatory requirements.
#'
#' @details
#' These themes are designed to meet the formatting requirements of major
#' scientific journals and regulatory agencies, with proper typography,
#' spacing, and clean aesthetics suitable for print and digital publication.

#' Nature Journal Theme
#'
#' @description
#' Creates a publication-ready theme following Nature journal guidelines.
#'
#' @param base_size Base font size in points. Default is 7pt per Nature guidelines.
#' @param base_family Font family. Default is "Arial" (Nature standard).
#' @param grid Logical. Whether to show grid lines. Default is FALSE for clean look.
#' @param border Logical. Whether to show panel border. Default is TRUE.
#'
#' @return A ggplot2 theme object.
#'
#' @details
#' Nature journal specifications:
#' - Font: Arial or Helvetica, 5-7pt
#' - Dimensions: 90mm (single) or 180mm (double column)
#' - Clean backgrounds, minimal grid lines
#' - Professional appearance for peer review
#'
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(wt, mpg)) + 
#'   geom_point() + 
#'   theme_nature()
#'   
#' @export
theme_nature <- function(base_size = 7, base_family = "Arial", 
                         grid = FALSE, border = TRUE) {
  
  # Base theme
  theme_base <- ggplot2::theme_bw(base_size = base_size, base_family = base_family)
  
  # Nature-specific modifications
  theme_base +
    ggplot2::theme(
      # Clean background
      panel.background = ggplot2::element_rect(fill = "white", colour = NA),
      plot.background = ggplot2::element_rect(fill = "white", colour = NA),
      
      # Grid lines (minimal or none)
      panel.grid.major = if (grid) {
        ggplot2::element_line(colour = "#E5E5E5", size = 0.25, linetype = "solid")
      } else {
        ggplot2::element_blank()
      },
      panel.grid.minor = ggplot2::element_blank(),
      
      # Panel border
      panel.border = if (border) {
        ggplot2::element_rect(colour = "black", fill = NA, size = 0.5)
      } else {
        ggplot2::element_blank()
      },
      
      # Axes
      axis.line = if (!border) {
        ggplot2::element_line(colour = "black", size = 0.5)
      } else {
        ggplot2::element_blank()
      },
      axis.ticks = ggplot2::element_line(colour = "black", size = 0.25),
      axis.ticks.length = ggplot2::unit(0.15, "cm"),
      axis.text = ggplot2::element_text(colour = "black", size = ggplot2::rel(1.0)),
      axis.title = ggplot2::element_text(colour = "black", size = ggplot2::rel(1.1)),
      axis.title.x = ggplot2::element_text(margin = ggplot2::margin(t = 8)),
      axis.title.y = ggplot2::element_text(margin = ggplot2::margin(r = 8), angle = 90),
      
      # Plot titles
      plot.title = ggplot2::element_text(
        colour = "black", size = ggplot2::rel(1.2), 
        hjust = 0, margin = ggplot2::margin(b = 10)
      ),
      plot.subtitle = ggplot2::element_text(
        colour = "black", size = ggplot2::rel(1.0), 
        hjust = 0, margin = ggplot2::margin(b = 5)
      ),
      plot.caption = ggplot2::element_text(
        colour = "black", size = ggplot2::rel(0.8), 
        hjust = 0, margin = ggplot2::margin(t = 5)
      ),
      
      # Legend (Nature prefers top or right)
      legend.background = ggplot2::element_rect(fill = "white", colour = NA),
      legend.key = ggplot2::element_rect(fill = "white", colour = NA),
      legend.key.size = ggplot2::unit(0.6, "cm"),
      legend.text = ggplot2::element_text(size = ggplot2::rel(0.9)),
      legend.title = ggplot2::element_text(size = ggplot2::rel(1.0)),
      legend.position = "top",
      legend.margin = ggplot2::margin(b = 10),
      
      # Strips (for faceting)
      strip.background = ggplot2::element_rect(fill = "#F0F0F0", colour = "black", size = 0.5),
      strip.text = ggplot2::element_text(colour = "black", size = ggplot2::rel(1.0), 
                                        margin = ggplot2::margin(4, 4, 4, 4)),
      
      # Margins
      plot.margin = ggplot2::margin(10, 10, 10, 10)
    )
}

#' Science Journal Theme  
#'
#' @description
#' Creates a publication-ready theme following Science journal guidelines.
#'
#' @param base_size Base font size in points. Default is 7pt per Science guidelines.
#' @param base_family Font family. Default is "Arial".
#' @param grid Logical. Whether to show major grid lines.
#'
#' @return A ggplot2 theme object.
#'
#' @details
#' Science journal specifications:
#' - Font: Arial, 6-7pt minimum
#' - Single column: 8.5 cm, Double column: 17.8 cm
#' - Clean, minimalist design
#' - Grid lines acceptable but subtle
#'
#' @examples
#' ggplot(mtcars, aes(wt, mpg)) + 
#'   geom_point() + 
#'   theme_science()
#'   
#' @export
theme_science <- function(base_size = 7, base_family = "Arial", grid = TRUE) {
  
  ggplot2::theme_bw(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      # Clean backgrounds
      panel.background = ggplot2::element_rect(fill = "white", colour = NA),
      plot.background = ggplot2::element_rect(fill = "white", colour = NA),
      
      # Subtle grid lines
      panel.grid.major = if (grid) {
        ggplot2::element_line(colour = "#F0F0F0", size = 0.25)
      } else {
        ggplot2::element_blank()
      },
      panel.grid.minor = ggplot2::element_blank(),
      
      # Clean panel border
      panel.border = ggplot2::element_rect(colour = "black", fill = NA, size = 0.5),
      
      # Axes
      axis.ticks = ggplot2::element_line(colour = "black", size = 0.25),
      axis.ticks.length = ggplot2::unit(0.12, "cm"),
      axis.text = ggplot2::element_text(colour = "black", size = ggplot2::rel(1.0)),
      axis.title = ggplot2::element_text(colour = "black", size = ggplot2::rel(1.1)),
      
      # Titles
      plot.title = ggplot2::element_text(
        size = ggplot2::rel(1.3), hjust = 0.5, 
        margin = ggplot2::margin(b = 10)
      ),
      
      # Legend positioned at bottom
      legend.position = "bottom",
      legend.key = ggplot2::element_rect(fill = "white", colour = NA),
      legend.background = ggplot2::element_rect(fill = "white", colour = NA),
      legend.text = ggplot2::element_text(size = ggplot2::rel(0.9)),
      
      # Facet strips
      strip.background = ggplot2::element_rect(fill = "white", colour = "black"),
      strip.text = ggplot2::element_text(size = ggplot2::rel(1.0))
    )
}

#' New England Journal of Medicine Theme
#'
#' @description
#' Creates a publication-ready theme following NEJM guidelines for clinical publications.
#'
#' @param base_size Base font size in points. Default is 8pt.
#' @param base_family Font family. Default is "Arial".
#' @param clinical Logical. If TRUE, applies clinical trial specific styling.
#'
#' @return A ggplot2 theme object.
#'
#' @details
#' NEJM specifications for clinical figures:
#' - Professional, clinical appearance
#' - Clear axis labels and readable fonts
#' - Suitable for medical/clinical publication
#' - Conservative, trustworthy design
#'
#' @examples
#' ggplot(mtcars, aes(wt, mpg)) + 
#'   geom_point() + 
#'   theme_nejm()
#'   
#' @export
theme_nejm <- function(base_size = 8, base_family = "Arial", clinical = TRUE) {
  
  ggplot2::theme_bw(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      # Professional appearance
      panel.background = ggplot2::element_rect(fill = "white", colour = NA),
      plot.background = ggplot2::element_rect(fill = "white", colour = NA),
      
      # No grid lines for clinical clarity
      panel.grid.major = if (clinical) {
        ggplot2::element_blank()
      } else {
        ggplot2::element_line(colour = "#F5F5F5", size = 0.25)
      },
      panel.grid.minor = ggplot2::element_blank(),
      
      # Strong panel border
      panel.border = ggplot2::element_rect(colour = "black", fill = NA, size = 0.75),
      
      # Prominent axes for clinical data
      axis.ticks = ggplot2::element_line(colour = "black", size = 0.5),
      axis.ticks.length = ggplot2::unit(0.2, "cm"),
      axis.text = ggplot2::element_text(colour = "black", size = ggplot2::rel(1.0)),
      axis.title = ggplot2::element_text(colour = "black", size = ggplot2::rel(1.1), 
                                        face = "bold"),
      
      # Clinical-style titles
      plot.title = ggplot2::element_text(
        size = ggplot2::rel(1.2), hjust = 0, face = "bold",
        margin = ggplot2::margin(b = 10)
      ),
      
      # Legend styling for clinical context
      legend.position = "bottom",
      legend.title = ggplot2::element_text(face = "bold"),
      legend.text = ggplot2::element_text(size = ggplot2::rel(0.9)),
      legend.key = ggplot2::element_rect(fill = "white", colour = "black", size = 0.25),
      
      # Clinical facet styling
      strip.background = ggplot2::element_rect(fill = "#E8E8E8", colour = "black", size = 0.5),
      strip.text = ggplot2::element_text(face = "bold", size = ggplot2::rel(1.0))
    )
}

#' FDA Regulatory Theme
#'
#' @description  
#' Creates a theme suitable for FDA regulatory submissions and clinical study reports.
#'
#' @param base_size Base font size in points. Default is 10pt for regulatory readability.
#' @param base_family Font family. Default is "Arial".
#' @param high_contrast Logical. If TRUE, uses high contrast styling.
#'
#' @return A ggplot2 theme object.
#'
#' @details
#' FDA regulatory specifications:
#' - High readability for regulatory review
#' - Conservative, professional styling  
#' - Clear distinctions for regulatory clarity
#' - Suitable for CSR (Clinical Study Report) inclusion
#'
#' @examples
#' ggplot(mtcars, aes(wt, mpg)) + 
#'   geom_point() + 
#'   theme_fda()
#'   
#' @export
theme_fda <- function(base_size = 10, base_family = "Arial", high_contrast = TRUE) {
  
  ggplot2::theme_bw(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      # Regulatory-appropriate background
      panel.background = ggplot2::element_rect(fill = "white", colour = NA),
      plot.background = ggplot2::element_rect(fill = "white", colour = NA),
      
      # Clear grid for data reading
      panel.grid.major = ggplot2::element_line(
        colour = if (high_contrast) "#D0D0D0" else "#F0F0F0", 
        size = 0.25, linetype = "solid"
      ),
      panel.grid.minor = ggplot2::element_line(
        colour = if (high_contrast) "#E8E8E8" else "#F8F8F8",
        size = 0.125, linetype = "solid"
      ),
      
      # Strong borders for regulatory clarity
      panel.border = ggplot2::element_rect(colour = "black", fill = NA, size = 1),
      
      # Regulatory-style axes
      axis.line = ggplot2::element_blank(),  # Use border instead
      axis.ticks = ggplot2::element_line(colour = "black", size = 0.5),
      axis.ticks.length = ggplot2::unit(0.25, "cm"),
      axis.text = ggplot2::element_text(
        colour = "black", size = ggplot2::rel(0.9)
      ),
      axis.title = ggplot2::element_text(
        colour = "black", size = ggplot2::rel(1.0), face = "bold"
      ),
      axis.title.x = ggplot2::element_text(margin = ggplot2::margin(t = 10)),
      axis.title.y = ggplot2::element_text(margin = ggplot2::margin(r = 10), angle = 90),
      
      # Conservative titles
      plot.title = ggplot2::element_text(
        size = ggplot2::rel(1.1), hjust = 0.5, face = "bold",
        margin = ggplot2::margin(b = 15)
      ),
      plot.subtitle = ggplot2::element_text(
        size = ggplot2::rel(0.9), hjust = 0.5,
        margin = ggplot2::margin(b = 10)
      ),
      plot.caption = ggplot2::element_text(
        size = ggplot2::rel(0.8), hjust = 0,
        margin = ggplot2::margin(t = 10)
      ),
      
      # Regulatory legend styling
      legend.position = "bottom",
      legend.title = ggplot2::element_text(face = "bold", size = ggplot2::rel(1.0)),
      legend.text = ggplot2::element_text(size = ggplot2::rel(0.9)),
      legend.key = ggplot2::element_rect(
        fill = "white", colour = if (high_contrast) "black" else NA,
        size = if (high_contrast) 0.25 else 0
      ),
      legend.key.size = ggplot2::unit(0.8, "cm"),
      legend.background = ggplot2::element_rect(fill = "white", colour = "black", size = 0.25),
      
      # Regulatory facet styling
      strip.background = ggplot2::element_rect(fill = "#F0F0F0", colour = "black", size = 0.75),
      strip.text = ggplot2::element_text(
        colour = "black", face = "bold", size = ggplot2::rel(1.0),
        margin = ggplot2::margin(6, 6, 6, 6)
      ),
      
      # Adequate margins for regulatory review
      plot.margin = ggplot2::margin(15, 15, 15, 15)
    )
}

#' Get Publication Theme by Name
#'
#' @description
#' Convenience function to get publication themes by name.
#'
#' @param theme_name Character string specifying theme name.
#'   Options: "nature", "science", "nejm", "fda", "default".
#' @param ... Additional arguments passed to specific theme functions.
#'
#' @return A ggplot2 theme object.
#'
#' @examples
#' theme_pub <- get_publication_theme("nature")
#' theme_reg <- get_publication_theme("fda", high_contrast = TRUE)
#' 
#' @export
get_publication_theme <- function(theme_name = "nature", ...) {
  
  available_themes <- c("nature", "science", "nejm", "fda", "default")
  
  if (!theme_name %in% available_themes) {
    stop(sprintf("Unknown theme '%s'. Available themes: %s",
                 theme_name, paste(available_themes, collapse = ", ")))
  }
  
  switch(theme_name,
         "nature" = theme_nature(...),
         "science" = theme_science(...),
         "nejm" = theme_nejm(...),
         "fda" = theme_fda(...),
         "default" = ggplot2::theme_bw(...)
  )
}

#' Apply Publication Theme with Color Palette
#'
#' @description
#' Convenience function that applies both publication theme and appropriate color palette.
#'
#' @param plot A ggplot object.
#' @param theme_name Character string specifying theme name.
#' @param color_palette Character string specifying color palette or vector of colors.
#' @param ... Additional arguments passed to theme function.
#'
#' @return Modified ggplot object.
#'
#' @examples  
#' p <- ggplot(mtcars, aes(wt, mpg, color = factor(cyl))) + geom_point()
#' p_pub <- apply_publication_style(p, "nature", "clinical")
#' 
#' @export
apply_publication_style <- function(plot, theme_name = "nature", 
                                   color_palette = NULL, ...) {
  
  # Apply theme
  plot <- plot + get_publication_theme(theme_name, ...)
  
  # Apply color palette if specified
  if (!is.null(color_palette)) {
    if (length(color_palette) == 1 && color_palette %in% c("clinical", "treatment")) {
      # Use clinical colors
      colors <- clinical_colors("treatment")
      plot <- plot + 
        ggplot2::scale_color_manual(values = colors) +
        ggplot2::scale_fill_manual(values = colors)
    } else if (is.character(color_palette) && length(color_palette) > 1) {
      # Use provided colors
      plot <- plot + 
        ggplot2::scale_color_manual(values = color_palette) +
        ggplot2::scale_fill_manual(values = color_palette)
    }
  }
  
  return(plot)
}