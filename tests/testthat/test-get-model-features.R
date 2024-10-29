
# Setup ----
features <- c("Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width")

# Testing ----
# glmnet model ----
test_that("`get_model_features()` returns correct features for class 'glmnet'", {
  model <- glmnet::glmnet(data.matrix(tr_iris[, -5L]), y = tr_iris$Species,
                          family = "binomial", lambda = 0.1, alpha = 1)
  expect_equal(features, get_model_features(model))
})

# glm model ----
test_that("`get_model_features()` returns correct features for class 'glm'", {
  model <- stats::glm(Species ~ ., data = tr_iris, family = "binomial")
  expect_equal(features, get_model_features(model))
})

# random forest model ----
test_that("`get_model_features()` returns correct features for class 'randomForest'", {
  rf <- randomForest::randomForest(Species ~ ., data = tr_iris, importance = TRUE)
  expect_equal(features, get_model_features(rf))
})

# SVM model ----
test_that("`get_model_features()` returns correct features for class 'svm'", {
  model <- e1071::svm(Species ~ ., data = tr_iris)
  expect_equal(features, get_model_features(model))
})

# GBM model ----
test_that("`get_model_features()` returns correct features for class 'gbm'", {
  model <- fit_gbm(Species ~ ., data = tr_iris, distribution = "bernoulli")
  expect_equal(features, get_model_features(model))
})

# robust naive Bayes model ----
test_that("`get_model_features()` returns correct features for class 'fit_nb'", {
  model <- fit_nb(Species ~ ., data = tr_iris)
  expect_equal(features, get_model_features(model))
})

# coxnet2 model ----
test_that("`get_model_features.coxnet2()` covered by `get_model_features.glmnet()`", {
  succeed()
})

# survregnet model ----
test_that("`get_model_features.survregnet()` covered by `get_model_features.glmnet()`", {
  succeed()
})

# survreg & psm models ----
test_that("`get_model_features()` returns correct features for class 'survreg'", {
  # hack together a dummy "survreg" object; just for testing
  # this avoids importing `survival` and `rms`
  obj <- list()
  ft  <- c("(Intercept)", "f1", "f2", "f3", "f4", "f5")
  obj$coefficients <- setNames(rnorm(6), ft)
  class(obj) <- c("survreg", class(obj))
  expect_equal(ft[-1L], get_model_features(obj))   # -1 rm Intercept

  # psm models are essentially the same;
  class(obj) <- c("psm", class(obj))
  expect_equal(ft[-1L], get_model_features(obj))   # -1 rm Intercept
})

# caret Logistic model ----
test_that("`get_model_features()` correct features for train:logistic regression", {
  t_crtl <- caret::trainControl(method = "repeatedcv")
  model  <- caret::train(Species ~ ., data = tr_iris, trControl = t_crtl,
                         method = "glm")
  expect_equal(features, get_model_features(model))
  model  <- caret::train(Species ~ ., data = tr_iris, trControl = t_crtl,
                         method = "glmnet")
  expect_equal(features, get_model_features(model))
})

# caret Regression model ----
test_that("`get_model_features()` correct features for train:linear regression", {
  data        <- sim_adat
  fts         <- attributes(data)$sig_feats$reg
  caret_data  <- data[, c(fts, "reg_response")]
  t_crtl      <- caret::trainControl(method = "repeatedcv")
  caret_model <- caret::train(reg_response ~ ., data = caret_data,
                              trControl = t_crtl,
                              metric = "RMSE", method = "glmnet")
  expect_equal(fts, get_model_features(caret_model))
})

# caret error catches ----
test_that("`get_model_features()` throws errors when incorrect arguments are passed", {
  # unknown model type; default method
  dummy <- data.frame(a = 1:3)
  expect_error(
    get_model_features(dummy),
    paste("Could not find a `get_model_features()` S3 method",
          "for this model type: 'data.frame'"), fixed = TRUE
  )
  # Error catch for no `coefnames` element
  class(dummy) <- c("train", "data.frame")
  expect_error(
    get_model_features(dummy),
    "The 'coefnames' element of the train object was empty"
  )
})
