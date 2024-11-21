
# this wrapper is necessary following the deprecation of
# purrr::cross_df(). Recommended to use tidyr::expand_grid()
# but that function is slow and re-orders the rows by variable
# relative to either expand.grid() or cross_df()
# this is for internal use only

#' @importFrom tibble as_tibble
#' @noRd
expand_grid <- function(...) {
  out <- expand.grid(..., KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  as_tibble(out)
}

# @param x a tr_data object
.get_response <- function(x) {
  attr(x, "response_var")
}

is_soma_adat <- getFromNamespace("is_soma_adat", "helpr")
is_seq <- getFromNamespace("is_seq", "helpr")
add_seq <- getFromNamespace("add_seq", "helpr")
get_analytes <- getFromNamespace("get_analytes", "helpr")
get_meta <- getFromNamespace("get_meta", "helpr")

col_palette <- list(
  purple     = "#24135F",
  lightgreen = "#00A499",
  lightgrey  = "#707372",
  magenta    = "#840B55",
  lightblue  = "#006BA6",
  yellow     = "#D69A2D",
  darkgreen  = "#007A53",
  darkblue   = "#1B365D",
  darkgrey   = "#54585A",
  blue       = "#004C97"
)

libml_theme <- function(base_size = 12,
                        base_family = "",
                        legend_pos = c("top", "none", "right", "left", "bottom"),
                        hjust = 0,
                        aspect_ratio = c("none", "landscape", "profile")) {
  grey <- col_palette$lightgrey
  ggplot2::theme_bw(
    base_size = base_size,
    base_family = base_family,
    base_line_size = base_size / 20) +
  ggplot2::theme(
    plot.background = ggplot2::element_rect(fill = "transparent", color = NA),
    plot.title = ggplot2::element_text(hjust = hjust, size = ggplot2::rel(1.5)),
    legend.position = match.arg(legend_pos),
    legend.background = ggplot2::element_rect(fill = "transparent", color = NA),
    legend.key = ggplot2::element_rect(fill = "transparent", color = NA),
    aspect.ratio = switch(match.arg(aspect_ratio),
                          landscape = 9 / 16,
                          profile = 11 / 8.5,
                          none = NULL),
    axis.ticks = ggplot2::element_line(color = grey),
    axis.ticks.length = ggplot2::unit(8, "points"),
    axis.text.x = ggplot2::element_text(color = grey, size = ggplot2::rel(1.2)),
    axis.text.y = ggplot2::element_text(color = grey, size = ggplot2::rel(1.2)),
    axis.line = ggplot2::element_line(color = grey, linewidth = 0.2),
    panel.background = ggplot2::element_rect(fill = "transparent", color = NA),
    panel.border = ggplot2::element_blank(),
    panel.grid = ggplot2::element_line(color = "#B9BDBE", linewidth = 0.2),
    strip.background = element_blank())
}
