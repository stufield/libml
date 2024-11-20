
# Setup -----
args <- list(data = tr_iris, k = 3L)

skip("for now in favor of `splyr::create_kfold()`")


# Testing -------
test_that("`kfold_cv()` generates correct output for various model types", {

  withr::local_seed(101)

  # Logistic regression
  args$model_type <- "lr"
  lr <- do.call(kfold_cv, args)
  lrsumm <- summary(lr)

  # naive Bayes
  args$model_type <- "nb"
  nB <- do.call(kfold_cv, args)
  nBsumm <- summary(nB)

  # Random Forest
  args$model_type <- "rf"
  rf <- do.call(kfold_cv, args)
  rfsumm <- summary(rf)

  # support vector machines
  args$model_type <- "svm"
  svm <- do.call(kfold_cv, args)
  svmsumm <- summary(svm)

  # Boosted Regression Model
  args$model_type <- "gbm"
  br <-  do.call(kfold_cv, args)
  brsumm <- summary(br)

  # Weighted K-Nearest-Neighbor
  args$model_type <- "kknn"
  args$k_neighbors <- 5
  knn <- do.call(kfold_cv, args)
  knnsumm <- summary(knn)
})
