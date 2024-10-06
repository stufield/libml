#' Fit Weighted k-Nearest Neighbor Classifier
#'
#' Wrapper for fitting weighted _k_-nearest neighbor classifiers.
#'
#' @family fit
#' @param formula An object of class "formula": a symbolic
#'   description of the model to be fitted (e.g. \eqn{Response ~ terms}).
#' @param train Matrix or data frame of training set cases.
#' @param test Matrix or data frame of test set cases.
#' @param K Numeric. Number of neighbors considered.
#' @param distance Numeric. Parameter of Minkowski distance. `1` is
#'   equivalent to Manhattan distance and `2` is equivalent to Euclidean.
#' @param kernel Character. Kernel to use. Possible choices are:
#'   \describe{
#'     \item{rectangular}{standard unweighted `knn`}
#'     \item{triangular}{\eqn{1 - |u|, |u| \le 1}}
#'     \item{epanechnikov}{beta(2, 2)}
#'     \item{biweight}{beta(3, 3)}
#'     \item{triweight}{beta(4, 4)}
#'     \item{cos}{\eqn{cos(0.5\pi u)}}
#'     \item{inv}{?}
#'     \item{gaussian}{\eqn{exp(-0.5u^2)}}
#'     \item{rank}{?}
#'     \item{optimal}{?}
#'   }
#' @param ... Additional arguments passed to [kknn()].
#' @return A k-nearest neighbors model, as returned by [kknn()],
#'   with a `"Response"` variable, `classes`, and function parameters `train`,
#'   `K`, `distance`, `kernel`, as well as the function call (`call`)
#'   added as entries to the list.
#' @author Stu Field
#' @seealso [kknn()]
#' @examples
#' # Use fake training data from iris data set
#' trainIdx <- sample(nrow(tr_iris), 90)  # random 90% training
#' kknnfit  <- fitKKNN(Species ~ ., train = tr_iris[trainIdx, ],
#'                     test = tr_iris[-trainIdx, ])
#' pos  <- getPositiveClass(kknnfit)
#' true <- tr_iris$Species[-trainIdx]   # true class names
#' pred <- calcPredictions(kknnfit)       # model predictions
#' pred
#'
#' # Confusion matrix
#' calc_confusion(true, pred$prob_virginica, pos.class = pos) |>
#'   summary()
#'
#' # plot ROC
#' plotEmpROC(true, pred$prob_virginica, pos)
#' @importFrom kknn kknn
#' @export
fitKKNN <- function(formula, train, test, K = 10, distance = 2,
                    kernel = "triangular", ...) {

  model <- kknn(formula, train = train, test = test,
                k = min(K, nrow(train)),
                distance = distance, kernel = kernel, ...)
  resp_col       <- as.character(attributes(model$terms)$predvars)[2L]
  model$Response <- test[[resp_col]]
  model$classes  <- levels(model$fitted.values)
  model$train    <- deparse(substitute(train))
  row.names(model$prob) <- row.names(test)
  model$K        <- K
  model$call     <- match.call()
  model$distance <- distance
  model$kernel   <- kernel
  model
}
