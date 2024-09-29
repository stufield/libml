
# Setup -----
# predictions on fake_iris data set
args <- list(data = fake_iris, k = 3, model.type = "lr")


# Testing -------
test_that("kfold_cv() generates correct output for various model types", {
  skip("in favor of `caret` cross validation for now")

  withr::local_seed(101)

  # Logistic regression
  lr <- do.call(kfold_cv, args)
  lrsumm <- summary(lr)

  # naive Bayes
  args$model.type <- "nb"
  nB <- do.call(kfold_cv, args)
  nBsumm <- summary(nB)

  # Random Forest
  args$model.type <- "rf"
  rf <- do.call(kfold_cv, args)
  rfsumm <- summary(rf)

  # support vector machines
  args$model.type <- "svm"
  svm <- do.call(kfold_cv, args)
  svmsumm <- summary(svm)

  # Boosted Regression Model
  args$model.type <- "gbm"
  br <-  do.call(kfold_cv, args)
  brsumm <- summary(br)

  # Weighted K-Nearest-Neighbor
  args$model.type <- "kknn"
  args$K <- 2
  knn <- do.call(kfold_cv, args)
  knnsumm <- summary(knn)
})
