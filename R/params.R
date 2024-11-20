#' Common Parameters in \pkg{libml}
#'
#' The parameters below are commonly used throughout
#'   the \pkg{libml} package.
#'
#' @name params
#'
#' @param truth `character(n)` or `factor(n)`. A vector of true class names.
#'   In most instances you will have to also pass a `pos_class` argument
#'   defining the positive/event class.
#'
#' @param predicted `numeric(n)`. A numeric vector of class probabilities.
#'
#' @param pos_class `character(1)`. Name of the "positive" or "event" class.
#'
#' @param cutoff `numeric(1)`. A cutoff for the decision/operating point,
#'   predictions above which are considered the _positive_ class.
#'
#' @param main `character(1)`. Optional string for the plot title.
#'
#' @param y_lab `character(1)`. Optional label for the y-axis.
#'
#' @param alpha `numeric(1)` in \verb{[0, 1]}. The color transparency.
#'   See also [ggplot2::alpha()].
#'
#' @param color `character(1)` or `integer(1)`. Specify the colors for
#'   lines, points, bar, box, or ROC.
#'
#' @param col `character(1)` or `integer(1)`. Specify the colors for
#' lines, points, bar, box, or ROC.
#'
#' @param data A `tibble` or `data.frame` object containing data for analysis.
#'   Should often contain a "Response" column indicating the
#'   response variable, often the grouping variable.
#'
#' @param feats `character(n)`. A vector of features, usually column names
#'   of a data frame.
#'
#' @param formula A `formula` class object, specifying
#'   the model to be fitted (e.g. \eqn{response ~ x_1 + x_2 + ... + x_n}).
#'
#' @param response `character(1)`. The column name to use as the
#'   response grouping. Expected to be a factor with 2 levels.
#'   If not a factor, `response` will be coerced to a
#'   factor (i.e. alphabetical order). Level 2 of the factor is
#'   considered the `disease/case` group, thus positive values
#'   for the statistic indicate up-regulation in `Level2` compared `Level1`.
#'
#' @param nboot `integer(1)`. The number of bootstrap estimates to perform.
#'
#' @param r_seed `integer(1). The value of the random seed if
#'   reproducibility is desired.
NULL
