#' Select Model Features
#'
#' Subsets a data frame to only the model predictor
#'   variables (columns), aka the "model frame", for
#'   a given a *model*. Similar to [model.frame()],
#'   except a *model* is passed rather than a *formula*.
#'
#' @param model A model with an S3 [get_model_features()] method. See description
#'   in [helpr::get_model_features()].
#' @param .data A `data.frame`, typically containing a test data
#'   of samples to to subset down to the minimal set of features.
#'
#' @return A `data.frame`-like object (depending on
#'   class of `.data`) subset to only the variables/features
#'   contained in the `model`.
#' @author Stu Field
#'
#' @examples
#' # set up training and test data:
#' idx   <- sample.int(nrow(tr_iris), size = 90L)
#' train <- tr_iris[idx, ]
#' test  <- tibble::as_tibble(tr_iris[-idx, ])
#'
#' lr <- fit_logistic(train)
#' select_features(lr, train)
#'
#' select_features(lr, test)
#'
#' \dontrun{
#'   select_features(lr, test[, -2L]) # throws error; missing feature
#' }
#'
#' # Generalized Boosted Regression Model
#' gb <- fit_gbm(Species ~ ., data = train)
#' select_features(gb, test)
#'
#' # Support Vector Machines
#' sm <- e1071::svm(Species ~ ., data = train, probability = TRUE)
#' select_features(sm, test)
#'
#' # KKNN
#' # note: test data passed during fitting
#' kknn <- fit_kknn(Species ~ ., train = train, test = test, k_neighbors = 10)
#' select_features(kknn, test)
#' @importFrom tibble as_tibble
#' @export
select_features <- function(model, .data) {
  ft <- get_model_features(model)
  if ( any(!ft %in% names(.data)) ) {
    stop(
      "There are missing model features in data set.\n",
      "Please check the column names and compare to those in the model.",
      call. = FALSE
    )
  }
  if ( inherits(.data, "grouped_df") ) {
    # don't care about groupings; avoids warning()
    if ( inherits(.data, "tbl_df") ) {
      .data <- as_tibble(.data)
    } else {
      .data <- data.frame(.data)
    }
  }
  .data[, ft, drop = FALSE]
}
