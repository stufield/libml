#' Common Parameters in \pkg{libml}
#'
#' The parameters below are commonly used throughout
#'   the \pkg{libml} package.
#'
#' @name params
#'
#' @param truth Character or factor. A vector of true class names.
#'   In most instances you will have to also pass a `pos.class` argument
#'   defining the positive/event class.
#'
#' @param predicted Numeric. A numeric vector of class probabilities.
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
#' @param data A `soma_adat` or `data.frame` object containing RFU data.
#'   Should contain a "Response" column/field indicating the dependent
#'   response variable, often the grouping variable. The `response =`
#'   variable can also be specified to override the default.
#'
#' @param apts Character vector of `AptNames` to use. If `NULL` (default),
#'   all analyte RFU fields in `data` are used.
#'
#' @param response Character. The column name to use as the
#'   response grouping. Expected to be a factor with 2 levels.
#'   If not a factor, `response` will be coerced to a
#'   factor (i.e. alphabetical order). Level 2 of the factor is
#'   considered the `disease/case` group, thus positive values
#'   for the statistic indicate up-regulation in `Level2` compared `Level1`.
#'
#' @param bh Logical. Indicating whether returned p-values will be
#'   adjusted for false discovery by "Benjamini & Hochberg"
#'   correction (`TRUE`) or by Storey's q-value correction.
#'
#' @param n Integer. The number of rows to show in the S3 print method.
#'
#' @param file A file name to write table output, typically a `*.csv`.
#'
#' @param nboot Integer. The number of bootstrap estimates to perform.
#'
#' @param r.seed Integer. The value of the random seed if
#'   reproducibility is desired.
#'
#' @return A list object of class `c(stat_table, *_table)` containing:
#' \item{stat.table}{A data frame (table) of the statistical results (see below)}
#' \item{test}{The name of the statistical test performed, e.g. "KS-test".}
#' \item{call}{The direct call made the `calc.*()`.}
#' \item{paired}{Logical. Whether the values are paired (if applicable).}
#' \item{response}{The "Response" column used in the statistical test.}
#' \item{counts}{Group counts split by the "Response" column (if applicable).}
#' \item{log}{Logical. Whether the RFU values were log10-transformed.}
#' \item{data.frame}{The name of the data frame containing the RFU data.}
#' \item{data.dim}{The dimensions of the data frame used for testing.}
#'
#' The `stat.table` contains:
#'   + __Test Statistic__: KS-distance, t-statistic, U, W, H, r, rho, tau, etc.
#'   + __Signed Statistic__: Signed test statistic (if applicable).
#'   + __p.value__: Unadjusted p-values for the test statistic.
#'   + __fdr or q.value__: FDR adjustment to p-values (either BH or Storey).
#'   + __p.bonferroni__: Bonferroni corrected p-value.
#'   + __rank__: Ranking by p-value.
#'   + __`loCI95`__: Lower 95% confidence interval ([calc.cor()] Pearson only).
#'   + __`hiCI95`__: Lower 95% confidence interval ([calc.cor()] Pearson only).
NULL
