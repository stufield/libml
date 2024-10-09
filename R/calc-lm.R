#' Calculate Linear Models Table
#'
#' Generate a table of linear regression models of the classic form:
#' \deqn{Y_i ~ \beta_0 + \beta_1 * X_i + \epsilon_i}
#' where in this context,
#' \deqn{Y = response}
#' \deqn{X = predictor}
#' This model represents the relationship between a continuous dependent
#' variable (`response`), and each of the analyte features (`predictor`) in
#' the ADAT. The "response" in this case is typically some clinical or assay
#' variable that can be predicted by an analyte RFU
#' via \eqn{\beta_0} and \eqn{\beta_1}.
#'
#' @family calc
#' @inheritParams calc.t
#' @param response Character. String identifying the _continuous_, dependent
#'   response variable. The `response` is _not_ log-transformed prior
#'   to analysis. If this is desired, the user is directed to do so in
#'   the data object itself prior to the call.
#' @return A list object of class `c(stat_table, *_table)` containing:
#'   \item{stat.table}{A data frame (table) of the statistical results (see below).}
#'   \item{models}{The stripped down (for size) model objects for each analyte.}
#'   \item{call}{The direct call made to `calc.*()`.}
#'   \item{test}{The name of the statistical test; linear regression.}
#'   \item{y.response}{The column name of the dependent/response variable.}
#'   \item{data.frame}{The name of the data frame containing the RFU data.}
#'   \item{data.dim}{The dimensions of the data matrix.}
#'   \item{log}{Whether the RFU values were log10-transformed prior to analysis.}
#'
#'   The `stat.table` contains:
#'     + __intercept__: the \eqn{\beta_0} intercept of the model.
#'     + __slope__: the \eqn{\beta_1} slope of the model.
#'     + __odds_ratio__: the odds ratio for classes ([calc.glm()] only).
#'     + __p.value__: Unadjusted p-values for the test statistic
#'       corresponding to \eqn{\beta_1}.
#'     + __fdr or q.value__: FDR adjusted p-value (Benjamini-Hochberg) or
#'       if q-value, Storey.
#'     + __p.bonferroni__: Bonferroni corrected p-value.
#'     + __rank__: Ranking by the test significance.
#' @author Stu Field
#' @seealso [lm()]
#' @examples
#' lm_table <- calc.lm(log10(sim_test_data), response = "HybControlNormScale")
#'
#' @importFrom stats lm
#' @export
calc.lm <- function(data, apts = NULL, response, bh = TRUE) {

  if ( is.null(apts) ) {
    apts <- getAnalytes(data)
  }

  calc_msg("linear regression", apts, response)

  if ( !is.logspace(data) ) {
    logWarning("linear regression")
  }

  models <- lapply(setNames(apts, apts), function(.apt) {
              stats::lm(createFormula(response, .apt), data = data,
                        x = TRUE, y = TRUE)
  })

  lm_df <- liter(models, .f = function(.x, .y) {
      co <- .x$coefficients
      data.frame(intercept = unname(co["(Intercept)"]),
                 slope     = unname(co[.y]),
                 t.slope   = summary(.x)$coefficients[.y, "t value"],
                 p.value   = .get_lmPvalue(.x))
    })
  lm_df <- do.call(rbind, lm_df)

  ret.list <- list()
  ret.list$stat.table  <- calc_stat_table(lm_df, bh = bh)
  ret.list$models      <- lapply(models, stripLMC)
  ret.list$test        <- "Linear Regression"
  ret.list$call        <- match.call(expand.dots = TRUE)
  ret.list$data.dim    <- dim(data)
  ret.list$y.response  <- response
  ret.list$log         <- is.logspace(data)
  ret.list$data.frame  <- deparse(ret.list$call[[2L]])
  if ( withr::with_preserve_seed(runif(1) < 0.25) ) gPraise()
  ret.list |>
    add_class(c("stat_table", "lm_table"))
}


#' @describeIn calc.lm
#' S3 print method for `lm_table` objects.
#' @param x An object of class `lm_table` created via call to [calc.lm()].
#' @param ... Arguments required by the S3 generics.
#' @examples
#' # S3 print method
#' lm_table
#'
#' # extend the default no. of rows
#' print(lm_table, n = 10)
#'
#' @export
print.lm_table <- function(x, n = 6L, ...) {
  key <- pad(c("Number of lm models", "Number of samples",
               "Response Variable"), 25)
  value <- c(length(x$models), x$data.dim[1L], x$y.response)
  writeLines(paste(" ", key, value))
  cat("\n")
  writeLines(signal_rule("Stat Table", line_col = "blue"))
  print(utils::head(x$stat.table, n))
  invisible(x)
}


#' @describeIn calc.lm
#'   The S3 `write_stat_table` method for class `lm_table`.
#' @export
write_stat_table.lm_table <- function(x, file) {
  withr::local_output_sink(file, append = TRUE)
  cat("Response Variable,", x$y.response, "\n\n", sep = "")
  renameStatTable(x$stat.table) |> rn2col("AptName") |>
    format(digits = 7L) |>
    write_uni_table(file = file)
  invisible(file)
}


#' @describeIn calc.lm
#' S3 plotting method for objects of class `lm_table`.
#' @param .data The data frame (or `soma_adat`) containing data to be plotted.
#'   In many cases this may now be included in the `lm_table` object itself.
#' @param n_plots Numeric. Numeric indices corresponding
#'   to the `lm_table` object, "stat.table" data frame rows.
#'   For example, `1:6`, will plot the top 6 analytes from the table.
#' @param method Character. See [ggplot2::geom_smooth()].
#' @param fit.col Character or numeric. Color of the model fit line,
#'   as used by [ggplot2::ggplot()]
#' @param ci.col Character. Color of the interval line to be plotted,
#'   as used in [ggplot2::ggplot()].
#' @param ci Logical. Should standard error based confidence
#'   intervals be plotted? See [ggplot2::geom_smooth()].
#' @param y.lab Character. An optional string for the y-axis label.
#' @param pt.col Character. Color for the points.
#' @param pt.pch Integer. Shape for of points.
#' @param pt.size Numeric. Size for the points.
#' @examples
#' # S3 plot method
#' plot(lm_table, .data = sim_test_data)
#'
#' # Adjust the `method` argument to an `lm` fit as in the model
#' plot(lm_table, .data = sim_test_data, method = "lm")
#'
#' # There are many options to the defaults
#' plot(lm_table, .data = sim_test_data, n_plots = c(2, 5, 9), pt.col = "darkred",
#'      ci.col = "green", pt.size = 4, fit.col = "cyan", pt.pch = 13,
#'      y.lab = "Changed y-axis"
#' )
#' @importFrom ggplot2 ggplot geom_smooth aes
#' @importFrom ggplot2 geom_point facet_wrap labs
#' @importFrom tidyr gather
#' @export
plot.lm_table <- function(x, .data, n_plots = seq(6L),
                          method  = "loess", y.lab = "RFU",
                          fit.col = SomaPlotr::soma_colors$purple,
                          ci.col  = SomaPlotr::soma_colors$lightgrey,
                          ci = TRUE,  pt.pch = 19,
                          pt.col  = "black", pt.size = 2, ...) {

  if ( missing(.data) ) {
    stop(
      "Please provide the data frame used to ",
      "calculate the `lm_table` object: ", x$data.frame, ".",
      call. = FALSE
    )
  }

  if ( is_intact_attr(.data) ) {
    tg <- unlist(getTargetNames(getAnalyteInfo(.data)))
  } else {
    stop("Data attributes broken ... cannot make plot titles.", call. = FALSE)
  }

  top_apts <- rownames(x$stat.table)[ n_plots ]
  stopifnot(all(top_apts %in% names(.data)))

  response <- as.name(x$y.response)

  if ( length(top_apts) > 25L ) {
    stop("Are you sure you want > 25 plots?", call. = FALSE)
  }

  plot_data <- dplyr::select(.data, top_apts, !!response) |>
    gather(key = "feature", value = "RFU", -!!response)
  plot_data$feature <- tg[plot_data$feature]
  plot_data |>
    ggplot(aes(x = !!response, y = RFU)) +
    geom_point(colour = pt.col, shape = pt.pch, size = pt.size, alpha = 0.5) +
    geom_smooth(method = method, span = 4, colour = fit.col, alpha = 0.5,
                se = ci, fill = ci.col) +
    facet_wrap(~ feature, scales = "free_y") +
    labs(y = y.lab) +
    SomaPlotr::theme_soma()
}

#' Get P-value from "lm" object
#'
#' Internal function to pull p-values from "lm" class objects.
#' @param model An object of class "lm", typically a linear regresssion model.
#' @keywords internal
#' @noRd
.get_lmPvalue <- function(model) {
  stopifnot(inherits(model, "lm"))
  co <- summary(model)$coefficients |> data.matrix()
  stopifnot(!is.null(dim(co)))   # catch for vector
  pcol  <- ncol(co)
  slope <- grep("Intercept", rownames(co), invert = TRUE)
  co[slope, pcol]
}
