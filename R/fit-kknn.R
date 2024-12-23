#' Fit Weighted k-Nearest Neighbor Classifier
#'
#' Wrapper for fitting weighted *k*-nearest neighbor classifiers.
#'
#' @family fit
#' @inheritParams params
#' @inheritParams kknn::kknn
#'
#' @param k_neighbors See `k` in [kknn()].
#' @param distance `numeric(1)`. Parameter of Minkowski distance.
#'   `Manhattan = 1` and `Euclidean = 2`.
#' @param ... Additional arguments passed to [kknn()].
#'
#' @return A k-nearest neighbors model, as returned by [kknn()],
#'   with a `"Response"` variable, `classes`, and function parameters `train`,
#'   `k`, `distance`, `kernel`, as well as the function call (`call`)
#'   added as entries to the list.
#' @author Stu Field
#' @seealso [kknn()]
#'
#' @examples
#' # Use fake training data from iris data set
#' train_idx <- sample(nrow(tr_iris), 90L)  # random 90% training
#' test_df   <- tr_iris[-train_idx, ]
#' kknnfit   <- fit_kknn(Species ~ ., train = tr_iris[train_idx, ], test = test_df)
#' pos  <- get_pos_class(kknnfit)
#' pred <- calc_predictions(kknnfit) # internal test predictions
#' pred
#'
#' # Confusion matrix
#' calc_confusion(test_df$Species, pred$prob_virginica, pos_class = pos) |>
#'   summary()
#'
#' # plot ROC
#' plot_emp_roc(test_df$Species, pred$prob_virginica, pos)
#' @importFrom kknn kknn
#' @export
fit_kknn <- function(formula, train, test, k_neighbors = 10, distance = 2,
                     kernel = "triangular", ...) {

  model <- kknn(formula, train = train, test = test,
                k = min(k_neighbors, nrow(train)),
                distance = distance, kernel = kernel, ...)
  resp_col       <- as.character(attributes(model$terms)$predvars)[2L]
  model$Response <- test[[resp_col]]
  model$classes  <- levels(model$fitted.values)
  row.names(model$prob) <- row.names(test)
  model$train    <- train
  model$form     <- formula
  model$k        <- k_neighbors
  model$distance <- distance
  model$kernel   <- kernel
  model
}
