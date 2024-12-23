#' Calculate k-Fold Cross-Validation
#'
#' Perform *k*-fold internal cross-validation on
#'   a `tr_data` class object.
#'
#' @param data A training data set, for convenience should be
#'   created via [create_train()], but *must* contain only the
#'   features to be used in fitting the model and `"Response"` column.
#' @param k `integer(1)`. The number of folds to perform
#'   (*k*-fold cross-validation). Passed to [wranglr::create_kfold()].
#' @param model_type Which type of model to run.
#' @param kknn_args Additional arguments as a pass-through to
#'   [fit_kknn()], since the `...` is already used. Ignored unless
#'   `type = "kknn"`.
#' @param ... Additional arguments passed to [wranglr::create_kfold()].
#'
#' @return A `tibble` containing model predictions, true class names,
#'   and the fold of the samples used to make the prediction. There
#'   should be a "test" prediction for each sample in `data`.
#'
#' @author Stu Field
#'
#' @seealso [fit_nb()], [fit_kknn()]
#' @seealso [randomForest::randomForest()], [fit_gbm()], [fit_logistic()]
#'
#' @examples
#' # naive Bayes
#' # Use fake training data from iris data set
#' k10_nb <- kfold_cv(tr_iris, k = 10L, model_type = "nb")
#' k10_nb
#'
#' # Boosted Regression Model
#' k10_b <- kfold_cv(tr_iris, k = 10L, model_type = "gbm")
#' k10_b
#'
#' # Weighted K-Nearest-Neighbor
#' # Pass k_neighbors = 9 for number of neighbors in hood
#' k10_knn <- kfold_cv(tr_iris, k = 10L, model_type = "kknn")
#' k10_knn
#'
#' # Random Forest
#' k10_rf <- kfold_cv(tr_iris, k = 10L, model_type = "rf")
#' k10_rf
#' @importFrom tibble tibble
#' @export
kfold_cv <- function(data, k, kknn_args = list(k_neighbors = 9L),
                     model_type = c("lr", "nb", "rf", "svm", "kknn", "gbm"), ...) {

  if ( !inherits(data, "tr_data") ) {
    stop(
      "Please pass a `tr_data` class object. ",
      "Typically created via `create_train()`.", call. = FALSE
    )
  }

  mtype <- match.arg(model_type)
  n     <- nrow(data)

  if ( k >= 1L && k <= n ) {
    cv_splits <- create_kfold(data, k = k, ...)
  } else {
    stop(
      "Value `k =` must be in (1L, ", n, "). Currently k = ", value(k), ".",
      call. = FALSE
    )
  }
  response <- .get_response(data)
  formula  <- as.formula(paste(response, "~ ."))

  lapply(1:k, function(i) {

    train_df <- analysis(cv_splits, i)[[1]]
    test_df  <- assessment(cv_splits, i)[[1]]

    if ( mtype %in% c("gbm", "rf", "nb", "lr", "svm") ) {
      .fun <- switch(mtype,
                     gbm = fit_gbm,
                     rf  = randomForest::randomForest,
                     svm = e1071::svm,
                     nb  = fit_nb,
                     lr  = fit_logistic)
      if ( mtype == "svm" ) {  # hard code if SVM
        .fun <- be_hard(.fun, probability = TRUE)
      }
      tr_model <- .fun(formula, data = train_df)
    } else if ( mtype == "kknn" ) {
      kknn_args <- c(list(formula = formula,
                          train = train_df,
                          test = test_df),
                     kknn_args)
      tr_model <- do.call(fit_kknn, kknn_args)
    }

    label <- paste0("prob_", get_pos_class(tr_model))
    tibble(truth     = test_df[[response]],
           predicted = calc_predictions(tr_model, test_df)[[label]],
           fold      = i)
  }) |>
    dplyr::bind_rows()
}
