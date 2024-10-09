
# Setup ----
fit <- fit_logistic(tr_iris)   # tr_data S3 method

# Testing ----
test_that("the `fit_logistic()` formula method returns correct model", {
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
  expect_named(fit$y, rownames(tr_iris))
  expect_equal(fit$data, tr_iris)
  expect_equal(fit$coefficients,
               c("(Intercept)" = -1.89320797887094,
                 Sepal.Length  = 0.52919531104304,
                   Sepal.Width = -0.58025558399033,
                  Petal.Length = 0.24041493147072,
                  Petal.Width  = -0.10747879390644))

  expect_equal(fit$classes, c("setosa", "virginica"))
  expect_equal(fit$formula, as.formula("Species ~ ."), ignore_attr = TRUE)
  expect_equal(fit$method, "glm.fit")
  expect_equal(fit$rank, 5)
  expect_equal(c(table(fit$y)), c("0" = 50, "1" = 50))
})


test_that("all `fit_logistic()` methods return identical results", {
  # pass 'tr_data'
  a <- fit_logistic(tr_iris)                             # tr_data object
  b <- fit_logistic(data.frame(tr_iris), y = "Species")  # pass string
  # pass 'tbl_df';  pass vector of class names
  # strip grouping variable 'Response'
  c <- fit_logistic(data.frame(tr_iris[, -5L]), y = tr_iris$Species)
  # pass stripped 'matrix'
  d <- fit_logistic(as.matrix(tr_iris[, -5L], rownames.force = FALSE),  # propagate rn
                    y = tr_iris$Species)
  # for below comparisons, some elements we do not check
  # .Environment attributes may differ
  # input data differs; data.frame, tr_data, matrix, etc.
  skip <- c(23, 24)  # these are formulae; differ in `Species ~ .` or `y ~ .`
  expect_equal(fit, a, ignore_formula_env = TRUE)
  expect_equal(fit, b, ignore_formula_env = TRUE, ignore_attr = TRUE)
  expect_equal(fit[-skip], c[-skip], ignore_attr = TRUE)
  expect_equal(fit[-skip], d[-skip], ignore_attr = TRUE)
})
