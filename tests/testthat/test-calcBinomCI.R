
test_that("a single value returns correct binomial limits", {
  a <- calcBinomCI(0.8, 20)     # default 95% ci
  b <- calcBinomCI(0.45, 20)    # default 95% ci
  expect_equal(a, tibble::tibble(lower = 0.5999634477, upper = 1.0000000))
  expect_equal(b, tibble::tibble(lower = 0.2012076794, upper = 0.69879232))
})

test_that("the vectorized form also works", {
  ci <- calcBinomCI(seq(0, 1, length.out = 9L), 20)
  expect_equal(
    ci,
    tibble::tibble(lower = c(0.000000000, 0.000000000, 0.033454080,
                             0.132894301, 0.249954310, 0.382894301,
                             0.533454080, 0.709610322, 1.000000000),
                   upper = c(0.000000000, 0.290389678, 0.466545920,
                             0.617105699, 0.750045690, 0.867105699,
                             0.966545920, 1.000000000, 1.000000000))
  )
})

test_that("the trap for invalid `ci` values works", {
  expect_error(
    calcBinomCI(0.8, 20, ci = 1.1),
    "Invalid confidence interval value"
  )
  expect_error(
    calcBinomCI(0.5, 20, ci = 0.25),
    "Invalid confidence interval value"
  )
})

test_that("the thresholding works, setting values in [0, 1]", {
  x <- calcBinomCI(runif(100), 50)
  expect_equal(dim(x), c(100, 2))
  expect_s3_class(x, "tbl_df")
  expect_true(max(x$upper) <= 1L)
  expect_true(min(x$lower) >= 0)
})
