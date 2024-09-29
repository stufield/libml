
# Setup ----
model <- withr::with_seed(10, {
  fitGBM(fake_iris[, -5], y = fake_iris$Response, distribution = "bernoulli")
})

# Formula syntax
form <- withr::with_seed(10, {
  fitGBM(Response ~ ., data = fake_iris, distribution = "bernoulli")
})

# Testing ----
test_that("fitGBM() returns the corrrect object", {
  expect_s3_class(model, "gbm")
  expect_equal(model$initF, 0)
  expect_equal(sum(model$fit), -4.2665040880244)
  expect_equal(sum(model$train.error), 101.89579450507)
  expect_equal(sum(model$oobag.improve), -0.2973498614618)
  expect_equal(model$bag.fraction, 0.5)
  expect_equal(model$distribution, list(name = "bernoulli"))
  expect_equal(model$interaction.depth, 1)
  expect_equal(model$n.minobsinnode, 10)
  expect_equal(model$num.classes, 1)
  expect_equal(model$n.trees, 100)
  expect_equal(model$nTrain, 100)
  expect_equal(model$train.fraction, 1)
  expect_equal(model$response.name, "Response")
  expect_equal(model$shrinkage, 0.1)
  expect_equal(lengths(model$var.levels, use.names = FALSE), c(11L, 11L, 11L, 11L))
  expect_equal(model$var.monotone, rep(0, 4))
  expect_equal(model$var.names, setdiff(names(fake_iris), model$response.name))
  expect_equal(model$var.type,  rep(0, 4))
  expect_false(model$verbose)
  expect_equal(model$cv.folds, 0)
  expect_equal(unname(model$class), fake_iris$Response)
})

test_that("fitGBM() formula and default methods are identical", {
  # attributes of Terms contain different envs
  expect_equal(model, form, ignore_formula_env = TRUE)
})
