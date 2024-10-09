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
                   response = NULL, ...) {

  if ( !is.logspace(data) ) {
    logWarning("t-test")
  }

  if ( is.null(response) && is.tr_data(data) ) {
    response <- .get_response(data)
  }

  data_prep <- prepCalcData(data, feats = apts, paired = paired,
                            response = response)

  disease_idx <- data_prep$which_disease
  t_data <- apply(data_prep$data, 2, column_t, which = disease_idx,
                  paired = paired, ...) |> t() |> data.frame()

  ret.list             <- list()
  ret.list$stat.table  <- calc_stat_table(t_data, bh = bh)
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
    add_class(c("stat_table", "t_table"))
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
print.t_table <- function(x, n = 6L, ...) {
  cat("\n")
  writeLines(signal_rule("Stat Table", line_col = "blue"))
  print(utils::head(x$stat.table, n))
  invisible(x)
}


#' @describeIn calc.t
#'   The S3 `write_stat_table` method for class `t_table`.
#' @export
write_stat_table.t_table <- write_stat_table.ks_table
