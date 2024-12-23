
# Setup -----
args <- list(data = tr_iris, k = 3L)

# Testing -------
test_that("`kfold_cv()` generates correct output for various model types", {
  # use snapshot tests to simplify output testing and updating

  # Logistic regression
  expect_snapshot({
    args$model_type <- "lr"
    withr::with_seed(101, summary(do.call(kfold_cv, args)))
  })

  # naive Bayes
  expect_snapshot({
    args$model_type <- "nb"
    withr::with_seed(101, summary(do.call(kfold_cv, args)))
  })

  # Random Forest
  expect_snapshot({
    args$model_type <- "rf"
    withr::with_seed(101, summary(do.call(kfold_cv, args)))
  })

  # support vector machines
  expect_snapshot({
    args$model_type <- "svm"
    withr::with_seed(101, summary(do.call(kfold_cv, args)))
  })

  # Boosted Regression Model
  expect_snapshot({
    args$model_type <- "gbm"
    withr::with_seed(101, summary(do.call(kfold_cv, args)))
  })

  # Weighted K-Nearest-Neighbor
  expect_snapshot({
    args$model_type <- "kknn"
    args$k_neighbors <- 5
    withr::with_seed(101, summary(do.call(kfold_cv, args)))
  })
})
