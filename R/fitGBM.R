#' Fit a Generalized Boosted Regression Model
#'
#' A wrapper for fitting boosted binary regression models
#' for binary classification problems. Assumes a binary
#' "Response" column is contained in the data frame.
#'
#' @family fit
#' @param x A `data.frame` containing feature data (predictors). If
#'   using the `formula` method, a "Response" column should be included. The
#'   simplest way to achieve this is a call to [createTrainingData()].
#' @param y Factor. If not passing a formula, a factor with
#'   true class names for each sample.
#' @param ... Arguments passed to [gbm()].
#' @return An object of class `gbm`, as returned by [gbm()].
#' @author Stu Field
#' @seealso [gbm()], [createTrainingData()]
#' @examples
#' # default method
#' # Use fake training data from iris data set
#' model1 <- withr::with_seed(10, fitGBM(fake_iris[, -5], y = fake_iris$Response))
#'
#' # formula method
#' model2 <- withr::with_seed(10, fitGBM(Response ~ ., data = fake_iris))
#' @export
fitGBM <- function(x, ...) UseMethod("fitGBM")

#' @describeIn fitGBM The S3 default method for `fitGBM`.
#' @importFrom stats setNames
#' @importFrom gbm gbm
#' @export
fitGBM.default <- function(x, y, ...) {
  if ( !is.factor(y) ) {
    y <- factor(y)
  }
  x$Response <- as.numeric(y) - 1
  fit <- gbm(Response ~ ., data = x, verbose = getOption("verbose"), ...)
  fit$class <- setNames(y, rownames(x))
  fit
}

#' @describeIn fitGBM The S3 formula method for `fitGBM`.
#' @param formula A model formula of the form: \eqn{class ~ x1 + x2 + ...+ xn`}
#' (no interactions).
#' @param data A data frame of predictors (categorical and/or numeric).
#' @export
fitGBM.formula <- function(formula, data, ...) {
  if ( inherits(data, "data.frame") ) {
    m      <- match.call(expand.dots = FALSE)
    m$...  <- NULL
    m[[1L]] <- as.name("model.frame")
    m       <- eval(m, parent.frame())
    Terms   <- attributes(attr(m, "terms"))
    if ( any(Terms$order > 1) ) {
      stop(
        "The `fitGBM()` function cannot currently handle interaction terms.",
        call. = FALSE
      )
    }
    X <- dplyr::select(m, -Terms$response)
    y <- stats::model.extract(m, "response")
    fitGBM(x = X, y = y, ...)
  } else {
    stop(
      "Generalized boosted regresion model formula ",
      "interface handles data frames only.\n",
      "Please ensure the `data =` argument inherts from class `data.frame`.",
      call. = FALSE
    )
  }
}
