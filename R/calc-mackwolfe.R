#' Create Mack-Wolfe Table
#'
#' Computes the Mack-Wolfe univariate non-parametric test statistic
#' given a response column and ordering for each variable in the data matrix.
#'
#' Distribution free test of a peak or trends (JT-test). If the JT-test
#' is desired, set `peak = "jt"`.
#'
#' @family calc
#' @inheritParams params
#' @inheritParams mackwolfe
#' @param response Character. The name of the column in `data`
#'   containing the grouping information for the Mack-Wolfe test.
#' @param ... Additional arguments passed to [mackwolfe()], particularly
#'   `verbose` or `nperm`.
#' @return A list object of class `c(stat_table, mackwolfe_table)` containing:
#'   \item{stat.table}{A data frame (table) of the statistical results.}
#'   \item{call}{The direct call made the `calc.mackwolfe`.}
#'   \item{test}{The name of the test performed, "Mack-Wolfe Test".}
#'   \item{data.dim}{The dimensions of the data frame used for testing.}
#'   \item{peak}{The peak factor level assumed by the test.}
#'   \item{response}{The "Response" column used in the statistical test.}
#'   \item{factor.order}{The ordering of the "Response" column factor levels.}
#'   \item{counts}{Group counts split by the "Response" column.}
#'   \item{data.frame}{The name of the data frame containing the RFU data.}
#'
#'   The `stat.table` contains:
#'     + __Ap__: The Mack-Wolfe test statistics.
#'     + __Astar__: The z-transform of `Ap`.
#'     + __n__: Number of samples used in calculating `Ap`.
#'     + __peak__: The string level of the peak and its factor level (`k`).
#'     + __p.value__: Unadjusted p-values for the `Astar` test statistics.
#'     + __fdr or q.value__: FDR adjustment to p-values (either BH or Storey).
#'     + __p.bonferroni__: Bonferroni corrected p-value.
#'     + __rank__: Ranking by the test significance.
#' @author Stu Field
#' @seealso [mackwolfe()]
#' @references Myles Hollander and Douglas A. Wolfe (1973).
#'   *Nonparametric Statistical Methods*. New York: John Wiley & Sons. Pages 115-120.
#' @examples
#' lett <- head(LETTERS, 4)
#' sim_test_data$group <- factor(rep(lett, each = nrow(sim_test_data) / 4L))
#'
#' # Peak at "B"
#' mack <- calc.mackwolfe(sim_test_data, response = "group", peak = "B")
#'
#' # S3 print method
#' mack
#'
#' # Permutation P-value estimation
#' # This is time consuming to run for all features
#' # so we use only the top features from above
#' # with nperm > 1000 is recommended
#' feats  <- rownames(head(mack$stat.table, 10L))
#' new_df <- dplyr::select(sim_test_data, group, all_of(feats))
#' mack_perm <- calc.mackwolfe(new_df, response = "group", nperm = 100, peak = "B")
#'
#' @export
calc.mackwolfe <- function(data, apts = NULL, response = NULL,
                           peak, bh = TRUE, ...) {

  if ( missing(peak) ) {
    stop(
      "Please explicitly declare a `peak =` argument.\n",
      "If you wish to perform a 'peak unknown' test, set `peak = NULL`.\n",
      "If you wish to perform a 'JT-test', set `peak = 'jt'`.\n",
      "Otherwise, set the peak equal to the known desired value ",
      "using a character string, e.g. 'July'.", call. = FALSE
    )
  }
  
  if ( is.null(response) && is.tr_data(data) ) {
    response <- .get_response(data)
  }

  data_prep <- prepCalcData(data, feats = apts, response = response, binary = FALSE)
  apts      <- data_prep$feats
  gr_vec    <- data[[response]]
  mackwolfe_stats <- lapply(apts, function(.apt) {
      mw <- mackwolfe(x = data[[.apt]], group = gr_vec, peak = peak, ...)
      data.frame(row.names = .apt, Ap = mw$Ap, Astar = mw$Astar, n = mw$n,
                 peak = mw$peak, p.value = mw$p.value)
    })
  mackwolfe_stats <- do.call(rbind, mackwolfe_stats)

  ret.list              <- list()
  ret.list$stat.table   <- calc_stat_table(mackwolfe_stats, bh = bh)
  ret.list$test         <- ifelse(peak == "jt", "Mack-Wolfe (JT) Test",
                                  "Mack-Wolfe Test")
  ret.list$call         <- match.call(expand.dots = TRUE)
  ret.list$data.dim     <- dim(data)
  ret.list$peak         <- peak
  ret.list$response     <- response
  ret.list$factor.order <- levels(gr_vec)
  ret.list$data.frame   <- deparse(ret.list$call[[2L]])
  ret.list$counts       <- as.table(table(data[[response]])[levels(gr_vec)])
  if ( withr::with_preserve_seed(runif(1) < 0.25) ) gPraise()
  ret.list |>
    addClass(c("stat_table", "mackwolfe_table"))
}


#' Create Jonckheere-Terpstra (JT) Table
#'
#' @rdname calc.mackwolfe
#' @examples
#' # Thin wrapper for JT-test
#' # peak = "jt"
#' calc.jt(sim_test_data, response = "group")
#'
#' @export
calc.jt <- function(data, apts = NULL, response = "SampleGroup", bh = TRUE, ...) {
  .call       <- match.call(expand.dots = TRUE)
  .call$peak  <- "jt"
  .call[[1L]] <- as.name("calc.mackwolfe")
  eval.parent(.call)
}


#' @describeIn calc.mackwolfe
#' S3 print method for `mackwolfe_table` objects.
#' @param x An object of class `mackwolfe_table`.
#' @export
print.mackwolfe_table <- function(x, n = 6, ...) {
  key   <- pad(c("Factor order", "Peak"), 25)
  value <- c(paste(x$factor.order, collapse = "-"), x$peak)
  writeLines(paste(" ", key, value))
  cat("\n")
  writeLines(signal_rule("Stat Table", line_col = "blue"))
  print(utils::head(x$stat.table, n))
  invisible(x)
}


#' @describeIn calc.mackwolfe
#' The S3 `writeStatTable` method for class `mackwolfe_table`.
#' @examples
#' # S3 writeStatTable method
#' apt_data <- getAnalyteInfo(sim_test_data)
#' mack$stat.table <- addTargetInfo(mack$stat.table, apt_data)
#' f_out <- tempfile("mack-table-", fileext = ".csv")
#' writeStatTable(mack, file = f_out)
#' @export
writeStatTable.mackwolfe_table <- function(x, file) {
  withr::local_output_sink(file, append = TRUE)
  cat("Response order,", paste(x$factor.order, collapse = " - "), "\n", sep = "")
  cat("Response peak,", x$peak, "\n\n", sep = "")
  renameStatTable(x$stat.table) |> rn2col("AptName") |>
    format(digits = 7L) |>
    write_uni_table(file = file)
  invisible(file)
}
