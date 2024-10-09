#' Calculate k-Fold Cross-Validation
#'
#' Perform _k_-fold internal cross-validation on a `tr_data`
#' class object.
#'
#' @param data A training data set, for convenience can be created via
#'   [create_train()], but _must_ contain only the
#'   features to be used in fitting the model and `"Response"` column.
#' @param model.type Which type of model to run.
#' @param k Integer. The number of folds to perform (_k_-fold cross-validation).
#' @param ... Additional arguments passed to the base model fitting function, e.g.
#'   [kknn::kknn()] or [randomForest::randomForest()].
#' @return A `tibble` containing model predictions, true class names,
#'   and the fold of the sample used to make the prediction.
#' @author Stu Field
#' @seealso [fit_nb()], [fit_kknn()]
#' @seealso [randomForest::randomForest()], [fit_gbm()], [fit_logistic()]
#' @examples
#' # naive Bayes
#' # Use fake training data from iris data set
#' xv_k10_n <- kfold_cv(tr_iris, k = 10, model.type = "nb")
#' xv_k10_n
#'
#' # Boosted Regression Model
#' xv_k10_b <- kfold_cv(tr_iris, k = 10, model.type = "gbm")
#' xv_k10_b
#'
#' # Weighted K-Nearest-Neighbor
#' # Pass K = 9 for number of neighbors in hood
#' xv_k10_k <- kfold_cv(tr_iris, k = 10, model.type = "kknn", K = 9)
#' xv_k10_k
#'
#' # Random Forest
#' xv_k10_f <- kfold_cv(tr_iris, k = 10, model.type = "rf")
#' xv_k10_f
#' @importFrom tibble tibble
#' @export
kfold_cv <- function(data, k, model.type = c("lr", "nb", "rf",
                                             "svm", "kknn", "gbm"), ...) {

  if ( !inherits(data, "tr_data") ) {
    stop(
      "Please pass a `tr_data` class object. ",
      "Typically created via `create_train()`.", call. = FALSE
    )
  }

  mtype   <- match.arg(model.type)
  cv_data <- data
  n       <- nrow(data)

  if ( k == 1 ) {
    train_rows <- list(seq(n))
  } else if ( k > 1 ) {
    train_rows <- calcFoldIndices(n = n, k = k)
  } else {
    stop(
      "Value `k =` must be in [1, ", n, "]. Currently k = ", value(k), ".",
      call. = FALSE
    )
  }
  response <- .get_response(data)
  formula  <- as.formula(paste(response, "~ ."))

  lapply(1:k, function(i) {

    cv_fold <- train_rows[[i]]

    if ( mtype %in% c("gbm", "rf", "nb", "lr") ) {
      .fun <- switch(mtype,
                     gbm = fit_gbm,
                     rf  = randomForest::randomForest,
                     nb  = fit_nb,
                     lr  = fit_logistic)
      tr_model <- .fun(formula, data = cv_data[cv_fold, ])
    } else if ( mtype == "svm" ) {
      tr_model <- e1071::svm(formula, data = cv_data, subset = cv_fold,
                             probability = TRUE)
    } else if ( mtype == "kknn" ) {
      tr_model <- fit_kknn(formula,
                           train = cv_data[cv_fold, ],
                           test  = cv_data[-cv_fold, ], ...)
    }

    test_df <- cv_data[-cv_fold, ]

    if ( mtype == "kknn" ) {
      test_df <- NULL # kknn models have test predictions inside model object
    }
    label <- paste0("prob_", getPositiveClass(tr_model))
    tibble(truth     = cv_data[[response]][-cv_fold],
           predicted = calcPredictions(tr_model, test_df)[[label]],
           fold      = i)
  }) |> dplyr::bind_rows()
}


#' Calculate Numeric Indices of Folds
#'
#' Calculate the row indices for the k-folds in the training set.
#'
#' @param n Integer. Total number of available samples.
#' @param k Integer. The number of folds to group the sample.
#' @return A list of the indices corresponding to the folds.
#' @keywords internal
#' @noRd
calcFoldIndices <- function(n, k) {
  ret <- list()
  row_index <- avail_rows <- seq(n)
  k_samples <- floor(n / k)
  extra_samples <- n - k_samples * k
  for ( i in seq(k) ) {
    test.rows  <- sample(avail_rows, k_samples)
    avail_rows <- setdiff(avail_rows, test.rows)
    if ( i <= extra_samples ) {
      test.rows <- c(test.rows, sample(avail_rows, 1))
    }
    ret[[i]]   <- setdiff(row_index, test.rows)
    avail_rows <- setdiff(avail_rows, test.rows)
  }
  ret
}
