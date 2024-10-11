#' Calculate Correlation Table
#'
#' Generate a correlation table, representing the relationship between a
#' continuous dependent variable, and each of the aptamers in the menu
#' in the ADAT (columns).
#'
#' @family calc
#' @inheritParams params
#' @inheritParams calc.t
#' @param response Character. String identifying the continuous response variable.
#' @param method Matched String. The correlation method to use.
#'   Matched to one of:
#'     \itemize{
#'       \item \verb{"spearman"}
#'       \item \verb{"pearson"}
#'       \item \verb{"kendall"}
#'     }
#' @param ... Additional arguments passed to [cor.test()].
#' @inherit params return
#' @note The dependent variable (`response`) is _not_ log-transformed prior
#'   to analysis. If this is desired, the user is directed to do so in
#'   the data object itself prior to the call.
#' @author Stu Field
#' @seealso [cor.test()]
#' @examples
#' cor_table <- list()
#'
#' # Spearman
#' cor_table$spearman <- withr::with_options(
#'   c(warn = -1),
#'   calc.cor(sim_test_data, response = "reg_response")
#' )
#'
#' # Pearson
#' cor_table$pearson  <- calc.cor(log10(sim_test_data),
#'                                response = "reg_response", method = "pearson")
#'
#' @importFrom stats cor.test cov
#' @export
calc.cor <- function(data, apts = NULL, response, bh = TRUE,
                     method = c("spearman", "pearson", "kendall"), ...) {

  method <- match.arg(method)

  if ( !is.logspace(data) && method == "pearson" ) {
    logWarning(method)
  }

  if ( is.null(apts) ) {
    apts <- getAnalytes(data)
  }

  calc_msg("correlation", apts, response)

  rho2t <- function(m) {   # internal to calculate t-stat for rho
    rho <- unname(m$estimate)
    rho * sqrt( (length(data[[response]]) - 2) / (1 - rho^2) )
  }

  resp_vec <- data[[response]]
  cor_df <- lapply(setNames(apts, apts), function(.x) {
               model <- stats::cor.test(resp_vec, data[[.x]], method = method, ...)
               if ( method == "pearson" ) {
                 data.frame(r       = model$estimate,
                            t.stat  = model$statistic,
                            loCI95  = model$conf.int[1L],
                            upCI95  = model$conf.int[2L],
                            p.value = model$p.value)
               } else if ( method == "spearman" ) {
                 data.frame(rho    = model$estimate, S = model$statistic,
                            t.stat = rho2t(model), p.value = model$p.value,
                            cov    = stats::cov(resp_vec, data[[.x]],
                                                method = "spearman",
                                                use    = "complete.obs"))
               } else {
                 data.frame(tau     = model$estimate,
                            T       = model$statistic,
                            p.value = model$p.value)
               }
    })
  cor_df <- do.call(rbind, cor_df)

  ret.list            <- list()
  ret.list$stat.table <- calc_stat_table(cor_df, bh = bh)
  ret.list$call       <- match.call()
  ret.list$test       <- stats::cor.test(1:10, 10:1, method = method)$method
  ret.list$data.dim   <- dim(data)
  ret.list$response   <- response
  ret.list$data.frame <- deparse(ret.list$call[[2L]])
  ret.list$log        <- is.logspace(data)
  if ( withr::with_preserve_seed(runif(1) < 0.25) ) gPraise()
  ret.list |>
    add_class(c("stat_table", "cor_table"))
}


#' @describeIn calc.cor
#'   S3 print method for Spearman, Pearson, and Kendall correlation
#'   tables, all `cor_table` objects.
#' @param x An object of class `cor_table`.
#' @examples
#' # S3 print method
#' cor_table   # both spearman and pearson
#'
#' @export
print.cor_table <- function(x, n = 6L, ...) {
  key <- pad(c("Number of samples", "Independent Variable"), 25)
  writeLines(paste(" ", key, c(x$data.dim[1L], x$response)))
  cat("\n")
  writeLines(signal_rule("Stat Table", line_col = "blue"))
  print(utils::head(x$stat.table, n))
  invisible(x)
}


#' @describeIn calc.cor
#'   The S3 `write_stat_tbl` method for class `cor_table`.
#' @export
write_stat_tbl.cor_table <- function(x, file) {
  withr::local_output_sink(file, append = TRUE)
  cat("Independent Variable,", x$response, "\n")
  cat("\n")
  rename_stat_tbl(x$stat.table) |> rn2col("AptName") |>
    format(digits = 7L) |>
    write_uni_table(file = file)
  invisible(file)
}
