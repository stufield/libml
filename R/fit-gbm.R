#' Fit a Generalized Boosted Regression Model
#'
#' A wrapper for fitting boosted binary regression models
#'   for binary classification problems. Assumes a binary
#'   "Response" in \verb{[0, 1]}.
#'
#' @family fit
#'
#' @param x A `data.frame` containing feature data (predictors). If
#'   using the `formula` method, a "Response" column should be included. The
#'   simplest way to achieve this is a call to [create_train()].
#' @param y `factor(n)`. If not passing a formula, a factor with
#'   true class names for each sample (row) in `x`.
#' @param ... Arguments passed to [gbm()].
#'
#' @return A `gbm` class object, as returned by [gbm()].
#' @author Stu Field
#' @seealso [gbm()], [create_train()]
#'
#' @examples
#' # formula method
#' model <- withr::with_seed(10, fit_gbm(Species ~ ., data = tr_iris))
#'
#' # data frame method
#' model <- withr::with_seed(10, fit_gbm(tr_iris[, -5L], y = tr_iris$Species))
#' @export
fit_gbm <- function(x, ...) UseMethod("fit_gbm")


#' @describeIn fit_gbm
#'   The S3 default method for `fit_gbm`.
#'
#' @importFrom stats setNames
#' @importFrom gbm gbm
#' @export
fit_gbm.default <- function(x, y, ...) {
  if ( !is.factor(y) ) {
    y <- as.factor(y)
  }
  x$y <- as.numeric(y) - 1
  fit <- gbm(y ~ ., data = x, ...)
  fit$class <- setNames(y, rownames(x))
  fit
}

#' @describeIn fit_gbm
#'   The S3 formula method for `fit_gbm`.
#'
#' @param formula A model formula of the form:
#'   \eqn{class ~ x1 + x2 + ...+ xn`}, (no interactions).
#' @param data A data frame of predictors (categorical and/or numeric).
#'
#' @export
fit_gbm.formula <- function(formula, data, ...) {
  if ( !inherits(data, "data.frame") ) {
    stop(
      "Generalized boosted regresion model formula ",
      "method handles data frames only.\n",
      "Please ensure the `data =` argument inherts from `data.frame`.",
      call. = FALSE
    )
  }
  response <- as.character(formula[[2L]])
  y <- data[[response]]
  classes <- setNames(y, rownames(data))
  if ( !is.factor(y) ) {
    y <- as.factor(y)
  }
  y <- as.numeric(y) - 1
  data[[response]] <- y
  fit <- gbm(formula, data = data, ...)
  fit$call[[2L]] <- formula
  fit$class <- classes
  fit
}
