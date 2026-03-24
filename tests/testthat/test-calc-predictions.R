
# Setup ----
# Uses `tr_iris` training data set object from iris data set
train <- head(tr_iris, -3L)
test  <- tibble::as_tibble(tail(tr_iris, 3L))  # strip `tr_data` class


# Testing ----
test_that("the logistic regression (GLM) method returns correct predictions", {
  # Logistic Regression
  lr <- fit_logistic(train)
  pred1 <- calc_predictions(lr, test)
  expect_false(has_rn(pred1))
  expect_equal(pred1,
    tibble(pred_class = c("virginica", "setosa", "setosa"),
      pred_linear = c(1.78167792472932, -0.609193148994239, -1.27204605039852),
      prob_setosa = c(0.144096068014264, 0.647756726495939, 0.781092796804913),
      prob_virginica = c(0.855903931985736, 0.352243273504061, 0.218907203195087)
    )
  )
  # with cutoff to switch class prediction
  pred2 <- calc_predictions(lr, test, cutoff = 0.33)
  expect_equal(pred2,
    tibble(
      pred_class = c("virginica", "virginica", "setosa"),
      pred_linear = c(1.78167792472932, -0.609193148994239, -1.27204605039852),
      prob_setosa = c(0.144096068014264, 0.647756726495939, 0.781092796804913),
      prob_virginica = c(0.855903931985736, 0.352243273504061, 0.218907203195087)
    )
  )
})

test_that("the Naive Bayes method returns correct predictions", {
  nb <- fit_nb(Species ~ ., data = train)
  pred1 <- calc_predictions(nb, test)
  expect_false(has_rn(pred1))
  expect_equal(pred1,
    tibble(pred_class = c("virginica", "setosa", "setosa"),
      prob_setosa = c(2.94243132997378e-05, 0.983414967907472, 0.999945042516105),
      prob_virginica = c(0.9999705756867, 0.016585032092528, 5.49574838953107e-05)
    )
  )
  # with cutoff to switch class prediction
  pred2 <- calc_predictions(nb, tail(fake_iris, 3L), cutoff = 0.01)
  expect_equal(pred2,
    tibble(pred_class = c("virginica", "virginica", "setosa"),
      prob_setosa = c(2.94243132997378e-05, 0.983414967907472, 0.999945042516105),
      prob_virginica = c(0.9999705756867, 0.016585032092528, 5.49574838953107e-05)
    )
  )
})

test_that("the Random Forest method returns correct out-of-bag predictions", {
  rf <- withr::with_seed(101,
          randomForest::randomForest(Species ~ ., data = train,
                                     importance = TRUE,
                                     proximity = TRUE, keep.inbag = TRUE)
  )
  pred1 <- calc_predictions(rf, NULL)                # out-of-bag
  expect_false(has_rn(pred1))
  # there are 97 out-of-bag samples; just test summaries
  expect_equal(c(table(pred1$pred_class)), c(setosa = 50, virginica = 47))
  expect_equal(sum(pred1$prob_setosa), 49.270947975713)
  expect_equal(sum(pred1$prob_virginica), 47.729052024287)
})

test_that("the Random Forest method returns correct predictions with test data", {
  rf <- withr::with_seed(999,
          randomForest::randomForest(Species ~ ., data = train,
                                     importance = TRUE,
                                     proximity = TRUE, keep.inbag = TRUE)
  )
  # with test data
  pred1 <- calc_predictions(rf, test)
  expect_false(has_rn(pred1))
  expect_equal(pred1, tibble(pred_class = c("virginica", "setosa", "setosa"),
                        prob_setosa     = c(0.27, 0.606, 0.812),
                        prob_virginica  = c(0.73, 0.394, 0.188)
                      )
  )
  # with cutoff to switch class prediction
  pred2 <- calc_predictions(rf, test, cutoff = 0.39)
  expect_equal(pred2, tibble(pred_class = c("virginica", "virginica", "setosa"),
                        prob_setosa     = c(0.27, 0.606, 0.812),
                        prob_virginica  = c(0.73, 0.394, 0.188)
                      )
  )
})

test_that("the General Boosted Regression (GBM) returns correct predictions", {
  gb <- withr::with_seed(101, fit_gbm(Species ~ ., data = train,
                                      distribution = "bernoulli"))
  pred1 <- calc_predictions(gb, test)
  expect_false(has_rn(pred1))
  expect_equal(pred1, tibble(pred_class = c("virginica", "setosa", "setosa"),
                        prob_setosa = c(0.15781951638483,
                                        0.503400655494596,
                                        0.806205501737701),
                     prob_virginica = c(0.84218048361517,
                                        0.496599344505404,
                                        0.193794498262298)
                     )
  )
  # with cutoff to switch class prediction
  pred2 <- calc_predictions(gb, test, 0.48)
  expect_equal(pred2, tibble(pred_class  = c("virginica", "virginica", "setosa"),
                        prob_setosa = c(0.15781951638483,
                                        0.503400655494596,
                                        0.806205501737701),
                        prob_virginica = c(0.84218048361517,
                                           0.496599344505404,
                                           0.193794498262298)
                        )
  )
})

test_that("the Support Vector Machines method returns correct predictions", {
  sm <- withr::with_seed(101,
          e1071::svm(Species ~ ., data = train, probability = TRUE)
        )
  pred1 <- calc_predictions(sm, test)
  expect_false(has_rn(pred1))
  expect_equal(
    pred1,
    tibble(
      pred_class  = c("virginica", "setosa", "setosa"),
      prob_setosa = c(0.194779472, 0.647764575, 0.750484873),
      prob_virginica = c(0.805220528, 0.352235425, 0.249515127)
    )
  )
  # with cutoff to switch class prediction
  pred2 <- calc_predictions(sm, test, 0.35)
  expect_equal(
    pred2,
    tibble(
      pred_class  = c("virginica", "virginica", "setosa"),
      prob_setosa = c(0.194779472, 0.647764575, 0.750484873),
      prob_virginica = c(0.805220528, 0.352235425, 0.249515127)
    )
  )
})

test_that("the `KKNN` method returns correct predictions", {
  # test set passed in during model fit
  kknn  <- fit_kknn(Species ~ ., train = train, test = test, k_neighbors = 10L)
  pred1 <- calc_predictions(kknn, newdata = NULL)
  expect_false(has_rn(pred1))
  true <- tibble(pred_class = c("virginica", "setosa", "setosa"),
            prob_setosa = c(0.235910086510298,
                            0.750153765250901,
                            0.5161924979046),
            prob_virginica = c(0.764089913489702,
                               0.249846234749099,
                               0.4838075020954)
            )
  expect_equal(pred1, true)

  # if you pass `newdata` identical to the original test data
  # should return the same
  expect_equal(
    calc_predictions(kknn, newdata = NULL),
    calc_predictions(kknn, newdata = test)
  )

  # if you pass "new" `newdata` model refits and returns new predictions
  expect_equal(
    calc_predictions(kknn, newdata = head(test, 1L)), # single sample
    head(true, 1L)
  )

  # with cutoff to switch class prediction
  pred2 <- calc_predictions(kknn, cutoff = 0.48)
  expect_equal(pred2, tibble(pred_class = c("virginica", "setosa", "virginica"),
                        prob_setosa = c(0.235910086510298,
                                        0.750153765250901,
                                        0.5161924979046),
                        prob_virginica = c(0.764089913489702,
                                           0.249846234749099,
                                           0.4838075020954)
                      )
  )

  # this warning mimics if the user passes an actual `kknn` object,
  # without using `fit_kknn()` ... predictions will be from the object itself
  kknn2 <- kknn
  kknn2$train <- NULL
  expect_warning(
    # no train data triggers warning; returns orig test predictions
    # test data ignored after warning
    foo <- calc_predictions(kknn2, newdata = test),
    "Cannot pass `newdata` with standard `kknn` class objects."
  )
  expect_equal(pred1, foo)
})
