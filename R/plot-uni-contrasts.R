#' Contrast 2 Univariate Tables
#'
#' Compare 2 `univariate` tables from any two analyses
#'   from the [calc_univariate()] function.
#'
#' @param x The first univariate tibble to contrast (x-axis).
#' @param y The second univariate tibble to contrast (y-axis).
#' @param cutoff `numeric(1)`. A `p-value` cutoff for comparison of tables.
#' @param ident `logical(1)`. Should the points beyond the cutoff be identified?
#' @param label_size `numeric(1)`. The size for the labels if `ident = TRUE`.
#'
#' @return A `ggplot` object.
#' @author Stu Field
#'
#' @examples
#' a <- calc_univariate(mtcars, var = "vs")
#' b <- calc_univariate(mtcars, var = "mpg", "lm")
#' plot_uni_contrasts(a, b, ident = TRUE, cutoff = 0.005)
#' @importFrom ggplot2 geom_point ggplot geom_text
#' @importFrom ggplot2 labs aes geom_hline geom_vline
#' @importFrom dplyr mutate select filter full_join
#' @export
plot_uni_contrasts <- function(x, y, cutoff = 0.05 / nrow(x),
                               ident = FALSE, label_size = 2.5) {

  if ( !(inherits(x, "uni_tbl") && inherits(y, "uni_tbl")) ) {
    stop(
      "Class of `x` and `y` is wrong. ",
      "Were they both created via `calc_univariate()`?",
      call. = FALSE
    )
  }

  common <- intersect(x$feature, y$feature)

  x <- filter(x, x$feature %in% common)
  y <- filter(y, y$feature %in% common)
  lab <- bquote(-italic(log)[10] ~ (italic(p) - value))

  plot_df <- full_join(x, y, by = "feature", suffix = c("_x", "_y")) |>
    select(feature, p_value_x, p_value_y) |>
    mutate(
      x_cutoff = p_value_x <= cutoff,
      y_cutoff = p_value_y <= cutoff,
      xy       = x_cutoff & y_cutoff,
      xory     = x_cutoff | y_cutoff,
      xnoty    = x_cutoff & (!y_cutoff),
      ynotx    = y_cutoff & (!x_cutoff)
    )

  c1 <- "#24135F"
  c2 <- "#00A499"
  c3 <- "#840B55"
  linecol <- "#54585A"
  border <- "black"
  alpha <- 0.7

  plot_df |>
    ggplot(aes(x = -log10(p_value_x), y = -log10(p_value_y))) +
    geom_point(alpha = alpha, size = 1.5) +
    geom_point(data = filter(plot_df, xnoty), pch = 21, alpha = alpha,
               colour = border, size = 2.5, fill = c2) +
    geom_point(data = filter(plot_df, ynotx), pch = 21, alpha = alpha,
               colour = border, size = 2.5, fill = c3) +
    geom_point(data = filter(plot_df, xy), pch = 21, alpha = alpha,
               colour = border, size = 3.5, fill = c1) +
    labs(x = lab, y = lab) + {
      if ( ident ) {
        geom_text(
          data = filter(plot_df, xory), aes(label = feature),
          hjust = "inward", size = label_size, check_overlap = TRUE
        )
      }
    } +
    geom_hline(yintercept = -log10(cutoff), linetype = "dashed", colour = linecol) +
    geom_vline(xintercept = -log10(cutoff), linetype = "dashed", colour = linecol) +
    libml_theme()
}
