
# Setup ----
data         <- centerScaleData(log10(sim_test_data))
reg_features <- attr(data, "sig_feats")$reg
reg_data     <- data[, c("reg_response", reg_features)]
features     <- c("(Intercept)", "Sepal.Length", "Sepal.Width",
                  "Petal.Length", "Petal.Width")
reg_features <- c("(Intercept)", reg_features)

expected_class_coefs <- list(
  glmnet       = c(-1.783968704, 0.225253653,  0.0000000,   0.136048927, 0.0000000),
  glm          = c(-1.89320798,  0.52919531,  -0.58025558,  0.24041493, -0.10747879),
  caret_glm    = c(-1.893207979, 0.529195311, -0.580255584, 0.240414931, -0.107478794),
  caret_glmnet = c(-1.55959533,  0.41175204,  -0.46195915,  0.17976789, 0.03708661)
)

expected_class_coefs <- lapply(expected_class_coefs, setNames, nm = features)

expected_reg_coefs  <- list(
  svm          = c(0.01165406, 0.30312404, 0.03302784, 0.46405124, 0.13513110, 0.31726695),
  caret_glmnet = c(200.000000, 147.57921, 63.43358, 146.50549, 50.84156, 151.31570)
) |>
lapply(setNames, nm = reg_features)



# Testing ----
# glmnet model ----
test_that("`getModelCoef()` returns correct coefs for class 'glmnet'", {
  model <- glmnet::glmnet(data.matrix(fake_iris[, -5L]),
                          y = fake_iris$Response,
                          family = "binomial", lambda = 0.1, alpha = 1)
  test_val <- getModelCoef(model)
  expect_equal(test_val, expected_class_coefs$glmnet)
})

# glm model ----
test_that("`getModelCoef()` returns correct coefs for class 'glm'", {
  model    <- stats::glm(Response ~ ., data = fake_iris, family = "binomial")
  test_val <- getModelCoef(model)
  expect_equal(test_val, expected_class_coefs$glm)
})

# random forest model ----
test_that("`getModelCoef()` returns correct coefs for class 'randomForest'", {
  rf <- withr::with_seed(1,
    randomForest::randomForest(Response ~ ., data = fake_iris, importance = TRUE)
  )
  expect_null(getModelCoef(rf))
})

# SVM model ----
test_that("`getModelCoef()` returns correct coefs for class 'svm'", {
  model <- e1071::svm(Response ~ ., data = fake_iris)
  expect_null(getModelCoef(model))
})

# SVM Regression model ----
test_that("`getModelCoef()` returns correct coefs for class 'svm' (regression)", {
  model <- withr::with_seed(12345,
    e1071::svm(reg_response ~ ., data = reg_data, kernel = "linear")
  )
  test_val <- getModelCoef(model)
  expect_equal(test_val, expected_reg_coefs$svm)
})

# GBM model ----
test_that("`getModelCoef()` returns correct coefs for class 'gbm'", {
  model    <- fitGBM(Response ~ ., data = fake_iris, distribution = "bernoulli")
  test_val <- getModelCoef(model)
  expect_null(test_val)
})

# robust naive Bayes model ----
test_that("`getModelCoef()` returns correct coefs for class 'naiveBayes'", {
  model    <- robustNaiveBayes(Response ~ ., data = fake_iris)
  test_val <- getModelCoef(model)
  expect_null(test_val)
})

# caret Logistic model ----
test_that("`getModelCoef()` correct coefs for train:logistic regression", {
  withr::local_package("caret")
  t_crtl <- caret::trainControl(method = "repeatedcv")
  model  <- withr::with_seed(12345,
    caret::train(Response ~ ., data = fake_iris, trControl = t_crtl, method = "glm")
  )
  test_val <- getModelCoef(model)
  expect_equal(test_val, expected_class_coefs$caret_glm)

  model <- withr::with_seed(12345,
    caret::train(Response ~ ., data = fake_iris, trControl = t_crtl, method = "glmnet")
  )
  test_val <- getModelCoef(model)
  expect_equal(test_val, expected_class_coefs$caret_glmnet)
})

# caret Regression model ----
test_that("`getModelCoef()` correct coefs for train:linear regression", {
  withr::local_package("caret")
  t_crtl <- caret::trainControl(method = "repeatedcv")
  model  <- withr::with_seed(12345,
    caret::train(reg_response ~ ., data = reg_data, trControl = t_crtl,
                 metric = "RMSE", method = "glmnet")
  )
  test_val <- getModelCoef(model)
  expect_equal(test_val, expected_reg_coefs$caret_glmnet)
})

# generic error catch ----
test_that("`getModelCoef()` throws errors when incorrect arguments are passed", {
  # unknown model type; default method
  expect_error(
    getModelCoef(data.frame(a = 1:3)),
    paste("Could not find a `getModelCoef()` S3 method",
          "for this model type: 'data.frame'"),
    fixed = TRUE
  )
})
