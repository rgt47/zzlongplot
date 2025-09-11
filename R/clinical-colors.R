#' Clinical Trial Color Palettes
#'
#' @description
#' Provides standardized color palettes for clinical trial visualizations,
#' following industry conventions for treatment group representation.
#'
#' @param type Character string specifying the type of clinical palette.
#'   Options: "treatment" (standard treatment colors), "severity" (condition severity),
#'   "outcome" (positive/negative outcomes), "fda" (FDA submission), or journal-specific
#'   palettes: "nejm", "nature", "lancet", "jama", "science", "jco". Default is "treatment".
#' @param n Integer specifying the number of colors needed. If not specified,
#'   returns the full palette.
#' @param placebo_first Logical. If TRUE, places placebo color first in treatment
#'   palettes. Default is TRUE.
#'
#' @return A character vector of hex color codes.
#'
#' @details
#' Clinical color palettes follow these conventions:
#' - **Treatment**: Placebo in neutral grey, active treatments in distinct colors
#' - **Severity**: Progression from mild (light) to severe (dark)  
#' - **Outcome**: Green for positive, red for negative, grey for neutral
#' - **FDA**: High contrast colors for regulatory submissions
#' 
#' Journal-specific palettes (based on ggsci package):
#' - **NEJM**: New England Journal of Medicine official colors
#' - **Nature**: Nature Publishing Group colors (Nature Reviews Cancer)
#' - **Lancet**: Lancet journal colors (Lancet Oncology)
#' - **JAMA**: Journal of the American Medical Association colors
#' - **Science**: Science journal (AAAS) colors
#' - **JCO**: Journal of Clinical Oncology colors
#' 
#' All palettes maintain distinction in grayscale printing and follow accessibility guidelines.
#'
#' @examples
#' # Standard treatment palette
#' colors <- clinical_colors("treatment", n = 3)
#' 
#' # Severity progression
#' severity_colors <- clinical_colors("severity", n = 5)
#' 
#' # Journal-specific palettes
#' nejm_colors <- clinical_colors("nejm", n = 4)
#' nature_colors <- clinical_colors("nature", n = 4) 
#' lancet_colors <- clinical_colors("lancet", n = 4)
#' 
#' # Use in plot
#' df <- data.frame(
#'   visit = rep(1:4, 60),
#'   efficacy = rnorm(240),
#'   treatment = rep(c("Placebo", "Drug 10mg", "Drug 20mg"), each = 80)
#' )
#' 
#' @export
clinical_colors <- function(type = "treatment", n = NULL, placebo_first = TRUE) {
  
  # Define clinical color palettes
  palettes <- list(
    
    # Standard treatment colors (colorblind-friendly)
    treatment = c(
      "#7F7F7F",  # Placebo: neutral grey
      "#1F77B4",  # Active 1: blue (primary endpoint)
      "#D62728",  # Active 2: red (secondary)
      "#FF7F0E",  # Active 3: orange
      "#2CA02C",  # Active 4: green
      "#9467BD",  # Active 5: purple
      "#8C564B",  # Active 6: brown
      "#E377C2"   # Active 7: pink
    ),
    
    # Severity/progression colors
    severity = c(
      "#E8F5E8",  # Very mild: light green
      "#A8DBA8",  # Mild: medium green  
      "#79C079",  # Moderate: darker green
      "#4A904A",  # Severe: dark green
      "#2D5D2D"   # Very severe: darkest green
    ),
    
    # Outcome colors
    outcome = c(
      "#2CA02C",  # Positive: green
      "#7F7F7F",  # Neutral: grey
      "#D62728"   # Negative: red
    ),
    
    # FDA submission palette (high contrast)
    fda = c(
      "#000000",  # Black
      "#E69F00",  # Orange  
      "#56B4E9",  # Sky blue
      "#009E73",  # Bluish green
      "#F0E442",  # Yellow
      "#0072B2",  # Blue
      "#D55E00",  # Vermillion
      "#CC79A7"   # Reddish purple
    ),
    
    # Journal-specific color palettes (from ggsci package)
    # NEJM (New England Journal of Medicine)
    nejm = c(
      "#BC3C29",  # NEJM Red
      "#0072B5",  # NEJM Blue
      "#E18727",  # Orange
      "#20854E",  # Green
      "#7876B1",  # Purple
      "#6F99AD",  # Light blue
      "#FFDC91",  # Light yellow
      "#EE4C97"   # Pink
    ),
    
    # Nature Publishing Group (inspired by Nature Reviews Cancer)
    nature = c(
      "#E64B35",  # Cinnabar red
      "#4DBBD5",  # Sky blue
      "#00A087",  # Persian green
      "#3C5488",  # Chambray blue
      "#F39B7F",  # Apricot
      "#8491B4",  # Wild blue yonder
      "#91D1C2",  # Monte carlo green
      "#DC0000",  # Monza red
      "#7E6148",  # Roman coffee
      "#B09C85"   # Sandrift
    ),
    
    # Lancet (inspired by Lancet Oncology)
    lancet = c(
      "#00468B",  # Deep blue
      "#ED0000",  # Lancet red
      "#42B540",  # Green
      "#0099B4",  # Cyan
      "#925E9F",  # Purple
      "#FDAF91",  # Light orange
      "#AD002A",  # Dark red
      "#ADB6B6",  # Light grey
      "#1B1919"   # Dark grey
    ),
    
    # JAMA (Journal of the American Medical Association)
    jama = c(
      "#374E55",  # Dark blue-grey
      "#DF8F44",  # Orange
      "#00A1D5",  # Cyan
      "#B24745",  # Red
      "#79AF97",  # Green
      "#6A6599",  # Purple
      "#80796B"   # Brown-grey
    ),
    
    # Science (AAAS)
    science = c(
      "#3B4992",  # Deep blue
      "#EE0000",  # Red
      "#008B45",  # Green
      "#631879",  # Purple
      "#008280",  # Teal
      "#BB0021",  # Dark red
      "#5F559B",  # Purple-blue
      "#A20056",  # Magenta
      "#808180",  # Grey
      "#1B1919"   # Dark grey
    ),
    
    # JCO (Journal of Clinical Oncology)
    jco = c(
      "#0073C2",  # Blue
      "#EFC000",  # Yellow
      "#868686",  # Grey
      "#CD534C",  # Red
      "#7AA6DC",  # Light blue
      "#003C67",  # Dark blue
      "#8F7700",  # Dark yellow
      "#3B3B3B",  # Dark grey
      "#A73030",  # Dark red
      "#4A6990"   # Blue-grey
    )
  )
  
  # Get requested palette
  if (!type %in% names(palettes)) {
    stop(sprintf("Unknown clinical color type '%s'. Available types: %s", 
                 type, paste(names(palettes), collapse = ", ")))
  }
  
  colors <- palettes[[type]]
  
  # For treatment palette, ensure placebo is first if requested
  if (type == "treatment" && !placebo_first) {
    colors <- c(colors[-1], colors[1])  # Move placebo to end
  }
  
  # Return requested number of colors or full palette
  if (is.null(n)) {
    return(colors)
  } else {
    if (n > length(colors)) {
      warning(sprintf("Requested %d colors but palette '%s' only has %d colors. Recycling colors.", 
                      n, type, length(colors)))
      colors <- rep_len(colors, n)
    }
    return(colors[1:n])
  }
}

#' Detect Treatment Groups for Color Assignment
#'
#' @description
#' Automatically detects placebo and treatment groups from treatment variable
#' and assigns appropriate colors following clinical conventions.
#'
#' @param treatment_var Character vector of treatment names.
#' @param palette_type Character string specifying color palette type.
#'
#' @return Named character vector of colors with treatment names as names.
#'
#' @details
#' This function uses pattern matching to identify placebo groups and
#' assigns neutral grey color, while active treatments get distinct colors.
#' 
#' Placebo detection patterns include: "placebo", "control", "sham", 
#' case-insensitive matching.
#'
#' @examples
#' treatments <- c("Placebo", "Drug A 10mg", "Drug A 20mg")
#' colors <- assign_treatment_colors(treatments)
#' 
#' @export
assign_treatment_colors <- function(treatment_var, palette_type = "treatment") {
  
  unique_treatments <- unique(treatment_var)
  n_treatments <- length(unique_treatments)
  
  # Get clinical colors
  colors <- clinical_colors(palette_type, n = n_treatments)
  
  # Identify placebo/control groups
  placebo_patterns <- c("placebo", "control", "sham", "vehicle")
  
  placebo_idx <- which(
    grepl(paste(placebo_patterns, collapse = "|"), 
          unique_treatments, ignore.case = TRUE)
  )
  
  # Assign colors with placebo first (grey)
  color_assignment <- colors
  names(color_assignment) <- unique_treatments
  
  # Ensure placebo gets grey color if detected
  if (length(placebo_idx) > 0 && palette_type == "treatment") {
    # Move placebo to position 1 (grey) and shift others
    placebo_name <- unique_treatments[placebo_idx[1]]
    other_names <- unique_treatments[-placebo_idx[1]]
    
    color_assignment <- c(
      setNames(colors[1], placebo_name),  # Grey for placebo
      setNames(colors[2:n_treatments], other_names)
    )
  }
  
  return(color_assignment)
}

#' Apply Clinical Color Scheme to ggplot
#'
#' @description
#' Convenience function to apply clinical color schemes to ggplot objects.
#'
#' @param plot A ggplot object.
#' @param treatment_var Character string specifying the treatment variable name.
#' @param palette_type Character string specifying the clinical palette type.
#' @param ... Additional arguments passed to scale_color_manual and scale_fill_manual.
#'
#' @return Modified ggplot object with clinical colors applied.
#'
#' @examples
#' \dontrun{
#' library(ggplot2)
#' 
#' # Create sample data
#' data <- data.frame(
#'   visit = rep(1:4, each = 10),
#'   efficacy = rnorm(40, mean = 50, sd = 10),
#'   treatment = rep(c("Placebo", "Drug A"), length.out = 40)
#' )
#' 
#' # Create base plot
#' p <- ggplot(data, aes(x = visit, y = efficacy, color = treatment)) +
#'   geom_line()
#' 
#' # Apply clinical colors
#' p_clinical <- apply_clinical_colors(p, "treatment")
#' }
#' 
#' @export
apply_clinical_colors <- function(plot, treatment_var = NULL, 
                                  palette_type = "treatment", ...) {
  
  # Extract data from plot if treatment_var not specified
  if (is.null(treatment_var)) {
    # Try to detect color/fill aesthetic
    plot_data <- plot$data
    aesthetics <- plot$mapping
    
    if ("colour" %in% names(aesthetics)) {
      treatment_var <- as.character(aesthetics$colour)[2]  # Remove ~
    } else if ("fill" %in% names(aesthetics)) {
      treatment_var <- as.character(aesthetics$fill)[2]
    } else {
      stop("Cannot detect treatment variable. Please specify treatment_var.")
    }
  }
  
  # Get treatment levels from plot data
  if (treatment_var %in% names(plot$data)) {
    treatments <- unique(plot$data[[treatment_var]])
  } else {
    warning("Treatment variable not found in plot data. Using default colors.")
    return(plot)
  }
  
  # Get color assignment
  color_map <- assign_treatment_colors(treatments, palette_type)
  
  # Apply to plot
  plot +
    ggplot2::scale_color_manual(values = color_map, ...) +
    ggplot2::scale_fill_manual(values = color_map, ...)
}