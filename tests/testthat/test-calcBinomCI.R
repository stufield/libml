
test_that("a single value returns correct binomial limits", {
  a <- calcBinomCI(0.8, 20)     # default 95% ci
  b <- calcBinomCI(0.45, 20)    # default 95% ci
  expect_s3_class(a, "data.frame")
  expect_s3_class(b, "data.frame")
  expect_equal(dim(a), c(1, 2))
  expect_equal(dim(b), c(1, 2))
  expect_named(a, c("lower", "upper"))
  expect_named(b, c("lower", "upper"))
  expect_equal(as.numeric(a), c(0.5999634, 1.0000000), tolerance = 1e-06)
  expect_equal(as.numeric(b), c(0.2012077, 0.6987923), tolerance = 1e-06)
})

test_that("the vectorized form also works", {
  c_ <- calcBinomCI(seq(0, 1, length.out = 9), 20)
  expect_s3_class(c_, "data.frame")
  expect_equal(dim(c_), c(9, 2))
  expect_named(c_, c("lower", "upper"))
  expect_equal(c_, data.frame(lower = c(0.000000000, 0.000000000, 0.033454080,
                                        0.132894301, 0.249954310, 0.382894301,
                                        0.533454080, 0.709610322, 1.000000000),
                              upper = c(0.000000000, 0.290389678, 0.466545920,
                                        0.617105699, 0.750045690, 0.867105699,
                                        0.966545920, 1.000000000, 1.000000000)),
                              tolerance = 1e-06)
})

test_that("the trap for invalie `ci` values works", {
  expect_error(
    calcBinomCI(0.8, 20, ci = 1.1)
    )
  expect_error(
    calcBinomCI(0.5, 20, ci = 0.25)
    )
})

test_that("the thresholding works, setting values in [0, 1]", {
  x <- calcBinomCI(runif(100), 50)
  expect_equal(dim(x), c(100, 2))
  expect_s3_class(x, "data.frame")
  expect_true(max(x$upper) <= 1L)
  expect_true(min(x$lower) >= 0)
})
