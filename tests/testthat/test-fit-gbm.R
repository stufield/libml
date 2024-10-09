
# Setup ----
model <- withr::with_seed(10, {
  fit_gbm(tr_iris[, -5L], y = tr_iris$Species, distribution = "bernoulli")
})

# Formula syntax
model_form <- withr::with_seed(10, {
  fit_gbm(Species ~ ., data = tr_iris, distribution = "bernoulli")
})

# Testing ----
test_that("`fit_gbm()` returns the corrrect object", {
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
  expect_equal(model$response.name, "y")
  expect_equal(model$shrinkage, 0.1)
  expect_equal(lengths(model$var.levels, use.names = FALSE), c(11L, 11L, 11L, 11L))
  expect_equal(model$var.monotone, rep(0, 4))
  expect_true(all(model$var.names %in% names(tr_iris)))
  expect_equal(model$var.type,  rep(0, 4))
  expect_false(model$verbose)
  expect_equal(model$cv.folds, 0)
  expect_equal(unname(model$class), tr_iris$Species)
})

test_that("`fit_gbm()` formula and default methods are identical", {
  # 'y' and 'Species' will differ in calls and formulae
  skip_nms <- c("response.name", "Terms", "call", "m")
  skip <- which(names(model) %in% skip_nms)
  expect_equal(model[-skip], model_form[-skip], ignore_formula_env = TRUE)
  expect_equal(model_form$response.name, "Species")
})
