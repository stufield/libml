
# Setup ----
fit <- fitGLM(Response ~ ., data = fake_iris)

# Testing ----
test_that("the `fitGLM` formula method returns correct model", {
  expect_s3_class(fit, "glm")
  expect_named(fit,
         c("coefficients",      "residuals", "fitted.values", "effects",
           "R",                 "rank",      "qr",            "family",
           "linear.predictors", "deviance",  "aic",           "null.deviance",
           "iter",              "weights",   "prior.weights", "df.residual",
           "df.null",           "y",         "converged",     "boundary",
           "model",             "call",      "formula",       "terms",
           "data",              "offset",    "control",       "method",
           "contrasts",         "xlevels",   "classes"))
  expect_true("classes" %in% names(fit))   # this is added
  expect_named(fit$y, rownames(fake_iris))
  expect_equal(fit$data, fake_iris)
  expect_equal(fit$coefficients,
               c("(Intercept)" = -1.89320797887094,
                 Sepal.Length  = 0.52919531104304,
                   Sepal.Width = -0.58025558399033,
                  Petal.Length = 0.24041493147072,
                  Petal.Width  = -0.10747879390644))

  expect_equal(fit$classes, c("setosa", "virginica"))
  expect_equal(fit$formula, as.formula("Response ~ ."), ignore_attr = TRUE)
  expect_equal(fit$method, "glm.fit")
  expect_equal(fit$rank, 5)
  expect_equal(c(table(fit$y)), c("0" = 50, "1" = 50))
})


test_that("all `fitGLM` methods return identical results", {
  # pass 'tr_data'
  a <- fitGLM(fake_iris)                  # assume "Response" is present
  b <- fitGLM(fake_iris, y = "Response")  # pass string containing class names
  # pass 'tbl_df';  pass vector of class names
  # strip grouping variable 'Response'
  c <- fitGLM(fake_iris[, -5], y = fake_iris$Response)
  # pass stripped 'matrix'
  d <- fitGLM(as.matrix(fake_iris[, -5], rownames.force = FALSE),  # propagate rn
              y = fake_iris$Response)
  expect_equal(fit, a, ignore_formula_env = TRUE) # .Environment attributes differ
  expect_equal(fit, b, ignore_formula_env = TRUE) # .Environment attributes differ
  expect_equal(fit, c, ignore_attr = TRUE)        # input data differs
  expect_equal(fit, d, ignore_attr = TRUE)        # input data differs
})
