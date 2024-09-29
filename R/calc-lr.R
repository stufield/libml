#' Calculate log-ratio Table
#'
#' Create a statistical table of the log fold changes for a data set
#' given the response column with 2 factor levels.
#'
#' @family calc
#' @inheritParams params
#' @inheritParams calc.t
#' @param do.mean Logical. Should the mean be used (rather than median) for
#'   calculating log-ratios?
#' @param ... Additional arguments passed to the internal `column_lr`,
#'   typically `rm.outliers = TRUE` if desired.
#' @return An object of class `c(stat_table, logratio_table)` sorted by the
#'   log-fold changes for the response variable.
#' @author Stu Field
#' @examples
#' lr1 <- calc.lr(sim_test_data, response = "class_response")
#'
#' # remove outliers
#' lr2 <- calc.lr(sim_test_data, response = "class_response", rm.outliers = TRUE)
#'
#' @export
calc.lr <- function(data, apts = NULL, response = "Response",
                    paired = FALSE, do.mean = FALSE, ...) {

  data_prep <- prepCalcData(data, feats = apts, response = response)
  lr_data   <- apply(data_prep$data, 2, column_lr,
                     which = data_prep$which_disease, paired = paired,
                     do.mean = do.mean, ...) |> t() |> data.frame()
  lr_data$.rn  <- rownames(lr_data)
  lr_data      <- dplyr::arrange(lr_data, dplyr::desc(log2.fold.change))
  lr_data$rank <- seq_len(nrow(lr_data))
  rownames(lr_data) <- lr_data$.rn
  lr_data$.rn  <- NULL

  ret.list             <- list()
  ret.list$stat.table  <- lr_data
  ret.list$call        <- match.call(expand.dots = TRUE)
  ret.list$test        <- "Log Ratios"
  ret.list$response    <- response
  ret.list$counts      <- c(table(data[[response]]))
  ret.list$rm.outliers <- list(...)$rm.outliers %||% FALSE
  ret.list$log         <- FALSE           # never do ratios in log-sapce
  ret.list$paired      <- paired
  ret.list$do.mean     <- do.mean
  ret.list$data.frame  <- deparse(ret.list$call[[2L]])
  ret.list$data.dim    <- dim(data)
  ret.list |>
    addClass(c("stat_table", "logratio_table"))
}


#' @describeIn calc.lr
#' S3 print method for `logratio_table` objects.
#' @param x An object of class `logratio_table`.
#' @examples
#' # S3 print method
#' lr1
#' lr2
#'
#' @export
print.logratio_table <- function(x, n = 6, ...) {
  key <- pad("Ratios of ->", 25)
  writeLines(paste(" ", key, ifelse(x$do.mean, "Means", "Medians")))
  cat("\n")
  writeLines(signal_rule("Stat Table", line_col = "blue"))
  print(utils::head(x$stat.table, n))
  invisible(x)
}


#' @describeIn calc.lr
#' The S3 `writeStatTable` method for class `logratio_table`.
#' @examples
#' # S3 writeStatTable method
#' apt_data <- getAnalyteInfo(sim_test_data)
#' lr1$stat.table <- addTargetInfo(lr1$stat.table, apt_data)
#' f_out <- tempfile("logRatio-table-", fileext = ".csv")
#' writeStatTable(lr1, file = f_out)
#' @export
writeStatTable.logratio_table <- writeStatTable.ks_table
