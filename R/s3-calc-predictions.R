#' Calculate Model Predictions
#'
#' Calculate the test set predictions of a given model and test set.
#' \itemize{
#'   \item For the `randomForest` model, if `newdata = NULL` (default),
#'     the out-of-bag sample predictions are returned, thus no test data
#'     are required.
#'   \item For KKNN models, the test set predictions are maintained
#'     with the model itself, thus you should _not_ pass `test`.
#'   \item For `randomForest` and `gbm` models, there are out-of-bag samples
#'     that are used for predictions if `newdata = NULL`.
#' }
#'
#' @name s3-calc_predictions
#'
#' @inheritParams helpr::calc_predictions
#' @inheritParams params
#'
#' @param model A model object. Currently one of:
#' \itemize{
#'   \item `glm` (for logistic regression)
#'   \item `libml_nb`
#'   \item `naiveBayes`
#'   \item `randomForest`
#'   \item `svm`
#'   \item `gbm`
#'   \item `kknn`
#' }
#'
#' @return A `data.frame` with predicted class and class probabilities for
#'   each row in `newdata`:
#'   \item{`pred_class`}{predicted class for each new observation.
#'                      If there are more than two classes, the class with
#'                      the _highest_ predicted probability. Otherwise, class
#'                      predictions are returned based on the value of `cutoff`.}
#'   \item{`prob_*`}{probability of belonging to class `*` for each new observation.}
#'   \item{`pred_linear`}{for linear models, the linear predictor for
#'                        each new observation.}
#'
#' @author Stu Field
#' @seealso [fit_nb()], [randomForest()], [fit_logistic()], [fit_kknn()]
#'
#' @examples
#' # Use training data from iris data set:
#' train <- head(tr_iris, -3L)
#' test  <- tibble::as_tibble(tail(tr_iris, 3L))
#'
#' # Logistic Regression
#' lr <- fit_logistic(Species ~ ., data = train)
#' calc_predictions(lr, test)
#' calc_predictions(lr, test, cutoff = 0.33)
#'
#' # Naive Bayes
#' nb <- fit_nb(Species ~ ., data = train)
#' calc_predictions(nb, test)
#' calc_predictions(nb, test, cutoff = 0.01)
#'
#' # Random Forest
#' rf <- withr::with_seed(101, {
#'   randomForest::randomForest(Species ~ ., data = train,
#'                              importance = TRUE, proximity = TRUE,
#'                              keep.inbag = TRUE)
#' })
#' head(calc_predictions(rf))        # out-of-bag
#' calc_predictions(rf, test)
#' calc_predictions(rf, test, cutoff = 0.39)
#'
#' # Generalized Boosted Regression Model
#' gb <- fit_gbm(Species ~ ., data = train)
#' calc_predictions(gb, test)
#' calc_predictions(gb, test, 0.48)
#'
#' # Support Vector Machines
#' sm <- e1071::svm(Species ~ ., data = train, probability = TRUE)
#' calc_predictions(sm, test)
#' calc_predictions(sm, test, 0.35)
#'
#' # KKNN
#' # test data passed during fitting:
#' kknn <- fit_kknn(Species ~ ., train = train, test = test, k_neighbors = 10)
#' calc_predictions(kknn)                 # do NOT pass test data
#' calc_predictions(kknn, cutoff = 0.48)
NULL

#' @export
helpr::calc_predictions

#' @describeIn s3-calc_predictions
#'   S3 method for "robust" Naive Bayes models.
#'
#' @export
calc_predictions.libml_nb <- function(model, newdata, cutoff = 0.5, ...) {
  test <- select_features(model, newdata)
  p <- predict(model, newdata = test, type = "raw")
  pos <- get_pos_class(model)
  if ( length(model$levels) > 2L ) {
    # if multi-class; ignore cutoff and use max.prob
    classes <- names(p)[apply(p, 1, which.max)]
  } else {
    classes <- ifelse(p[[pos]] >= cutoff, pos, setdiff(names(p), pos))
  }
  structure(
    cbind(classes, p),
    names = c("pred_class", paste0("prob_", names(p)))
  )
}

#' @describeIn s3-calc_predictions
#'   S3 method for Naive Bayes models.
#'
#' @export
calc_predictions.naiveBayes <- calc_predictions.libml_nb

#' @describeIn s3-calc_predictions
#'   S3 method for Random Forest models.
#'
#' @export
calc_predictions.randomForest <- function(model, newdata = NULL, cutoff = 0.5, ...) {
  pos <- get_pos_class(model)
  if ( is.null(newdata) ) {
    p <- data.frame(model$votes, row.names = NULL)
  } else {
    test <- select_features(model, newdata)
    p <- data.frame(predict(model, newdata = test, type = "prob"), row.names = NULL)
  }
  if ( length(model$classes) > 2L ) {
    # if multi-class; ignore cutoff and use max.prob
    classes <- names(p)[apply(p, 1, which.max)]
  } else {
    classes <- ifelse(p[[pos]] >= cutoff, pos, setdiff(names(p), pos))
  }
  structure(
    cbind(classes, p),
    names = c("pred_class", paste0("prob_", names(p)))
  )
}

#' @describeIn s3-calc_predictions
#'   S3 method for Gradient Boosted Tree models.
#'
#' @export
calc_predictions.gbm <- function(model, newdata, cutoff = 0.5, ...) {
  test <- select_features(model, newdata)
  p <- predict(model, newdata = test, n.trees = model$n.trees, type = "response")
  if ( length(levels(model$class)) > 2L ) {
    # if multi-class; ignore cutoff and use max.prob
    p <- setNames(data.frame(p), levels(model$class))
    classes <- names(p)[apply(p, 1, which.max)]
  } else {
    pos <- get_pos_class(model)
    neg <- setdiff(levels(model$class), pos)
    classes <- ifelse(p >= cutoff, pos, neg)
    p <- setNames(data.frame(1 - p, p), c(neg, pos))
  }
  structure(
    cbind(classes, p),
    names = c("pred_class", paste0("prob_", names(p)))
  )
}

#' @describeIn s3-calc_predictions
#'   S3 method for Support Vector Machines.
#'
#' @export
calc_predictions.svm <- function(model, newdata, cutoff = 0.5, ...) {
  test <- select_features(model, newdata)
  p   <- predict(model, newdata = test, probability = TRUE)
  p   <- data.frame(attr(p, "probabilities"), row.names = NULL)
  if ( model$nclasses > 2 ) {
    # if multi-class; ignore cutoff and use max.prob
    classes <- names(p)[apply(p, 1, which.max)]
  } else {
    pos <- get_pos_class(model)
    classes <- ifelse(p[[pos]] >= cutoff, pos, setdiff(names(p), pos))
  }
  structure(
    cbind(classes, p),
    names = c("pred_class", paste0("prob_", names(p)))
  )
}

#' @describeIn s3-calc_predictions
#'   S3 method for Logistic Regression via `glm`.
#'
#' @export
calc_predictions.glm <- function(model, newdata, cutoff = 0.5, ...) {
  test <- select_features(model, newdata)
  p    <- unname(predict(model, newdata = test, type = "response"))
  LP   <- unname(predict(model, newdata = test, type = "link"))
  if ( length(model$classes) > 2L ) {
    stop("Binary classification only supported at the moment", call. = FALSE)
  } else {
    pos <- get_pos_class(model)
    neg <- setdiff(model$classes, pos)
    classes <- ifelse(p >= cutoff, pos, neg)
    p   <- setNames(data.frame(1 - p, p), c(neg, pos))
  }
  structure(
    cbind(classes, LP, p),
    names = c("pred_class", "pred_linear", paste0("prob_", names(p)))
  )
}

#' @describeIn s3-calc_predictions
#'   S3 method for Weighted k-Nearest Neighbor.
#'   kknn models have self-contained test predictions, so `newdata`
#'   can be `NULL` to return those predictions. If *actual* `newdata`
#'   is desired, must re-fit using original data and pull test
#'   predictions. This is built-in for [fit_kknn()] objects, so
#'   the standard syntax is possible.
#'
#' @export
calc_predictions.kknn <- function(model, newdata = NULL, cutoff = 0.5, ...) {

  if ( !is.null(newdata) ) {
    if ( is.null(model$train) ) {
      warning(
        "Cannot pass `newdata` with standard `kknn` class objects.\n",
        "Returning original `test` predictions.", call. = FALSE)
      p <- model$prob
    } else {
      # refit the model w orig training data
      # to get new test predictions
      p <- fit_kknn(model$form, train = model$train, test = newdata,
                    k_neighbors = model$k, distance = model$distance,
                    kernel = model$kernel, ...)$prob
    }
  } else {
    p <- model$prob
  }

  p <- data.frame(p, row.names = NULL)

  if ( length(model$classes) > 2L ) {
    # if multi-class; ignore cutoff and use max prob
    classes <- names(p)[apply(p, 1, which.max)]
  } else {
    pos <- get_pos_class(model)
    classes <- ifelse(p[[pos]] >= cutoff, pos, setdiff(names(p), pos))
  }
  structure(
    cbind(classes, p),
    names = c("pred_class", paste0("prob_", names(p)))
  )
}
