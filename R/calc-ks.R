#' Calculate KS-distance Table
#'
#' Computes KS distances for a supplied data set (ADAT).
#'
#' @family calc
#' @inheritParams params
#' @inherit params return
#' @param ... The `rm.outliers = TRUE` option should be passed here, otherwise
#'   additional arguments to allow extensibility to S3 methods.
#' @author Mike Mehan and Stu Field
#' @seealso [create_train()]
#' @examples
#' # suppress p-value ties warning
#' ks_table <- calc.ks(sim_test_data, response = "class_response")
#'
#' # minor differences; some outliers removed
#' ks2 <- calc.ks(sim_test_data, response = "class_response", rm.outliers = TRUE)
#'
#' @importFrom stats runif
#' @export
calc.ks <- function(data, apts = NULL, response = NULL, bh = TRUE, ...) {

  if ( is.null(response) && is.tr_data(data) ) {
    response <- .get_response(data)
  }
  data_prep   <- prepCalcData(data, feats = apts, response = response)
  disease_idx <- data_prep$which_disease
  ks_data     <- apply(data_prep$data, 2, column_ks, which = disease_idx, ...) |>
    t() |> data.frame()

  # fix edge case of tied p-values of ks.dist can separate features
  if ( anyDuplicated(ks_data$p.value) != 0 ) {
    ks_data <- ks_data[ order(ks_data$ks.dist, decreasing = TRUE), ]
  }

  ret.list             <- list()
  ret.list$stat.table  <- calc_stat_table(ks_data, bh = bh)
  ret.list$call        <- match.call(expand.dots = TRUE)
  ret.list$test        <- "Kolmogorov-Smirnov Test"
  ret.list$response    <- response
  ret.list$counts      <- c(table(data[[response]]))
  ret.list$rm.outliers <- list(...)$rm.outliers %||% FALSE
  ret.list$data.frame  <- deparse(ret.list$call[[2L]])
  ret.list$data.dim    <- dim(data)
  if ( withr::with_preserve_seed(runif(1) < 0.25) ) gPraise()
  ret.list |>
    addClass(c("stat_table", "ks_table"))
}


#' @describeIn calc.ks
#' S3 print method for `ks_table` objects.
#' @param x An object of class `ks_table`.
#' @examples
#' # S3 print method
#' ks_table
#'
#' # no outliers
#' ks2
#'
#' @export
print.ks_table <- function(x, n = 6, ...) {
  cat("\n")
  writeLines(signal_rule("Stat Table", line_col = "blue"))
  print(utils::head(x$stat.table, n))
  invisible(x)
}


#' @describeIn calc.ks
#' The S3 `writeStatTable` method for class `ks_table`.
#' @examples
#' # S3 writeStatTable method
#' apt_data <- getAnalyteInfo(sim_test_data)
#' ks_table$stat.table <- addTargetInfo(ks_table$stat.table, apt_data)
#' f_out <- tempfile("ks-table-", fileext = ".csv")
#' writeStatTable(ks_table, file = f_out)
#' @importFrom stats setNames
#' @export
writeStatTable.ks_table <- function(x, file) {
  withr::local_output_sink(file, append = TRUE)
  cat("\n")
  out <- rn2col(renameStatTable(x$stat.table), "AptName")
  if ( all(c("nGrp1", "nGrp2") %in% names(out)) ) {
    key <- setNames(
      c("nGrp1", "nGrp1"),
      sprintf("N_samples_%s", names(x$counts)[1L])
    )
    out <- dplyr::rename(out, !!!key)
  }
  format(out, digits = 7L) |>
    write_uni_table(file = file)
  invisible(file)
}
