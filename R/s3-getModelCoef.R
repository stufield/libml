#' Get Coefficients of a Model
#'
#' Extract the coefficients for an arbitrary model.
#'
#' @name getModelCoef-libml
#' @param model A model object, currently one of:
#' ```{r methods, echo = FALSE}
#' options(width = 50)
#' withr::with_collate("en_US.UTF-8", methods("getModelCoef"))
#' ```
#' @param lambda The value of the penalty parameter `lambda` which
#'   can either be `NULL` or `numeric`.
#'   If `NULL`, the default value depends on the underlying class:
#'   \describe{
#'     \item{`glmnet`}{The first value of lambda.}
#'     \item{`cv.glmnet`}{The lambda where the cross validated error is minimized.}
#'     \item{`train`}{The optimal value of lambda. When given a numeric value
#'       of `lambda`, the closest value of `lambda` within the model will be used.}
#'   }
#' @param ... Additional parameters for extensibility.
#' @return A named numeric vector of the coefficients of the model.
#'   If the model is non-linear (e.g. random forest), `NULL`.
#' @seealso [coef()]
#' @examples
#' # set up training and test data:
#' iris2 <- droplevels(iris[iris$Species != "setosa", ])
#'
#' # Logistic Regression
#' stats::glm(Species ~ ., data = iris2, family = "binomial") |>
#'   getModelCoef()
NULL


#' @export
globalr::getModelCoef


#' @describeIn getModelCoef-libml
#'   S3 method for `glm` models.
#' @importFrom stats coefficients
#' @export
getModelCoef.glm <- function(model, ...) {
  stats::coefficients(model, ...)
}

#' @describeIn getModelCoef-libml
#'   S3 method for `lm` models.
#' @export
getModelCoef.lm <- getModelCoef.glm

#' @describeIn getModelCoef-libml
#'   S3 method for `lda` models.
#' @export
getModelCoef.lda <- getModelCoef.glm

#' @describeIn getModelCoef-libml
#'   S3 method for `libml_nb` models.
#' @export
getModelCoef.libml_nb <- getModelCoef.glm

#' @describeIn getModelCoef-libml
#'  S3 method for `naiveBayes` models.
#' @export
getModelCoef.naiveBayes <- getModelCoef.glm

#' @describeIn getModelCoef-libml
#'   S3 method for `kknn` models.
#' @export
getModelCoef.kknn <- getModelCoef.glm

#' @describeIn getModelCoef-libml
#'   S3 method for `randomForest` models.
#' @export
getModelCoef.randomForest <- getModelCoef.glm

#' @describeIn getModelCoef-libml
#'   S3 method for `gbm` models.
#' @export
getModelCoef.gbm <- getModelCoef.glm

#' @describeIn getModelCoef-libml
#'   S3 method for `glmnet` models.
#' @export
getModelCoef.glmnet <- function(model, lambda = NULL, ...) {
  lambda        <- lambda %||% model$lambda[1L]
  lambda_idx    <- which.min(abs(model$lambda - lambda))
  tmp_coefs     <- model$beta[, lambda_idx]
  tmp_intercept <- c(`(Intercept)` = model$a0[[lambda_idx]])
  c(tmp_intercept, tmp_coefs)
}

#' @describeIn getModelCoef-libml
#'   S3 method for `cv.glmnet` models.
#' @export
getModelCoef.cv.glmnet <- function(model, lambda = NULL, ...) {
  lambda        <- lambda %||% model$lambda.min
  lambda_idx    <- which.min(abs(model$lambda - lambda))
  tmp_coefs     <- model$glmnet.fit$beta[, lambda_idx]
  tmp_intercept <- c(`(Intercept)` = model$glmnet.fit$a0[[lambda_idx]])
  c(tmp_intercept, tmp_coefs)
}

#' @describeIn getModelCoef-libml
#'   S3 method for `train` models.
#' @export
getModelCoef.train <- function(model, lambda = NULL, ...) {
  actual_model <- model$finalModel
  if ( model$method == "glmnet" ) {
    lambda <- lambda %||% model$finalModel$lambdaOpt
    getModelCoef.glmnet(actual_model, lambda = lambda, ...)
  } else {
    getModelCoef.glm(actual_model, ...)
  }
}

#' @describeIn getModelCoef-libml
#'   S3 method for SVM models. If the model `kernel = linear`,
#'   coefficients are returned. Otherwise, `NULL`.
#' @export
getModelCoef.svm <- function(model, ...) {
  if ( model$kernel == 0 ) {
    stats::coefficients(model)
  } else {
    NULL
  }
}
