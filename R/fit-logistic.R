#' Fit Multivariate Logistic Regression Model
#'
#' A wrapper around [glm()] for fitting multivariate
#' logistic regression models for binary classification problems.
#'
#' @family fit
#' @param formula,x,... Either a formula, data frame, or matrix.
#'   If a `formula` (preferred) should be a model of the
#'   form: \eqn{class ~ x_1 + x_2 + ... + x_n}.
#'   If a data frame (preferably a `tr_data` object), containing features
#'   or predictors. If a matrix object containing ONLY predictors,
#'   in which case `y` _must_ be passed (see examples below). Unmatched
#'   arguments eventually be passed to [glm()] via the `...`.
#' @param y Can be one of _two_ options:
#'   \describe{
#'     \item{character}{A `character(1)` indicating the column in `x`
#'       containing the true class names.}
#'     \item{vector}{A vector (`nrow(x)`) containign the true class names
#'       for each sample. That is a vector with _2_ levels. If not
#'       a factor class, it will be converted to one via [as.factor()].}
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
#' class(tr_iris)
#'
#' df <- tibble::as_tibble(tr_iris)  # strip tr_data class
#'
#' # tr_data S3 method:
#' model <- fit_logistic(tr_iris)
#'
#' # data frame S3 method:
#' model <- fit_logistic(df, "Species")
#'
#' # formula S3 method:
#' model <- fit_logistic(Species ~ ., data = df)
#'
#' # data frame S3 method (2):
#' model <- fit_logistic(df[, -5L], y = df$Species)  # vector of class names
#'
#' # matrix S3 method:
#' model <- fit_logistic(as.matrix(df[, -5L]), y = df$Species)  # 'glmnet' syntax
#' @export
fit_logistic <- function(x, ..., strip) UseMethod("fit_logistic")


#' @describeIn fit_logistic
#'   S3 formula method for `fit`.
#' @importFrom stats glm model.response model.frame as.formula
#' @export
fit_logistic.formula <- function(formula, ..., strip = FALSE) {
  fit <- glm(formula, ..., family = "binomial", model = !strip)
  mfr <- model.frame(formula, ...)
  names(fit$y) <- rownames(mfr)
  fit$classes  <- levels(model.response(mfr))
  if ( strip ) {
    fit <- stripLMC(fit)
  }
  fit
}

#' @describeIn fit_logistic
#'   S3 `data.frame` method for `fit_logistic`.
#' @importFrom stats as.formula
#' @export
fit_logistic.data.frame <- function(x, y = NULL, strip = FALSE, ...) {
  if ( is.null(y) ) {
    stop("Must pass `y` response if `x` is a data.frame.", call. = FALSE)
  } else if ( is_chr(y) && y %in% names(x) ) {
    formula <- as.formula(paste(y, "~ ."))
  } else if ( length(y) == nrow(x) ) {  # glmnet syntax
    if ( !is.factor(y) ) {
      y <- as.factor(y)
    }
    x$y <- y
    formula    <- as.formula("y ~ .")
  } else {
    stop(
      "Unable to determine response variable. Please check value of `y`.",
      call. = FALSE
    )
  }
  fit_logistic(formula, data = x)
}

#' @describeIn fit_logistic
#'   S3 `tr_data` method for `fit_logistic`.
#' @importFrom stats as.formula
#' @export
fit_logistic.tr_data <- function(x, ..., strip = FALSE) {
  response <- .get_response(x)
  formula  <- as.formula(paste(response, "~ ."))
  fit_logistic(formula, data = x, strip = strip)
}

#' @describeIn fit_logistic
#'   S3 matrix method for `fit_logistic`.
#' @export
fit_logistic.matrix <- function(x, y, strip = FALSE, ...) {
  x <- as.data.frame(x)
  if ( missing(y) ) {
    stop(
      "Must pass a `y` vector of true classes if using S3 matrix method.",
      call. = FALSE
    )
  }
  fit_logistic(x = x, y = y)
}
