#' Create Kruskal-Wallis Table
#'
#' Computes the Kruskal-Wallis univariate test statistic
#' given a response column for each variable in the data matrix.
#' One-way ANOVA on ranks (non-parametric).
#'
#' @family calc
#' @inheritParams calc.ks
#' @inherit params return
#' @param response Character. The column name to use as the response
#'   grouping. Expected to be a factor with > 2 levels.
#' @param ... Additional arguments passed to [kruskal.test()].
#' @author Stu Field
#' @references Myles Hollander and Douglas A. Wolfe (1973),
#'   *Nonparametric Statistical Methods*. New York: John Wiley & Sons. Pages 115-120.
#' @seealso [kruskal.test()]
#' @examples
#' # Create multi-level variable
#' sim_test_data$Response <- factor(paste(sim_test_data$class_response,
#'                                        sim_test_data$gender, sep = "_"))
#' print(levels(sim_test_data$Response))
#'
#' kw_table <- calc.kw(sim_test_data, response = "Response")
#'
#' @importFrom stats kruskal.test
#' @export
calc.kw <- function(data, apts = NULL, response = NULL, bh = TRUE, ...) {

  if ( is.null(response) && is.tr_data(data) ) {
    response <- .get_response(data)
  }
  if ( is.factor(data[[response]]) ) {
    data <- refactorData(data)
  } else if ( is.Integer(data[[response]]) ) {
    data[[response]] <- as.character(data[[response]])
  } else {
    data[[response]] <- factor(data[[response]])
  }

  test_tab <- table(data[[response]])

  if ( length(test_tab) <= 2L ) {
    stop(
      "Inappropriate number of factor levels in the ",
      value(response), " column: ", value(length(test_tab)),
      ".", call. = FALSE
    )
  }

  if ( is.null(apts) ) {
    apts <- getAnalytes(data)
  }

  kw_stats <- lapply(apts, function(.apt) {
      test <- createFormula(.apt, sprintf("factor(%s)", response)) |>
        kruskal.test(data = data, ...)
      data.frame(row.names = .apt,           H       = test$statistic,
                 df        = test$parameter, p.value = test$p.value)
    })
  kw_stats <- do.call(rbind, kw_stats)  # do.call() b/c map_df() zaps rn

  ret.list            <- list()
  ret.list$stat.table <- calc_stat_table(kw_stats, bh = bh)
  ret.list$test       <- "Kruskal-Wallis rank sum test"
  ret.list$call       <- match.call()
  ret.list$data.dim   <- dim(data)
  ret.list$response   <- response
  ret.list$counts     <- c(table(data[[response]]))
  ret.list$data.frame <- deparse(ret.list$call[[2L]])
  if ( withr::with_preserve_seed(runif(1) < 0.25) ) gPraise()
  ret.list |>
    addClass(c("stat_table", "kw_table"))
}


#' @describeIn calc.kw
#' S3 print method for `kw_table` objects.
#' @param x An object of class `kw_table`.
#' @examples
#' # S3 print method
#' kw_table
#'
#' @export
print.kw_table <- function(x, n = 6, ...) {
  cat("\n")
  writeLines(signal_rule("Stat Table", line_col = "blue"))
  print(utils::head(x$stat.table, n))
  invisible(x)
}


#' @describeIn calc.kw
#' The S3 `writeStatTable` method for class `kw_table`.
#' @examples
#' # S3 writeStatTable method
#' apt_data <- getAnalyteInfo(sim_test_data)
#' kw_table$stat.table <- addTargetInfo(kw_table$stat.table, apt_data)
#' f_out <- tempfile("kw-table-", fileext = ".csv")
#' writeStatTable(kw_table, file = f_out)
#' @export
writeStatTable.kw_table <- function(x, file) {
  withr::local_output_sink(file, append = TRUE)
  cat("\n")
  renameStatTable(x$stat.table) |> rn2col("AptName") |>
    format(digits = 7L) |>
    write_uni_table(file = file)
  invisible(file)
}
