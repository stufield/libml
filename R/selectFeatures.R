#' Select Model Features
#'
#' Subsets a data frame (or `soma_adat`) to only the model predictor
#' variables (columns), aka the "model frame", for a given a _model_.
#' Similar to [model.frame()], except a _model_ is passed rather than
#' a _formula_.
#'
#' @param model A model with an S3 [getModelFeatures()] method. See description
#'   in [getModelFeatures()].
#' @param .data A `data.frame`, typically containing a test data
#'   of samples to to subset down to the minimal set of features.
#' @return A `data.frame`-like object (depending on class of `.data`) subset
#'   to only the variables/features contained in the `model`.
#' @author Stu Field
#' @examples
#' # Use fake training data from iris data set:
#' train_idx <- sample.int(nrow(fake_iris), size = 70)
#' train <- fake_iris[train_idx, -3L]
#' test  <- fake_iris[-train_idx, -3L]
#'
#' lr <- fitGLM(Response ~ ., data = train)
#' selectFeatures(lr, train)
#' selectFeatures(lr, test)
#' \dontrun{selectFeatures(lr, test[, -2L])} # throws error
#'
#' # Generalized Boosted Regression Model
#' gb <- fitGBM(Response ~ ., data = train)
#' getModelCoef(gb)
#'
#' # Support Vector Machines
#' sm <- e1071::svm(Response ~ ., data = train, probability = TRUE)
#' getModelCoef(sm)
#'
#' # KKNN
#' # test data passed during fitting:
#' test <- tail(fake_iris, 3L)
#' kknn <- fitKKNN(Response ~ ., train = train, test = test, K = 10)
#' getModelCoef(kknn)
#' @export
selectFeatures <- function(model, .data) {
  features <- getModelFeatures(model)
  if ( any(!features %in% names(.data)) ) {
    stop(
      "There are missing model features in data set.\n",
      "Please check the column names and compare to those in the model.",
      call. = FALSE
    )
  }
  if ( inherits(.data, "grouped_df") ) {
    .data <- dplyr::ungroup(.data)  # don't care about groupings; avoids warning()
  }
  .data[, features, drop = FALSE]
}
