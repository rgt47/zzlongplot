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
#' @param jitter_width Numeric. Width of horizontal jitter for error bars when 
#'   multiple groups are present. Only applies when error_type = "bar".
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
#' @param use_boxplot Logical. If TRUE, renders actual boxplots instead of line graphs.
#' @param ribbon_alpha Numeric. Transparency level for ribbon/band error representations.
#'   Values from 0 (fully transparent) to 1 (fully opaque). Default is 0.2.
#' @param ribbon_fill Character. Custom fill color for ribbons. If NULL, uses group colors.
#' @param bw_print Logical. If TRUE, maps linetype and shape to group variable
#'   for black-and-white print compatibility. Default is FALSE.
#' @param sample_size_opts List. Options controlling the appearance and
#'   placement of sample size labels. Elements (all optional):
#'   \describe{
#'     \item{position}{Placement style: "point" (next to each data
#'       point, the default) or "table" (color-coded table below
#'       x-axis with one row per group).}
#'     \item{size}{Font size in mm. Default 2.8.}
#'     \item{color}{Label color (only for position = "point").
#'       Default "grey40". Table mode uses group colors.}
#'     \item{alpha}{Transparency, 0-1. Default 1.}
#'     \item{nudge_x}{Horizontal offset from the point (only for
#'       position = "point"). Default is auto-calculated.}
#'     \item{nudge_y}{Vertical offset from the point (only for
#'       position = "point"). Default 0.}
#'     \item{gap}{Fraction of y-range between plot area and first
#'       table row (only for position = "table"). Default 0.10.}
#'     \item{row_height}{Fraction of y-range between table rows
#'       (only for position = "table"). Default 0.05.}
#'     \item{label_size}{Font size for group labels in the table
#'       (only for position = "table"). Defaults to size.}
#'     \item{label_offset}{Horizontal offset for group labels
#'       (only for position = "table"). Default 0.08 for
#'       continuous x, 0.35 for categorical.}
#'   }
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
#' # Create a plot with jittered error bars
#' plot_jitter <- generate_plot(
#'   stats = data,
#'   x_var = "x", 
#'   y_var = "mean_value",
#'   group_var = "group",
#'   error_type = "bar",
#'   jitter_width = 0.2,
#'   xlab = "Time",
#'   ylab = "Measurement", 
#'   title = "Example Plot with Jittered Error Bars"
#' )
#' print(plot_jitter)
#'
#' @import ggplot2
#' @export
generate_plot <- function(
  stats, 
  x_var, 
  y_var, 
  group_var = NULL, 
  error_type = "bar", 
  jitter_width = 0.1,
  xlab = NULL, 
  ylab = NULL, 
  title = NULL, 
  subtitle = NULL, 
  caption = NULL, 
  facet = NULL,
  color_palette = NULL,
  reference_lines = NULL,
  show_sample_sizes = FALSE,
  statistical_annotations = FALSE,
  use_boxplot = FALSE,
  ribbon_alpha = 0.2,
  ribbon_fill = NULL,
  bw_print = FALSE,
  sample_size_opts = list(),
  contrast_display = NULL,
  contrast_data = NULL
) {
  # Set x-axis scale based on whether x is continuous
  x_scale <- if (stats$is_continuous[1]) {
    ggplot2::scale_x_continuous
  } else {
    ggplot2::scale_x_discrete
  }
  
  # Conditionally create the plot based on whether grouping is used
  if (!is.null(group_var) && group_var %in% names(stats)) {
    base_aes <- ggplot2::aes(
      x = .data[[x_var]],
      y = .data[[y_var]],
      group = .data[[group_var]],
      color = .data[[group_var]],
      fill = .data[[group_var]]
    )
    if (bw_print) {
      base_aes <- utils::modifyList(base_aes, ggplot2::aes(
        linetype = .data[[group_var]],
        shape = .data[[group_var]]
      ))
    }
    plot <- ggplot2::ggplot(stats, base_aes)
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
  
  # Determine if we need to apply dodging/jittering for multiple groups
  has_groups <- !is.null(group_var) && group_var %in% names(stats) && length(unique(stats[[group_var]])) > 1
  
  # Add plotting layers based on plot type
  if (use_boxplot) {
    # Create boxplots using summary statistics
    # For boxplots, we need to create the boxplot elements manually since we have summary stats
    if (has_groups && jitter_width > 0) {
      dodge_pos <- ggplot2::position_dodge(width = jitter_width)
      
      # Add boxplot elements: box (IQR), whiskers, median line, and mean point
      plot <- plot + 
        # Box representing IQR (Q1 to Q3) - made wider and more visible
        ggplot2::geom_rect(
          ggplot2::aes(
            xmin = as.numeric(.data[[x_var]]) - 0.25,
            xmax = as.numeric(.data[[x_var]]) + 0.25,
            ymin = .data[["q25_value"]],
            ymax = .data[["q75_value"]],
            fill = .data[[group_var]]
          ),
          alpha = 0.8,
          color = "black",
          linewidth = 1,
          position = dodge_pos
        ) +
        # Whiskers (extends to bound_lower and bound_upper)
        ggplot2::geom_segment(
          ggplot2::aes(
            x = as.numeric(.data[[x_var]]),
            xend = as.numeric(.data[[x_var]]),
            y = .data[["q75_value"]],
            yend = .data[["bound_upper"]]
          ),
          position = dodge_pos
        ) +
        ggplot2::geom_segment(
          ggplot2::aes(
            x = as.numeric(.data[[x_var]]),
            xend = as.numeric(.data[[x_var]]),
            y = .data[["q25_value"]],
            yend = .data[["bound_lower"]]
          ),
          position = dodge_pos
        ) +
        # Median line (bold horizontal line) - made wider to match box
        ggplot2::geom_segment(
          ggplot2::aes(
            x = as.numeric(.data[[x_var]]) - 0.25,
            xend = as.numeric(.data[[x_var]]) + 0.25,
            y = .data[[y_var]],  # This is the median for boxplot
            yend = .data[[y_var]]
          ),
          color = "black",
          linewidth = 1.5,
          position = dodge_pos
        )
    } else {
      # Single group boxplots without dodging
      plot <- plot + 
        # Box representing IQR - made wider and more visible
        ggplot2::geom_rect(
          ggplot2::aes(
            xmin = as.numeric(.data[[x_var]]) - 0.3,
            xmax = as.numeric(.data[[x_var]]) + 0.3,
            ymin = .data[["q25_value"]],
            ymax = .data[["q75_value"]]
          ),
          alpha = 0.8,
          color = "black",
          linewidth = 1
        ) +
        # Whiskers
        ggplot2::geom_segment(
          ggplot2::aes(
            x = as.numeric(.data[[x_var]]),
            xend = as.numeric(.data[[x_var]]),
            y = .data[["q75_value"]],
            yend = .data[["bound_upper"]]
          )
        ) +
        ggplot2::geom_segment(
          ggplot2::aes(
            x = as.numeric(.data[[x_var]]),
            xend = as.numeric(.data[[x_var]]),
            y = .data[["q25_value"]],
            yend = .data[["bound_lower"]]
          )
        ) +
        # Median line - made wider to match box
        ggplot2::geom_segment(
          ggplot2::aes(
            x = as.numeric(.data[[x_var]]) - 0.3,
            xend = as.numeric(.data[[x_var]]) + 0.3,
            y = .data[[y_var]],
            yend = .data[[y_var]]
          ),
          color = "black",
          linewidth = 1.5
        )
    }
  } else {
    # Add line and point layers with appropriate positioning
    if (has_groups && jitter_width > 0) {
      # Use position_dodge for multiple groups
      plot <- plot + 
        ggplot2::geom_line(position = ggplot2::position_dodge(width = jitter_width)) +
        ggplot2::geom_point(position = ggplot2::position_dodge(width = jitter_width))
    } else {
      # Standard lines and points without dodging
      plot <- plot + 
        ggplot2::geom_line() +
        ggplot2::geom_point()
    }
  }
  
  # Add error representation based on type (skip for boxplots as they have their own whiskers)
  if (!use_boxplot && error_type == "bar") {
    if (has_groups && jitter_width > 0) {
      # Use position_dodge for multiple groups
      plot <- plot + ggplot2::geom_errorbar(
        ggplot2::aes(
          ymin = .data[["bound_lower"]], 
          ymax = .data[["bound_upper"]]
        ),
        width = 0.2, 
        color = "black", 
        alpha = 0.3,
        position = ggplot2::position_dodge(width = jitter_width)
      )
    } else {
      # Standard error bars without dodging
      plot <- plot + ggplot2::geom_errorbar(
        ggplot2::aes(
          ymin = .data[["bound_lower"]], 
          ymax = .data[["bound_upper"]]
        ),
        width = 0.2, 
        color = "black", 
        alpha = 0.3
      )
    }
  } else if (!use_boxplot) {
    # Add error bands (ribbons) - skip for boxplots
    if (is.null(ribbon_fill)) {
      # Use group colors for ribbons
      plot <- plot + ggplot2::geom_ribbon(
        ggplot2::aes(
          ymin = .data[["bound_lower"]], 
          ymax = .data[["bound_upper"]],
          fill = if (!is.null(group_var)) .data[[group_var]] else NULL,
          color = NULL
        ), 
        alpha = ribbon_alpha
      )
    } else {
      # Use custom fill color for ribbons
      plot <- plot + ggplot2::geom_ribbon(
        ggplot2::aes(
          ymin = .data[["bound_lower"]], 
          ymax = .data[["bound_upper"]],
          color = NULL
        ), 
        fill = ribbon_fill,
        alpha = ribbon_alpha
      )
    }
  }
  
  if (identical(contrast_display, "footnote") &&
      !is.null(contrast_data) && nrow(contrast_data) > 0) {
    ci_level <- if ("ci_level" %in% names(stats)) {
      stats$ci_level[1]
    } else {
      NA
    }
    fn_text <- .format_contrast_footnote(
      contrast_data, x_var,
      error_type = error_type, ci_level = ci_level
    )
    caption <- if (!is.null(caption) && nzchar(caption)) {
      paste0(caption, "\n", fn_text)
    } else {
      fn_text
    }
  }

  # Add labels
  plot <- plot +
    ggplot2::xlab(xlab) +
    ggplot2::ylab(ylab) +
    ggplot2::labs(title = title, subtitle = subtitle, caption = caption)

  if (identical(contrast_display, "footnote") &&
      !is.null(contrast_data)) {
    plot <- plot + ggplot2::theme(
      plot.caption = ggplot2::element_text(
        hjust = 0, face = "italic", size = 7
      )
    )
  }
  
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
          linewidth = ref_line$linewidth %||% ref_line$size %||% 0.5,
          alpha = ref_line$alpha %||% 0.7
        )
      } else if (ref_line$axis == "x") {
        plot <- plot + ggplot2::geom_vline(
          xintercept = ref_line$value,
          color = ref_line$color %||% "red",
          linetype = ref_line$linetype %||% "dashed",
          linewidth = ref_line$linewidth %||% ref_line$size %||% 0.5,
          alpha = ref_line$alpha %||% 0.7
        )
      }
    }
  }
  
  # Add sample size annotations if requested
  if (show_sample_sizes && "sample_size" %in% names(stats)) {
    ss <- sample_size_opts
    ss_position <- ss$position %||% "point"
    ss_size  <- ss$size  %||% 2.8
    ss_alpha <- ss$alpha %||% 1

    if (ss_position == "table" && has_groups) {
      plot <- .add_sample_size_table(
        plot, stats, x_var, y_var, group_var,
        ss_size, ss_alpha, ss
      )
    } else {
      ss_color <- ss$color %||% "grey40"
      ss_ny    <- ss$nudge_y %||% 0

      ss_nx <- if (!is.null(ss$nudge_x)) {
        ss$nudge_x
      } else if (stats$is_continuous[1]) {
        diff(range(as.numeric(stats[[x_var]]), na.rm = TRUE)) * 0.03
      } else {
        0.15
      }

      stats_label <- stats
      stats_label[[".x_nudged"]] <- as.numeric(
        stats_label[[x_var]]
      ) + ss_nx
      stats_label[[".y_nudged"]] <- stats_label[[y_var]] + ss_ny

      if (has_groups && jitter_width > 0) {
        plot <- plot + ggplot2::geom_text(
          data = stats_label,
          ggplot2::aes(
            x = .data[[".x_nudged"]],
            y = .data[[".y_nudged"]],
            label = .data[["sample_size"]]
          ),
          hjust = 0, size = ss_size, show.legend = FALSE,
          color = ss_color, alpha = ss_alpha,
          position = ggplot2::position_dodge(width = jitter_width)
        )
      } else {
        plot <- plot + ggplot2::geom_text(
          data = stats_label,
          ggplot2::aes(
            x = .data[[".x_nudged"]],
            y = .data[[".y_nudged"]],
            label = .data[["sample_size"]]
          ),
          hjust = 0, size = ss_size, show.legend = FALSE,
          color = ss_color, alpha = ss_alpha
        )
      }
    }
  }
  
  # Add statistical annotations if requested
  if (statistical_annotations && "significance" %in% names(stats)) {
    pw_df <- attr(stats, "pairwise")
    has_pairwise <- !is.null(pw_df) && nrow(pw_df) > 0

    if (has_pairwise) {
      plot <- .add_pairwise_annotations(
        plot, stats, pw_df, x_var, y_var, group_var
      )
    } else {
      sig_stats <- stats[
        !is.na(stats$significance) &
        stats$significance != "ns" &
        stats$significance != "",
      ]
      if (nrow(sig_stats) > 0) {
        plot <- plot + ggplot2::geom_text(
          data = sig_stats,
          ggplot2::aes(label = .data[["significance"]]),
          vjust = -1.2, size = 4, show.legend = FALSE,
          color = "black", fontface = "bold"
        )
      }
    }
  }
  
  return(plot)
}


#' Add sample size table below x-axis
#'
#' Places a color-coded table of sample sizes below the plot area,
#' with one row per group aligned to x-axis tick positions.
#'
#' @param plot A ggplot object.
#' @param stats Data frame of summary statistics.
#' @param x_var Column name for x variable.
#' @param y_var Column name for y variable.
#' @param group_var Column name for group variable.
#' @param ss_size Font size for labels.
#' @param ss_alpha Transparency for labels.
#' @param ss_opts Full sample_size_opts list for additional settings.
#'
#' @return Modified ggplot object with sample size table.
#' @noRd
.add_sample_size_table <- function(
  plot, stats, x_var, y_var, group_var,
  ss_size, ss_alpha, ss_opts
) {
  y_vals <- c(
    stats[[y_var]],
    if ("bound_lower" %in% names(stats)) stats[["bound_lower"]],
    if ("bound_upper" %in% names(stats)) stats[["bound_upper"]]
  )
  y_min <- min(y_vals, na.rm = TRUE)
  y_max <- max(y_vals, na.rm = TRUE)
  y_range <- y_max - y_min
  if (y_range == 0) y_range <- abs(y_min) * 0.1 + 1

  groups <- unique(stats[[group_var]])
  n_groups <- length(groups)

  gap <- ss_opts$gap %||% 0.18
  row_height <- ss_opts$row_height %||% 0.06
  label_size <- ss_opts$label_size %||% ss_size

  table_rows <- data.frame(
    x = numeric(0), y = numeric(0),
    label = character(0), group = character(0),
    stringsAsFactors = FALSE
  )

  x_numeric <- as.numeric(stats[[x_var]])
  x_positions <- sort(unique(x_numeric))

  for (i in seq_along(groups)) {
    grp <- groups[i]
    row_y <- y_min - y_range * (gap + (i - 1) * row_height)
    grp_stats <- stats[stats[[group_var]] == grp, ]

    for (xp in x_positions) {
      match_row <- grp_stats[as.numeric(grp_stats[[x_var]]) == xp, ]
      n_label <- if (nrow(match_row) > 0) {
        as.character(match_row[["sample_size"]][1])
      } else {
        ""
      }
      table_rows <- rbind(table_rows, data.frame(
        x = xp, y = row_y, label = n_label,
        group = grp, stringsAsFactors = FALSE
      ))
    }

    x_label_pos <- if (stats$is_continuous[1]) {
      min(x_positions) - diff(range(x_positions)) *
        (ss_opts$label_offset %||% 0.08)
    } else {
      1 - (ss_opts$label_offset %||% 0.35)
    }
    table_rows <- rbind(table_rows, data.frame(
      x = x_label_pos, y = row_y, label = as.character(grp),
      group = grp, stringsAsFactors = FALSE
    ))
  }

  is_label <- !table_rows$x %in% x_positions
  count_rows <- table_rows[!is_label, ]
  label_rows <- table_rows[is_label, ]

  bottom_margin <- n_groups * 18 + 30

  plot <- plot +
    ggplot2::geom_text(
      data = count_rows,
      ggplot2::aes(
        x = .data[["x"]], y = .data[["y"]],
        label = .data[["label"]],
        color = .data[["group"]]
      ),
      size = ss_size, alpha = ss_alpha,
      hjust = 0.5, show.legend = FALSE,
      inherit.aes = FALSE
    ) +
    ggplot2::geom_text(
      data = label_rows,
      ggplot2::aes(
        x = .data[["x"]], y = .data[["y"]],
        label = .data[["label"]],
        color = .data[["group"]]
      ),
      size = label_size, alpha = ss_alpha,
      hjust = 1, fontface = "bold", show.legend = FALSE,
      inherit.aes = FALSE
    ) +
    ggplot2::coord_cartesian(
      clip = "off",
      ylim = c(y_min, y_max)
    ) +
    ggplot2::theme(
      plot.margin = ggplot2::margin(
        t = 5.5, r = 5.5,
        b = bottom_margin,
        l = 40,
        unit = "pt"
      ),
      legend.position = "none"
    )

  plot
}


#' Add omnibus p-value and pairwise brackets
#'
#' For 3+ groups, draws an overall p-value at the top of each
#' timepoint and pairwise significance brackets between groups.
#'
#' @param plot A ggplot object.
#' @param stats Summary statistics data frame.
#' @param pw_df Pairwise comparison data frame (from attribute).
#' @param x_var Column name for x variable.
#' @param y_var Column name for y variable.
#' @param group_var Column name for group variable.
#'
#' @return Modified ggplot with bracket annotations.
#' @noRd
.add_pairwise_annotations <- function(
  plot, stats, pw_df, x_var, y_var, group_var
) {
  y_vals <- c(
    stats[[y_var]],
    if ("bound_upper" %in% names(stats)) stats[["bound_upper"]]
  )
  y_range <- diff(range(y_vals, na.rm = TRUE))
  if (y_range == 0) y_range <- 1

  bracket_gap <- y_range * 0.08
  step_height <- y_range * 0.07
  tick_height <- y_range * 0.02
  tick_width <- if (stats$is_continuous[1]) {
    diff(range(as.numeric(stats[[x_var]]), na.rm = TRUE)) * 0.04
  } else {
    0.15
  }

  x_values <- unique(stats[[x_var]])
  sig_pw <- pw_df[
    !is.na(pw_df$significance) &
    pw_df$significance != "ns" &
    pw_df$significance != "",
  ]

  omnibus_df <- unique(stats[, c(x_var, "p_adj", "significance")])
  omnibus_sig <- omnibus_df[
    !is.na(omnibus_df$significance) &
    omnibus_df$significance != "ns" &
    omnibus_df$significance != "",
  ]

  seg_data <- data.frame(
    x = numeric(0), xend = numeric(0),
    y = numeric(0), yend = numeric(0),
    stringsAsFactors = FALSE
  )
  label_data <- data.frame(
    x = numeric(0), y = numeric(0),
    label = character(0),
    fontface = character(0),
    size = numeric(0),
    stringsAsFactors = FALSE
  )

  for (xv in x_values) {
    xn <- as.numeric(xv)
    tp_upper <- max(
      y_vals[as.numeric(stats[[x_var]]) == xn],
      na.rm = TRUE
    )
    bracket_base <- tp_upper + bracket_gap

    tp_pw <- sig_pw[sig_pw$x_val == xv, , drop = FALSE]
    top_y <- bracket_base

    if (nrow(tp_pw) > 0) {
      tp_pw <- tp_pw[order(tp_pw$p_adj), ]

      for (j in seq_len(nrow(tp_pw))) {
        g1 <- tp_pw$group1[j]
        g2 <- tp_pw$group2[j]
        sig_label <- tp_pw$significance[j]

        y_bar <- bracket_base + (j - 1) * step_height

        seg_data <- rbind(seg_data, data.frame(
          x = xn - tick_width, xend = xn - tick_width,
          y = y_bar - tick_height, yend = y_bar
        ))
        seg_data <- rbind(seg_data, data.frame(
          x = xn - tick_width, xend = xn + tick_width,
          y = y_bar, yend = y_bar
        ))
        seg_data <- rbind(seg_data, data.frame(
          x = xn + tick_width, xend = xn + tick_width,
          y = y_bar, yend = y_bar - tick_height
        ))

        pair_label <- paste0(
          .abbrev_group(g1), " vs ", .abbrev_group(g2),
          " ", sig_label
        )
        label_data <- rbind(label_data, data.frame(
          x = xn, y = y_bar + tick_height * 0.4,
          label = pair_label,
          fontface = "plain", size = 2.6,
          stringsAsFactors = FALSE
        ))

        top_y <- y_bar + step_height * 0.6
      }
    }

  }

  if (nrow(seg_data) > 0) {
    plot <- plot + ggplot2::geom_segment(
      data = seg_data,
      ggplot2::aes(
        x = .data[["x"]], xend = .data[["xend"]],
        y = .data[["y"]], yend = .data[["yend"]]
      ),
      linewidth = 0.4, color = "grey30",
      inherit.aes = FALSE
    )
  }

  if (nrow(label_data) > 0) {
    plot <- plot + ggplot2::geom_text(
      data = label_data,
      ggplot2::aes(
        x = .data[["x"]], y = .data[["y"]],
        label = .data[["label"]]
      ),
      size = label_data$size,
      fontface = label_data$fontface,
      color = "grey20",
      hjust = 0.5, vjust = 0,
      inherit.aes = FALSE
    )
  }

  plot
}


#' Abbreviate group name for bracket labels
#' @param g Character group name.
#' @return Abbreviated name (first word, max 8 chars).
#' @noRd
.abbrev_group <- function(g) {
  parts <- strsplit(g, "\\s+")[[1]]
  nm <- if (length(parts) > 1) {
    paste0(substr(parts[1], 1, 1), substr(parts[2], 1, 1))
  } else {
    substr(g, 1, 4)
  }
  nm
}


#' Filter contrasts to keep only those involving the reference group
#'
#' Detects the reference group (placebo/control) and keeps only
#' contrasts where one side is the reference. If no reference is
#' detected, returns the original data frame unchanged.
#' @param pw_df Pairwise data frame.
#' @return Filtered data frame.
#' @noRd
.filter_vs_reference <- function(pw_df) {
  all_groups <- unique(c(pw_df$group1, pw_df$group2))
  ref_patterns <- c("placebo", "pbo", "control", "vehicle")
  ref <- NULL
  for (g in all_groups) {
    if (tolower(g) %in% ref_patterns) {
      ref <- g
      break
    }
  }
  if (is.null(ref)) return(pw_df)
  pw_df[pw_df$group1 == ref | pw_df$group2 == ref, , drop = FALSE]
}


#' Format contrast results as a footnote caption
#'
#' @param pw_df Pairwise data frame with estimate, lower_cl,
#'   upper_cl, p_adj columns.
#' @param x_var Name of the time variable.
#' @param error_type One of "bar" or "band" (passed through for
#'   accurate header text).
#' @param ci_level Confidence level used for bounds, or NA if
#'   standard error was used.
#' @return Character string for use as a plot caption.
#' @noRd
.format_contrast_footnote <- function(pw_df, x_var,
                                      error_type = "bar",
                                      ci_level = NA) {
  pw_df <- .filter_vs_reference(pw_df)
  has_est <- "estimate" %in% names(pw_df) &&
    any(!is.na(pw_df$estimate))

  sig_rows <- pw_df[!is.na(pw_df$p_adj) & pw_df$p_adj < 0.05,
                     , drop = FALSE]
  if (nrow(sig_rows) == 0) sig_rows <- pw_df

  lines <- character(0)

  for (i in seq_len(nrow(sig_rows))) {
    r <- sig_rows[i, ]
    lbl <- paste0(r$group1, " - ", r$group2)
    p_str <- .format_p(r$p_adj)
    if (has_est && !is.na(r$estimate)) {
      line <- sprintf(
        "%s %s: %s, %.2f (95%% CI: %.2f, %.2f), %s",
        x_var, r$x_val, lbl,
        r$estimate, r$lower_cl, r$upper_cl, p_str
      )
    } else {
      line <- sprintf("%s %s: %s, %s", x_var, r$x_val, lbl, p_str)
    }
    lines <- c(lines, line)
  }

  if (length(lines) > 4) {
    lines <- c(
      lines[1:3],
      "... (use contrast_display='table' for full results)"
    )
  }

  err_desc <- if (!is.na(ci_level)) {
    sprintf("%.0f%% CI", ci_level * 100)
  } else {
    "+/-1 SE"
  }
  shape <- if (identical(error_type, "band")) "Bands" else "Error bars"
  header <- sprintf("%s represent %s.", shape, err_desc)
  paste(c(header, lines), collapse = "\n")
}


#' Format a p-value for display
#' @param p Numeric p-value.
#' @return Formatted string.
#' @noRd
.format_p <- function(p) {
  if (is.na(p)) return("p=NA")
  if (p < 0.001) "p<0.001"
  else paste0("p=", formatC(p, format = "f", digits = 3))
}


#' Build a contrast results table as a ggplot
#'
#' @param pw_df Pairwise data frame with estimate, lower_cl,
#'   upper_cl, p_adj columns.
#' @param x_var Name of the time variable.
#' @return A ggplot object rendered as a table.
#' @noRd
.build_contrast_table_plot <- function(pw_df, x_var) {
  pw_df <- .filter_vs_reference(pw_df)
  has_est <- "estimate" %in% names(pw_df) &&
    any(!is.na(pw_df$estimate))

  tbl <- data.frame(
    Time = as.character(pw_df$x_val),
    Contrast = paste0(pw_df$group1, " - ", pw_df$group2),
    stringsAsFactors = FALSE
  )

  if (has_est) {
    tbl[["Estimate (95% CI)"]] <- ifelse(
      !is.na(pw_df$estimate),
      sprintf(
        "%.2f (%.2f, %.2f)",
        pw_df$estimate, pw_df$lower_cl, pw_df$upper_cl
      ),
      "--"
    )
  }

  tbl[["P-value"]] <- vapply(
    pw_df$p_adj, .format_p, character(1)
  )

  n_col <- ncol(tbl)
  n_row <- nrow(tbl)
  col_names <- names(tbl)

  col_x <- seq_len(n_col)
  header <- data.frame(
    x = col_x, y = n_row + 1,
    label = col_names,
    fontface = "bold",
    stringsAsFactors = FALSE
  )

  cells <- expand.grid(
    col = seq_len(n_col), row = seq_len(n_row)
  )
  cells$x <- cells$col
  cells$y <- n_row - cells$row + 1
  cells$label <- vapply(seq_len(nrow(cells)), function(i) {
    as.character(tbl[cells$row[i], cells$col[i]])
  }, character(1))
  cells$fontface <- "plain"

  all_labels <- rbind(
    header[, c("x", "y", "label", "fontface")],
    cells[, c("x", "y", "label", "fontface")]
  )

  p <- ggplot2::ggplot(all_labels, ggplot2::aes(
    x = .data[["x"]], y = .data[["y"]]
  )) +
    ggplot2::geom_text(
      ggplot2::aes(label = .data[["label"]]),
      fontface = all_labels$fontface,
      size = 2.8, hjust = 0.5
    ) +
    ggplot2::geom_hline(
      yintercept = n_row + 0.5,
      linewidth = 0.3, color = "grey40"
    ) +
    ggplot2::scale_x_continuous(
      limits = c(0.3, n_col + 0.7), expand = c(0, 0)
    ) +
    ggplot2::scale_y_continuous(
      limits = c(0.3, n_row + 1.7), expand = c(0, 0)
    ) +
    ggplot2::theme_void() +
    ggplot2::theme(plot.margin = ggplot2::margin(2, 10, 2, 10))

  p
}