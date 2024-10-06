#' Calculate Logistic Regression Table
#'
#' Generate a table of logistic regression models
#' representing the relationship between a two-class
#' response variable, and each of the `predictors` in the data (columns).
#'
#' @family calc
#' @inheritParams calc.lm
#' @inherit calc.lm return
#' @param response Character. String identifying the categorical response variable.
#' @author Stu Field
#' @seealso [fitGLM()], [glm()]
#' @examples
#' # convert to training data object for fitGLM downstream & log-transform
#' tr <- create_train(log10(sim_test_data), group.var = gender)
#' glm_table <- calc.glm(tr)
#'
#' @importFrom stats coefficients setNames
#' @export
calc.glm <- function(data, response = NULL, apts = NULL, bh = TRUE) {

  if ( is.null(response) && is.tr_data(data) ) {
    response <- .get_response(data)
  }

  if ( !is.factor(data[[response]]) ) {
    data[[response]] <- factor(data[[response]])
  }

  if ( (L <- length(levels(data[[response]]))) != 2L ) {
    stop(
      "The ", value(response), " variable must have exactly 2 levels. ",
      "It currently has ", value(L), " levels.", call. = FALSE
    )
  }

  if ( is.null(apts) ) {
    apts <- getAnalytes(data)
  }

  calc_msg("logistic regression", apts, response)

  models <- lapply(setNames(apts, apts), function(.apt) {
              fitGLM(createFormula(response, .apt), data = data)
  })

  glm_df <- liter(models, .f = function(.x, .y) {
              co <- coefficients(.x)
              data.frame(intercept  = co["(Intercept)"],
                         slope      = co[.y],
                         odds_ratio = exp(co[.y]),
                         p.value    = .get_glmPvalue(.x))
    })
  glm_df <- do.call(rbind, glm_df)

  ret.list            <- list()
  ret.list$stat.table <- calc_stat_table(glm_df, bh = bh)
  ret.list$models     <- lapply(models, stripLMC)
  ret.list$test       <- "Logistic Regression"
  ret.list$call       <- match.call(expand.dots = TRUE)
  ret.list$data.dim   <- dim(data)
  ret.list$y.response <- response
  ret.list$counts     <- c(table(data[[response]]))
  ret.list$data.frame <- deparse(ret.list$call[[2L]])
  ret.list$log        <- is.logspace(data)
  if ( withr::with_preserve_seed(runif(1) < 0.25) ) gPraise()
  ret.list |>
    addClass(c("stat_table", "glm_table"))
}


#' @describeIn calc.glm
#' S3 print method for `glm_table` objects.
#' @param x An object of class `glm_table` created via call [calc.glm()].
#' @param ... Arguments required by the S3 generics.
#' @examples
#' # S3 print method
#' glm_table                 # top 6
#'
#' # extend the default no. of rows
#' print(glm_table, n = 10)  # top 10
#'
#' @export
print.glm_table <- function(x, n = 6, ...) {
  key <- pad(c("Number of glm models", "Number of samples", "Class Variable"), 25)
  value <- c(length(x$models), x$data.dim[1L], x$y.response)
  writeLines(paste(" ", key, value))
  cat("\n")
  writeLines(signal_rule("Stat Table", line_col = "blue"))
  print(utils::head(x$stat.table, n))
  invisible(x)
}


#' @describeIn calc.glm
#' The S3 `writeStatTable` method for class `glm_table`.
#' @examples
#' # S3 writeStatTable method
#' apt_data <- getAnalyteInfo(tr)
#' glm_table$stat.table <- addTargetInfo(glm_table$stat.table, apt_data)
#' f_out <- tempfile("glm-table-", fileext = ".csv")
#' writeStatTable(glm_table, file = f_out)
#'
#' @export
writeStatTable.glm_table <- function(x, file) {
  withr::local_output_sink(file, append = TRUE)
  cat("Response Variable,", x$y.response, "\n\n", sep = "")
  renameStatTable(x$stat.table) |> rn2col("AptName") |>
    format(digits = 7L) |>
    write_uni_table(file = file)
  invisible(file)
}


#' @describeIn calc.glm
#' S3 plotting method for objects of class `glm_table`.
#' @param .data The data frame containing data to be plotted.
#'   In many cases this may now be included in the `"glm.table"` object itself.
#' @param n_plots Numeric. Numeric indices corresponding to the `glm_table`
#'   object, "stat.table" data frame rows. For example, `1:6` will plot the top
#'   6 analytes from the table.
#' @param pt.size Numeric. Size for the points.
#' @param pt.pch Shape of points. [par()].
#' @examples
#' # S3 plot method
#' plot(glm_table, .data = tr, n_plots = c(2, 4, 6))
#' @importFrom ggplot2 ggplot aes geom_point geom_line geom_hline
#' @importFrom ggplot2 coord_cartesian facet_wrap labs
#' @importFrom tidyr gather nest unnest
#' @importFrom purrr pmap
#' @export
plot.glm_table <- function(x, .data, n_plots = seq(6), pt.size = 2, pt.pch = 19,
                           fit.col = SomaPlotr::soma_colors$magenta, ...) {

  if ( missing(.data) ) {
    stop(
      "Please provide the data frame used to ",
      "calculate the `glm.table` object: ", x$data.frame,
      call. = FALSE
    )
  }
  if ( is_intact_attr(.data) ) {
    tg <- unlist(getTargetNames(getAnalyteInfo(.data)))
  } else {
    stop("Data attributes broken ... cannot make plot titles.", call. = FALSE)
  }

  top_apts <- rownames(x$stat.table)[n_plots]
  stopifnot(all(top_apts %in% names(.data)))

  if ( length(top_apts) > 25L ) {
    stop("Are you sure you want > 25 plots?", call. = FALSE)
  }

  response <- as.name(x$y.response)

  plot_data <- dplyr::ungroup(.data) |>
    dplyr::select(top_apts, !!response) |>
    gather(key = "feature", value = "RFU", -!!response) |>
    nest(rfu_df = c(response, RFU))
  plot_data$target  <- tg[plot_data$feature]
  plot_data$model   <- lapply(plot_data$feature, function(.x) x$models[[.x]])
  plot_data$predict <- pmap(plot_data, function(model, rfu_df, feature, ...) {
                         predict(model, setNames(rfu_df[, "RFU"], feature),
                                 type = "response")})
  plot_data <- unnest(plot_data, c(predict, rfu_df))

  curve_df <- setNames(top_apts, top_apts) |>
    lapply(function(.x) {
      df   <- dplyr::filter(plot_data, feature == .x)
      rng  <- range(df$RFU)
      grid <- seq(rng[1L], rng[2L], length = 100)
      data.frame(
        x = grid,
        y = predict(x$models[[.x]], setNames(data.frame(grid), .x), type = "resp")
      ) |> setNames(c("RFU", x$y.response))
    }) |> dplyr::bind_rows(.id = "feature")
  curve_df$target <- tg[curve_df$feature]

  plot_data |>
    ggplot(aes(x = RFU, y = !!response, color = !!response)) +
    geom_point(size = pt.size, shape = pt.pch, alpha = 0.9) +
    SomaPlotr::scale_color_soma() +
    geom_point(aes(x = RFU, y = predict + 1), alpha = 0.5, size = 2.5,
               color = SomaPlotr::soma_colors$lightgrey) +
    geom_line(aes(x = RFU, y = !!response + 1), data = curve_df,
              color = fit.col, size = 0.75) +
    coord_cartesian(ylim = c(1.5, 1.5)) +
    geom_hline(yintercept = 1.5, linetype = "dashed",
               color = SomaPlotr::soma_colors$lightgrey) +
    facet_wrap(~ target, scales = "free_x") +
    labs(y = x$y.response)
}

#' Get P-value from "glm" object
#'
#' Internal function to pull p-values corresponding to the *B_1*
#'   coefficient `glm` class objects.
#' @param model An object of class "glm", typically a logistic regresssion model.
#' @keywords internal
#' @noRd
.get_glmPvalue <- function(model) {
  stopifnot(inherits(model, "glm"))
  co <- summary(model)$coefficients |> data.matrix()
  stopifnot(!is.null(dim(co)))   # catch for vector
  pcol  <- ncol(co)
  slope <- grep("Intercept", rownames(co), invert = TRUE)
  co[slope, pcol]
}
