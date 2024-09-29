#' Fit Multivariate Logistic Regression Model
#'
#' A wrapper around [glm()] for fitting multivariate
#' logistic regression models for binary classification problems.
#'
#' @family fit
#' @param formula,x,... Either a formula, data frame, or matrix.
#'   If a `formula` (preferred) should be a model of the
#'   form: \eqn{class ~ x_1 + x_2 + ... + x_n}.
#'   If a data frame (preferably a "tr_data" object), containing features
#'   or predictors. If a column named "Response" is present, it is assumed to be
#'   the column of `true` classes and is re-coded to be `y` (and `y = NULL`
#'   is allowed). Alternatively, a matrix object containing ONLY predictors,
#'   in which case `y` _must_ be passed (see examples below). Unmatched
#'   arguments eventually make their way to [glm()].
#' @param y Can be one of _three_ options:
#'   \describe{
#'     \item{NULL}{Assumes a column named "Response" is in `x`
#'                 which contains true class names.}
#'     \item{factor}{A vector indicating the true class names for each
#'                   sample. That is, a factor class object with _2_ levels.}
#'     \item{character}{A string indicating the column in `x` containing
#'                      the true class names.}
#'   }
#' @param strip Logical. Should certain entries of the model object
#'   be stripped via [stripLMC()] to reduce object size?
#'   If true, some downstream functionality is compromised, e.g. [summary()] and
#'   [residuals()], however when iterating over 1000s of models this may be
#'   an acceptable trade-off to limit runaway memory consumption.
#' @return A `glm` model object as returned by [glm()], logistic regression model.
#' @author Stu Field
#' @seealso [glm()]
#' @examples
#' # formula S3 method
#' # This is the preferred syntax
#' model <- fitGLM(Response ~ ., data = fake_iris)
#'
#' # data frame S3 method: 1
#' model <- fitGLM(fake_iris)   # assume "Response" is present
#'
#' # data frame S3 method: 2
#' model <- fitGLM(fake_iris[, -5], y = fake_iris$Response)  # pass vector of class names
#'
#' # data frame S3 method: 3
#' model <- fitGLM(fake_iris, y = "Response")  # pass string containing class names
#'
#' # matrix S3 method (*must* pass `y` here)
#' model <- fitGLM(as.matrix(fake_iris[, -5]), y = fake_iris$Response)
#' @importFrom stats glm model.response model.frame as.formula
#' @export
fitGLM <- function(x, ..., strip) UseMethod("fitGLM")


#' @describeIn fitGLM
#' S3 formula method for `fitGLM`.
#' @export
fitGLM.formula <- function(formula, ..., strip = FALSE) {
  fit <- glm(formula, ..., family = "binomial", model = !strip)
  mf  <- stats::model.frame(formula, ...)
  names(fit$y) <- rownames(mf)
  fit$classes  <- levels(stats::model.response(mf))
  if ( strip ) {
    fit <- stripLMC(fit)
  }
  fit
}


#' @describeIn fitGLM
#' S3 data frame method for `fitGLM`.
#' @importFrom stats as.formula
#' @export
fitGLM.data.frame <- function(x, y = NULL, strip = FALSE, ...) {
  if ( is.null(y) ) {
    formula <- as.formula("Response ~ .")
  } else if ( length(y) == 1L && y %in% names(x) ) {
    formula <- as.formula(paste(y, "~ ."))
  } else if ( length(y) == nrow(x) ) {
    if ( !is.factor(y) ) {
      y <- factor(y)
    }
    x$Response <- y
    formula    <- as.formula("Response ~ .")
  } else {
    stop(
      "Unable to determine response variable. Please check value of `y`.",
      call. = FALSE
    )
  }
  fitGLM(formula, data = x)
}


#' @describeIn fitGLM
#' S3 matrix method for `fitGLM`.
#' @export
fitGLM.matrix <- function(x, y, strip = FALSE, ...) {
  x <- as.data.frame(x)
  if ( missing(y) ) {
    stop(
      "Must pass a `y` vector of true classes if using S3 matrix method.",
      call. = FALSE
    )
  }
  fitGLM(x = x, y = y)
}
