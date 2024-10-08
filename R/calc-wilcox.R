#' Calculate Wilcoxon/Mann-Whitney Table
#'
#' Computes either the Wilcoxon signed rank test (if `paired = TRUE`)
#' or the Wilcoxon rank sum test (if `paired = FALSE`; default)
#' aka the Mann-Whitney U. The function [calc.mw()] is a wrapper
#' for [calc.wilcox()] with the `paired = FALSE` (default) and is
#' maintained for backward compatibility.
#'
#' The following is from [wilcox.test()]:\cr
#'
#' If only `x` is given, or if both x and y are given and
#' `paired = TRUE`, a Wilcoxon signed rank test of the null that
#' the distribution of x (in the one sample case) or of `x - y` (in
#' the paired two sample case) is symmetric about mu is performed.
#'
#' Otherwise, if both x and y are given and `paired = FALSE`,
#' a Wilcoxon rank sum test (equivalent to the Mann-Whitney test)
#' is carried out. In this case, the null hypothesis is
#' that the distributions of x and y differ by a location shift
#' of mu and the alternative is that they differ by some other
#' location shift (and the one-sided alternative "greater" is that
#' x is shifted to the right of y).
#'
#' By default (if exact is not specified), an exact p-value is
#' computed if the samples contain less than 50 finite values and
#' there are no ties. Otherwise, a normal approximation is used.
#'
#' @family calc
#' @inheritParams params
#' @inheritParams calc.t
#' @inherit params return
#' @param ... Additional arguments passed to ultimately [wilcox.test()], or
#'   the `rm.outliers = TRUE` option can also be passed. Otherwise arguments
#'   required by other S3 generics.
#' @author Stu Field
#' @seealso [wilcox.test()]
#' @examples
#' # Suppress p-value ties warning
#' w  <- calc.wilcox(sim_test_data, response = "class_response")
#'
#' # Mann-Whitney wrapper
#' mw <- calc.mw(sim_test_data, response = "class_response")  # same
#'
#' # Remove outliers
#' w2 <- calc.wilcox(sim_test_data, response = "class_response", rm.outliers = TRUE)
#'
#' @export
calc.wilcox <- function(data, apts = NULL, paired = FALSE,
                        response = NULL, bh = TRUE, ...) {

  if ( is.null(response) && is.tr_data(data) ) {
    response <- .get_response(data)
  }

  data_prep   <- prepCalcData(data, feats = apts, paired = paired,
                              response = response)
  disease_idx <- data_prep$which_disease
  wilcox_df <- apply(data_prep$data, 2, column_wilcox, which = disease_idx,
                     paired = paired, ...) |> t() |> data.frame()

  if ( paired ) {
    names(wilcox_df) <- gsub("^U$", "W", names(wilcox_df))
  }

  ret.list             <- list()
  ret.list$stat.table  <- calc_stat_table(wilcox_df, bh = bh)
  ret.list$test        <- ifelse(paired,
                                 "Wilcoxon signed-rank test",
                                 "Wilcoxon rank-sum test (Mann-Whitney)")
  ret.list$call        <- match.call(expand.dots = TRUE)
  ret.list$paired      <- paired
  ret.list$response    <- response
  ret.list$counts      <- c(table(data[[response]]))
  ret.list$rm.outliers <- list(...)$rm.outliers %||% FALSE
  ret.list$data.frame  <- deparse(ret.list$call[[2L]])
  ret.list$data.dim    <- dim(data)
  if ( withr::with_preserve_seed(runif(1) < 0.25) ) gPraise()
  ret.list |>
    addClass(c("stat_table", "wilcox_table"))
}


#' Calculate Mann-Whitney Table
#'
#' A wrapper for calc.wilcox() and backward compatibility.
#'
#' @rdname calc.wilcox
#' @export
calc.mw <- function(...) calc.wilcox(..., paired = FALSE)


#' @describeIn calc.wilcox
#' S3 print method for `wilcox_table` objects.
#' @param x An object of class `wilcox_table`.
#' @examples
#' # S3 print method
#' w
#' mw
#' w2
#'
#' @export
print.wilcox_table <- function(x, n = 6L, ...) {
  cat("\n")
  writeLines(signal_rule("Stat Table", line_col = "blue"))
  print(utils::head(x$stat.table, n))
  invisible(x)
}


#' @describeIn calc.wilcox
#'   The S3 `writeStatTable` method for class `wilcox_table`.
#' @export
writeStatTable.wilcox_table <- writeStatTable.ks_table
