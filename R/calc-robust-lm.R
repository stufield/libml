#' Calculate Robust Linear Models Table
#'
#' @family calc
#' @inherit calc.lm
#' @details Robust regression utilizes [rlm()], where
#'   "fitting is done by iterated re-weighted least-squares".
#' @author Stu Field, Leigh Alexander
#' @seealso [lm()]
#' @examples
#' rlm_table <- calc.robust.lm(log10(sim_test_data), response = "HybControlNormScale")
#'
#' @importFrom lifecycle is_present deprecated deprecate_stop
#' @export
calc.robust.lm <- function(data, apts = NULL, response, bh = TRUE,
                           do.log = deprecated()) {

  if ( is_present(do.log) ) {
    deprecate_stop("0.0.1", "fittr::calc.robust.lm(do.log = )",
                   details = "Please log-transform upstream prior to call.")
  }

  if ( !is.logspace(data) ) {
    logWarning("robust lm")
  }

  if ( is.null(apts) ) {
    apts <- getAnalytes(data)
  }

  calc_msg("'robust' linear regression", apts, response)

  models <- lapply(setNames(apts, apts), function(.apt) {
              MASS::rlm(createFormula(response, .apt), data = data)
  })

  stats <- liter(models, .f = function(.x, .y) {
       data.frame(intercept = .x$coefficients["(Intercept)"],
                  slope     = .x$coefficients[.y],
                  t.slope   = summary(.x)$coefficients[.y, "t value"],
                  p.value   = .get_rlmPvalue(.x))
    })
  stats <- do.call(rbind, stats)

  ret.list             <- list()
  ret.list$stat.table  <- calcStatTable(stats, bh = bh)
  ret.list$models      <- models
  ret.list$test        <- "Robust Linear Regression"
  ret.list$call        <- match.call(expand.dots = TRUE)
  ret.list$data.dim    <- dim(data)
  ret.list$y.response  <- response
  ret.list$log         <- is.logspace(data)
  ret.list$data.frame  <- deparse(ret.list$call[[2L]])
  if ( withr::with_preserve_seed(runif(1) < 0.25) ) gPraise()
  ret.list |>
    addClass(c("stat_table", "rlm_table"))
}


#' @describeIn calc.robust.lm
#' S3 print method for `rlm_table` objects.
#' @param x An object of class `rlm_table` created via call to [calc.robust.lm()].
#' @inheritParams calc.lm
#' @examples
#' # S3 print method
#' rlm_table                 # top 6
#' print(rlm_table, n = 20)  # top 20
#'
#' @export
print.rlm_table <- function(x, n = 6, ...) {
  key <- c("Number of rlm models", "Number of samples", "Response Variable") |>
    pad(25)
  value <- c(length(x$models), x$data.dim[1L], x$y.response)
  writeLines(paste(" ", key, value))
  cat("\n")
  writeLines(signal_rule("Stat Table", line_col = "blue"))
  print(utils::head(x$stat.table, n))
  invisible(x)
}


#' @describeIn calc.robust.lm
#' The S3 `writeStatTable` method for class `rlm_table`.
#' @inheritParams calc.lm
#' @examples
#' # S3 writeStatTable method
#' apt_data <- getAnalyteInfo(sim_test_data)
#' rlm_table$stat.table <- addTargetInfo(rlm_table$stat.table, apt_data)
#' f_out <- tempfile("rlm-table-", fileext = ".csv")
#' writeStatTable(rlm_table, file = f_out)
#' @export
writeStatTable.rlm_table <- writeStatTable.lm_table


#' Calculate P-value of the slope from "rlm" object
#'
#' Internal function to pull p-values from "rlm" class objects.
#' @param model An object of class "rlm", a robust linear regresssion model.
#' @keywords internal
#' @importFrom stats pt
#' @noRd
.get_rlmPvalue <- function(model) {
  stopifnot(inherits(model, "rlm"))
  coefs <- summary(model)$coefficients |> data.frame()
  stopifnot(!is.null(dim(coefs)))   # catch for vector
  slope <- grep("Intercept", rownames(coefs), invert = TRUE)
  p <- 2 * stats::pt(abs(coefs$t.value), summary(model)$df[2L], lower.tail = FALSE)
  p[slope]
}
