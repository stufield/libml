#' Common Parameters in \pkg{libml}
#'
#' The parameters below are commonly used throughout
#'   the \pkg{libml} package.
#'
#' @name params
#'
#' @param truth `character(n)` or `factor(n)`. A vector of true class names.
#'   In most instances you will have to also pass a `pos.class` argument
#'   defining the positive/event class.
#'
#' @param predicted `numeric(n)`. A numeric vector of class probabilities.
#'
#' @param pos.class Character. Name of the "positive" or "event" class.
#'
#' @param cutoff Numeric. A cutoff for the decision/operating point,
#'   predictions above which are considered the _positive_ class.
#'
#' @param main Character. Optional string for the plot title.
#'
#' @param y.lab Character. Optional label for the y-axis.
#'
#' @param alpha Numeric in \verb{[0, 1]}. The color transparency level.
#' See also [ggplot2::alpha()].
#'
#' @param color Character or integer. Specify the colors for
#'   lines, points, bar, box, or ROC.
#'
#' @param col Character or integer. Specify the colors for
#' lines, points, bar, box, or ROC.
#'
#' @param data A `tibble` or `data.frame` object containing data for analysis.
#'   Should often contain a "Response" column indicating the
#'   response variable, often the grouping variable.
#'
#' @param feats Character vector of features, usually column names
#'   of a data frame.
#'
#' @param response Character. The column name to use as the
#'   response grouping. Expected to be a factor with 2 levels.
#'   If not a factor, `response` will be coerced to a
#'   factor (i.e. alphabetical order). Level 2 of the factor is
#'   considered the `disease/case` group, thus positive values
#'   for the statistic indicate up-regulation in `Level2` compared `Level1`.
#'
#' @param nboot Integer. The number of bootstrap estimates to perform.
#'
#' @param r.seed Integer. The value of the random seed if
#'   reproducibility is desired.
NULL
