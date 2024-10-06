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
#' @inheritParams globalr::calcPredictions
#' @inheritParams params
#' @param model A model object. Currently one of:
#' \itemize{
#'   \item `glm` (for logistic regression)
#'   \item `robustNaiveBayes`
#'   \item `naiveBayes`
#'   \item `randomForest`
#'   \item `svm`
#'   \item `gbm`
#'   \item `kknn`
#'   \item `soma_lognet`
#' }
#' @return A `data.frame` with predicted class and class probabilities for
#'   each row in `newdata`:
#'   \item{`pred_class`}{predicted class for each new observation.
#'                      If there are more than two classes, the class with
#'                      the _highest_ predicted probability. Otherwise, class
#'                      predictions are returned based on the value of `cutoff`.}
#'   \item{`prob_*`}{probability of belonging to class `*` for each new observation.}
#'   \item{`pred_linear`}{for linear models, the linear predictor for
#'                        each new observation.}
#' @author Stu Field
#' @seealso [robustNaiveBayes()], [randomForest()], [glm()], [kknn()]
#' @examples
#' # Use fake training data from iris data set:
#' train <- head(fake_iris, -3L)
#' test  <- tail(fake_iris, 3L)
#'
#' # Logistic Regression
#' lr <- fitGLM(Response ~ ., data = train)
#' calcPredictions(lr, test)
#' calcPredictions(lr, test, cutoff = 0.33)
#'
#' # Naive Bayes
#' nb <- robustNaiveBayes(Response ~ ., data = train)
#' calcPredictions(nb, test)
#' calcPredictions(nb, test, cutoff = 0.01)
#'
#' # Random Forest
#' rf <- withr::with_seed(101, {
#'   randomForest::randomForest(Response ~ ., data = train,
#'                              importance = TRUE, proximity = TRUE,
#'                              keep.inbag = TRUE)
#' })
#' head(calcPredictions(rf))        # out-of-bag
#' calcPredictions(rf, test)
#' calcPredictions(rf, test, cutoff = 0.39)
#'
#' # Generalized Boosted Regression Model
#' gb <- fitGBM(Response ~ ., data = train)
#' calcPredictions(gb, test)
#' calcPredictions(gb, test, 0.48)
#'
#' # Support Vector Machines
#' sm <- e1071::svm(Response ~ ., data = train, probability = TRUE)
#' calcPredictions(sm, test)
#' calcPredictions(sm, test, 0.35)
#'
#' # KKNN
#' # test data passed during fitting:
#' kknn <- fitKKNN(Response ~ ., train = train, test = test, K = 10)
#' calcPredictions(kknn)                 # do NOT pass test data
#' calcPredictions(kknn, cutoff = 0.48)
#' @name s3-calcPredictions
NULL

#' @export
globalr::calcPredictions

#' @describeIn s3-calcPredictions
#' S3 method for "robust" Naive Bayes models.
#' @export
calcPredictions.robustNaiveBayes <- function(model, newdata, cutoff = 0.5, ...) {
  test <- select_features(model, newdata)
  p <- predict(model, newdata = test, type = "raw")
  pos <- getPositiveClass(model)
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

#' @describeIn s3-calcPredictions S3 method for Naive Bayes models.
#' @export
calcPredictions.naiveBayes <- calcPredictions.robustNaiveBayes

#' @describeIn s3-calcPredictions
#' S3 method for Random Forest models.
#' @export
calcPredictions.randomForest <- function(model, newdata = NULL, cutoff = 0.5, ...) {
  pos <- getPositiveClass(model)
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

#' @describeIn s3-calcPredictions
#' S3 method for Gradient Boosted Tree models.
#' @export
calcPredictions.gbm <- function(model, newdata, cutoff = 0.5, ...) {
  test <- select_features(model, newdata)
  p <- predict(model, newdata = test, n.trees = model$n.trees, type = "response")
  if ( length(levels(model$class)) > 2L ) {
    # if multi-class; ignore cutoff and use max.prob
    p <- setNames(data.frame(p), levels(model$class))
    classes <- names(p)[apply(p, 1, which.max)]
  } else {
    pos <- getPositiveClass(model)
    neg <- setdiff(levels(model$class), pos)
    classes <- ifelse(p >= cutoff, pos, neg)
    p <- setNames(data.frame(1 - p, p), c(neg, pos))
  }
  structure(
    cbind(classes, p),
    names = c("pred_class", paste0("prob_", names(p)))
  )
}

#' @describeIn s3-calcPredictions
#' S3 method for Support Vector Machines.
#' @export
calcPredictions.svm <- function(model, newdata, cutoff = 0.5, ...) {
  test <- select_features(model, newdata)
  p   <- predict(model, newdata = test, probability = TRUE)
  p   <- data.frame(attr(p, "probabilities"), row.names = NULL)
  if ( model$nclasses > 2 ) {
    # if multi-class; ignore cutoff and use max.prob
    classes <- names(p)[apply(p, 1, which.max)]
  } else {
    pos <- getPositiveClass(model)
    classes <- ifelse(p[[pos]] >= cutoff, pos, setdiff(names(p), pos))
  }
  structure(
    cbind(classes, p),
    names = c("pred_class", paste0("prob_", names(p)))
  )
}

#' @describeIn s3-calcPredictions
#' S3 method for Logistic Regression via `glm`.
#' @export
calcPredictions.glm <- function(model, newdata, cutoff = 0.5, ...) {
  test <- select_features(model, newdata)
  p    <- unname(predict(model, newdata = test, type = "response"))
  LP   <- unname(predict(model, newdata = test, type = "link"))
  if ( length(model$classes) > 2L ) {
    stop("Binary classification only supported at the moment", call. = FALSE)
  } else {
    pos <- getPositiveClass(model)
    neg <- setdiff(model$classes, pos)
    classes <- ifelse(p >= cutoff, pos, neg)
    p   <- setNames(data.frame(1 - p, p), c(neg, pos))
  }
  structure(
    cbind(classes, LP, p),
    names = c("pred_class", "pred_linear", paste0("prob_", names(p)))
  )
}

#' @describeIn s3-calcPredictions
#' S3 method for Weighted k-Nearest Neighbor.
#' @export
calcPredictions.kknn <- function(model, newdata = NULL, cutoff = 0.5, ...) {

  if ( !is.null(newdata) ) {
    warning(
      "KKNN models differ from other class models.\n",
      "Test predictions are built into the model object. `newdata` will be ignored.",
      call. = FALSE
    )
  }

  p <- data.frame(model$prob, row.names = NULL)

  if ( length(model$classes) > 2L ) {
    # if multi-class; ignore cutoff and use max.prob
    classes <- names(p)[apply(p, 1, which.max)]
  } else {
    pos <- getPositiveClass(model)
    classes <- ifelse(p[[pos]] >= cutoff, pos, setdiff(names(p), pos))
  }
  structure(
    cbind(classes, p),
    names = c("pred_class", paste0("prob_", names(p)))
  )
}

#' @describeIn s3-calcPredictions
#' S3 method for Logistic Regression Elastic Net models.
#' @export
calcPredictions.soma_lognet <- calcPredictions.glm

