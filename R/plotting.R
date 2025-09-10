#' Generate Custom ggplot2 Visualization for Longitudinal Data
#'
#' @description
#' Creates customizable visualizations using `ggplot2` for longitudinal data.
#' Supports dynamic axis scaling, optional grouping, faceting, and error visualization
#' with ribbons or error bars.
#'
#' @param stats A data frame containing the data to be plotted. Must include the columns 
#'   specified in `x_var`, `y_var`, and optionally `group_var`, `bound_lower`, 
#'   and `bound_upper` for error visualization.
#' @param x_var A string specifying the column name for the x-axis variable.
#' @param y_var A string specifying the column name for the y-axis variable.
#' @param group_var A string specifying the column name for the grouping variable.
#' @param error_type A string specifying the error type. Use `"bar"` for error bars or 
#'   `"band"` for ribbons.
#' @param xlab A string for the x-axis label.
#' @param ylab A string for the y-axis label.
#' @param title A string for the plot title.
#' @param subtitle A string for the plot subtitle.
#' @param caption A string for the plot caption.
#' @param facet A list specifying faceting variables. Use `facet_x` for columns 
#'   and `facet_y` for rows. Both are optional.
#' @param color_palette Optional vector of colors to use. If NULL, default ggplot 
#'   colors are used.
#' @param reference_lines List of reference line specifications. Each element should
#'   be a list with components: value, axis ("x" or "y"), color, linetype, size.
#' @param show_sample_sizes Logical. If TRUE, adds sample size annotations.
#' @param statistical_annotations Logical. If TRUE, adds p-values and significance.
#'
#' @return A `ggplot` object representing the visualization.
#' 
#' @examples
#' library(ggplot2)
#' data <- data.frame(
#'   x = rep(1:10, each = 2),
#'   mean_value = c(1:10, 2:11),
#'   group = rep(c("A", "B"), 10),
#'   bound_lower = c(0.8 * (1:10), 1:10),
#'   bound_upper = c(1.2 * (1:10), 2:11),
#'   is_continuous = TRUE
#' )
#'
#' # Create a plot with error bands
#' plot <- generate_plot(
#'   stats = data,
#'   x_var = "x",
#'   y_var = "mean_value",
#'   group_var = "group",
#'   error_type = "band",
#'   xlab = "Time",
#'   ylab = "Measurement",
#'   title = "Example Plot"
#' )
#' print(plot)
#'
#' @import ggplot2
#' @export
generate_plot <- function(
  stats, 
  x_var, 
  y_var, 
  group_var = NULL, 
  error_type = "bar", 
  xlab = NULL, 
  ylab = NULL, 
  title = NULL, 
  subtitle = NULL, 
  caption = NULL, 
  facet = NULL,
  color_palette = NULL,
  reference_lines = NULL,
  show_sample_sizes = FALSE,
  statistical_annotations = FALSE
) {
  # Set x-axis scale based on whether x is continuous
  x_scale <- if (stats$is_continuous[1]) {
    ggplot2::scale_x_continuous
  } else {
    ggplot2::scale_x_discrete
  }
  
  # Conditionally create the plot based on whether grouping is used
  if (!is.null(group_var) && group_var %in% names(stats)) {
    # Plot with grouping
    plot <- ggplot2::ggplot(
      stats, 
      ggplot2::aes(
        x = .data[[x_var]],
        y = .data[[y_var]],
        group = .data[[group_var]],
        color = .data[[group_var]],
        fill = .data[[group_var]]
      )
    )
  } else {
    # Plot without grouping
    plot <- ggplot2::ggplot(
      stats, 
      ggplot2::aes(
        x = .data[[x_var]],
        y = .data[[y_var]]
      )
    )
  }
  
  # Add line layer
  plot <- plot + ggplot2::geom_line()
  
  # Add error representation based on type
  if (error_type == "bar") {
    plot <- plot + ggplot2::geom_errorbar(
      ggplot2::aes(
        ymin = .data[["bound_lower"]], 
        ymax = .data[["bound_upper"]]
      ),
      width = 0.2, 
      color = "black", 
      alpha = 0.3
    )
  } else {
    plot <- plot + ggplot2::geom_ribbon(
      ggplot2::aes(
        ymin = .data[["bound_lower"]], 
        ymax = .data[["bound_upper"]],
        color = NULL
      ), 
      alpha = 0.2
    )
  }
  
  # Add labels
  plot <- plot + 
    ggplot2::xlab(xlab) +
    ggplot2::ylab(ylab) +
    ggplot2::labs(title = title, subtitle = subtitle, caption = caption)
  
  # Apply custom colors if provided
  if (!is.null(color_palette)) {
    plot <- plot + ggplot2::scale_color_manual(values = color_palette) +
      ggplot2::scale_fill_manual(values = color_palette)
  }
  
  # Add theme
  plot <- plot + 
    ggplot2::theme_bw() +
    ggplot2::theme(legend.position = "bottom")
  
  # Add faceting if specified
  if (!is.null(facet)) {
    plot <- plot + ggplot2::facet_grid(
      rows = if (!is.null(facet$facet_y)) ggplot2::vars(.data[[facet$facet_y]]) else NULL,
      cols = if (!is.null(facet$facet_x)) ggplot2::vars(.data[[facet$facet_x]]) else NULL
    )
  }
  
  # Add reference lines if specified
  if (!is.null(reference_lines)) {
    for (ref_line in reference_lines) {
      if (ref_line$axis == "y" || is.null(ref_line$axis)) {
        plot <- plot + ggplot2::geom_hline(
          yintercept = ref_line$value,
          color = ref_line$color %||% "red",
          linetype = ref_line$linetype %||% "dashed", 
          size = ref_line$size %||% 0.5,
          alpha = ref_line$alpha %||% 0.7
        )
      } else if (ref_line$axis == "x") {
        plot <- plot + ggplot2::geom_vline(
          xintercept = ref_line$value,
          color = ref_line$color %||% "red",
          linetype = ref_line$linetype %||% "dashed",
          size = ref_line$size %||% 0.5, 
          alpha = ref_line$alpha %||% 0.7
        )
      }
    }
  }
  
  # Add sample size annotations if requested
  if (show_sample_sizes && "sample_size" %in% names(stats)) {
    plot <- plot + ggplot2::geom_text(
      ggplot2::aes(label = paste("n =", .data[["sample_size"]])),
      vjust = -0.5, size = 3, show.legend = FALSE,
      color = "black", alpha = 0.7
    )
  }
  
  # Add statistical annotations if requested
  if (statistical_annotations && "significance" %in% names(stats)) {
    # Only show significant results
    sig_stats <- stats[!is.na(stats$significance) & stats$significance != "ns" & stats$significance != "", ]
    
    if (nrow(sig_stats) > 0) {
      plot <- plot + ggplot2::geom_text(
        data = sig_stats,
        ggplot2::aes(label = .data[["significance"]]),
        vjust = -1.2, size = 4, show.legend = FALSE,
        color = "black", fontface = "bold"
      )
    }
  }
  
  return(plot)
}