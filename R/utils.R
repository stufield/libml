
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

is.soma_adat <- getFromNamespace("is.soma_adat", "helpr")
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
