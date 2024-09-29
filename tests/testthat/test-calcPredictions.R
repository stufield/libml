
# Setup ----
# Uses `fake_iris` training data set object from iris data set
train <- head(fake_iris, -3L)
test  <- tail(fake_iris, 3L)


# Testing ----
test_that("the logistic regression (GLM) method returns correct predictions", {
  # Logistic Regression
  lr <- fitGLM(Response ~ ., data = train)
  pred1 <- calcPredictions(lr, test)
  expect_false(has_rn(pred1))
  expect_equal(pred1,
    data.frame(stringsAsFactors = FALSE,
      pred_class = c("virginica", "setosa", "setosa"),
      pred_linear = c(1.78167792472932, -0.609193148994239, -1.27204605039852),
      prob_setosa = c(0.144096068014264, 0.647756726495939, 0.781092796804913),
      prob_virginica = c(0.855903931985736, 0.352243273504061, 0.218907203195087)
    )
  )
  # with cutoff to switch class prediction
  pred2 <- calcPredictions(lr, test, cutoff = 0.33)
  expect_equal(pred2,
    data.frame(stringsAsFactors = FALSE,
      pred_class = c("virginica", "virginica", "setosa"),
      pred_linear = c(1.78167792472932, -0.609193148994239, -1.27204605039852),
      prob_setosa = c(0.144096068014264, 0.647756726495939, 0.781092796804913),
      prob_virginica = c(0.855903931985736, 0.352243273504061, 0.218907203195087)
    )
  )
})

test_that("the Naive Bayes method returns correct predictions", {
  nb <- robustNaiveBayes(Response ~ ., data = train)
  pred1 <- calcPredictions(nb, test)
  expect_false(has_rn(pred1))
  expect_equal(pred1,
    data.frame(stringsAsFactors = FALSE,
      pred_class = c("virginica", "setosa", "setosa"),
      prob_setosa = c(2.94243132997378e-05, 0.983414967907472, 0.999945042516105),
      prob_virginica = c(0.9999705756867, 0.016585032092528, 5.49574838953107e-05)
    )
  )
  # with cutoff to switch class prediction
  pred2 <- calcPredictions(nb, tail(fake_iris, 3L), cutoff = 0.01)
  expect_equal(pred2,
    data.frame(stringsAsFactors = FALSE,
      pred_class = c("virginica", "virginica", "setosa"),
      prob_setosa = c(2.94243132997378e-05, 0.983414967907472, 0.999945042516105),
      prob_virginica = c(0.9999705756867, 0.016585032092528, 5.49574838953107e-05)
    )
  )
})

test_that("the Random Forest method returns correct out-of-bag predictions", {
  rf <- withr::with_seed(101,
          randomForest::randomForest(Response ~ ., data = train,
                                     importance = TRUE,
                                     proximity = TRUE, keep.inbag = TRUE)
  )
  pred1 <- calcPredictions(rf, NULL)                # out-of-bag
  expect_false(has_rn(pred1))
  # there are 97 out-of-bag samples; just test summaries
  expect_equal(c(table(pred1$pred_class)), c(setosa = 50, virginica = 47))
  expect_equal(sum(pred1$prob_setosa), 49.270947975713)
  expect_equal(sum(pred1$prob_virginica), 47.729052024287)
})

test_that("the Random Forest method returns correct predictions with test data", {
  rf <- withr::with_seed(999,
          randomForest::randomForest(Response ~ ., data = train,
                                     importance = TRUE,
                                     proximity = TRUE, keep.inbag = TRUE)
  )
  # with test data
  pred1 <- calcPredictions(rf, test)
  expect_false(has_rn(pred1))
  expect_equal(pred1, data.frame(stringsAsFactors = FALSE,
                        pred_class = c("virginica", "setosa", "setosa"),
                        prob_setosa    = c(0.27, 0.606, 0.812),
                        prob_virginica = c(0.73, 0.394, 0.188)
                      )
  )
  # with cutoff to switch class prediction
  pred2 <- calcPredictions(rf, test, cutoff = 0.39)
  expect_equal(pred2, data.frame(stringsAsFactors = FALSE,
                        pred_class = c("virginica", "virginica", "setosa"),
                        prob_setosa    = c(0.27, 0.606, 0.812),
                        prob_virginica = c(0.73, 0.394, 0.188)
                      )
  )
})

test_that("the General Boosted Regression (GBM) returns correct predictions", {
  gb <- withr::with_seed(101, fitGBM(Response ~ ., data = train,
                                     distribution = "bernoulli"))
  pred1 <- calcPredictions(gb, test)
  expect_false(has_rn(pred1))
  expect_equal(pred1, data.frame(stringsAsFactors = FALSE,
                         pred_class = c("virginica", "setosa", "setosa"),
                        prob_setosa = c(0.15781951638483,
                                        0.503400655494596,
                                        0.806205501737701),
                     prob_virginica = c(0.84218048361517,
                                        0.496599344505404,
                                        0.193794498262298)
                     )
  )
  # with cutoff to switch class prediction
  pred2 <- calcPredictions(gb, test, 0.48)
  expect_equal(pred2, data.frame(stringsAsFactors = FALSE,
                        pred_class  = c("virginica", "virginica", "setosa"),
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
          e1071::svm(Response ~ ., data = train, probability = TRUE)
        )
  pred1 <- calcPredictions(sm, test)
  expect_false(has_rn(pred1))
  expect_equal(pred1, data.frame(stringsAsFactors = FALSE,
                        pred_class  = c("virginica", "setosa", "setosa"),
                        prob_setosa = c(0.194761910287786,
                                        0.647758225687972,
                                        0.7504834840278),
                        prob_virginica = c(0.805238089712214,
                                           0.352241774312028,
                                           0.2495165159722)
                      )
  )
  # with cutoff to switch class prediction
  pred2 <- calcPredictions(sm, test, 0.35)
  expect_equal(pred2, data.frame(stringsAsFactors = FALSE,
                        pred_class  = c("virginica", "virginica", "setosa"),
                        prob_setosa = c(0.194761910287786,
                                        0.647758225687972,
                                        0.7504834840278),
                        prob_virginica = c(0.805238089712214,
                                           0.352241774312028,
                                           0.2495165159722)
                      )
  )
})

test_that("the KKNN method returns correct predictions", {
  # test set passed in during model fit
  kknn  <- fitKKNN(Response ~ ., train = train, test = test, K = 10)
  pred1 <- calcPredictions(kknn)  # cannot pass test data
  expect_false(has_rn(pred1))
  expect_equal(pred1, data.frame(stringsAsFactors = FALSE,
                        pred_class = c("virginica", "setosa", "setosa"),
                        prob_setosa = c(0.235910086510298,
                                        0.750153765250901,
                                        0.5161924979046),
                        prob_virginica = c(0.764089913489702,
                                           0.249846234749099,
                                           0.4838075020954)
                      )
  )
  expect_warning(
    foo <- calcPredictions(kknn, test),  # test data triggers warning
    paste0("KKNN models differ from other class models.\n",
           "Test predictions are built into the model object.")
  )
  expect_equal(pred1, foo)   # test data should be ignored after warning

  # with cutoff to switch class prediction
  pred2 <- calcPredictions(kknn, cutoff = 0.48)
  expect_equal(pred2, data.frame(stringsAsFactors = FALSE,
                        pred_class = c("virginica", "setosa", "virginica"),
                        prob_setosa = c(0.235910086510298,
                                        0.750153765250901,
                                        0.5161924979046),
                        prob_virginica = c(0.764089913489702,
                                           0.249846234749099,
                                           0.4838075020954)
                      )
  )
})
