#' Calculate Student's t-statistics Table
#'
#' Computes t-statistics for a supplied data set (ADAT).
#'
#' @family calc
#' @inheritParams params
#' @inherit params return
#' @param paired Logical. Indicating whether the data are paired or not.
#' @param ... The `rm.outliers = TRUE` option should be passed here, otherwise
#'   additional arguments to allow extensibility to S3 methods.
#' @author Mike Mehan and Stu Field
#' @examples
#' t_table <- calc.t(log10(sim_test_data), response = "class_response")
#'
#' # minor differences; some outliers removed
#' t2 <- calc.t(log10(sim_test_data), response = "class_response", rm.outliers = TRUE)
#' @export
calc.t <- function(data, apts = NULL, bh = TRUE, paired = FALSE,
                   response = "Response", ...) {

  if ( !is.logspace(data) ) {
    logWarning("t-test")
  }

  data_prep <- prepCalcData(data, feats = apts, paired = paired,
                            response = response)

  disease_idx <- data_prep$which_disease
  t_data <- apply(data_prep$data, 2, column_t, which = disease_idx,
                  paired = paired, ...) |> t() |> data.frame()

  ret.list             <- list()
  ret.list$stat.table  <- calcStatTable(t_data, bh = bh)
  ret.list$call        <- match.call(expand.dots = TRUE)
  ret.list$test        <- "Student t-test"
  ret.list$paired      <- paired
  ret.list$response    <- response
  ret.list$counts      <- c(table(data[[response]]))
  ret.list$rm.outliers <- list(...)$rm.outliers %||% FALSE
  ret.list$log         <- is.logspace(data)
  ret.list$data.frame  <- deparse(ret.list$call[[2L]])
  ret.list$data.dim    <- dim(data)
  if ( withr::with_preserve_seed(runif(1) < 0.25) ) gPraise()
  ret.list |>
    addClass(c("stat_table", "t_table"))
}


#' @describeIn calc.t
#' S3 print method for `t_table` objects.
#' @param x An object of class `t_table`.
#' @examples
#' # S3 print method
#' t_table
#' t2
#'
#' @export
print.t_table <- function(x, n = 6, ...) {
  cat("\n")
  writeLines(signal_rule("Stat Table", line_col = "blue"))
  print(utils::head(x$stat.table, n))
  invisible(x)
}


#' @describeIn calc.t
#' The S3 `writeStatTable` method for class `t_table`.
#' @examples
#' # S3 writeStatTable method
#' apt_data <- getAnalyteInfo(sim_test_data)
#' t_table$stat.table <- addTargetInfo(t_table$stat.table, apt_data)
#' f_out <- tempfile("t-table-", fileext = ".csv")
#' writeStatTable(t_table, file = f_out)
#' @export
writeStatTable.t_table <- writeStatTable.ks_table
