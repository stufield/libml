
# AUC internals ----
# calcTrap_cpp() ----
test_that("calcTrap() returns correct area", {
  expect_equal(calcTrap_cpp(cbind(c(0, 0.5), c(0, 0.5))), 0.125)
  expect_equal(calcTrap_cpp(cbind(c(0, 1), c(0, 1))), 0.5)
  expect_equal(calcTrap_cpp(cbind(c(0, 1), c(1, 0))), 0.5)
  expect_equal(calcTrap_cpp(cbind(c(0.5, 1), c(0.5, 1))), 0.375)
  expect_equal(calcTrap_cpp(cbind(c(0, 0.5), c(0.5, 1))), 0.375)
  expect_equal(calcTrap_cpp(cbind(c(0, 1), c(0.5, 1))), 0.75)
  expect_equal(calcTrap_cpp(cbind(c(1, 0.5), c(0.5, 0))), 0.125)
  expect_equal(calcTrap_cpp(cbind(c(0, 1), c(1, 1))), 1)          # 1.0 AUC
  expect_equal(calcTrap_cpp(cbind(c(0, 0.9), c(0.9, 1))), 0.855)
  expect_equal(calcTrap_cpp(cbind(c(0, 0.1), c(0.9, 1))), 0.095)
  # random pts
  m1 <- withr::with_seed(1, matrix(runif(4), ncol = 2))
  m2 <- withr::with_seed(99, matrix(runif(4), ncol = 2))
  expect_equal(calcTrap_cpp(m1), 0.078951842563577)
  expect_equal(calcTrap_cpp(m2), 0.39482162492074)
})

test_that("calcTrap() trips errors if `x` matrix if 2x2 not passed", {
  m <- matrix(runif(6), ncol = 2)
  expect_error(calcTrap_cpp(m),
               "'x' must be a 2x2 numeric matrix, dim(x) = 3x2", fixed = TRUE)
  m <- matrix(runif(6), ncol = 3)
  expect_error(calcTrap_cpp(m),
               "'x' must be a 2x2 numeric matrix, dim(x) = 2x3", fixed = TRUE)
  expect_error(calcTrap_cpp(1), "Not a matrix.")
  expect_error(calcTrap_cpp(1L), "Not a matrix.")
  expect_error(calcTrap_cpp(1.5), "Not a matrix.")
})

# empAUC_cpp() ----
test_that("empAUC_cpp() trips errors if `x` matrix if ncol != 2", {
  expect_error(empAUC_cpp(matrix(runif(6), ncol = 3)),
               "'xy' must be a 2x2 numeric matrix (ncol = 3)", fixed = TRUE)
  expect_error(empAUC_cpp(matrix(runif(6), ncol = 2)), NA)  # expect no error
})

test_that("empAUC_cpp() is the same as calcTrap_cpp() for 2x2 matrix", {
  x <- cbind(c(0, 1), c(0, 1))
  expect_equal(calcTrap_cpp(x), empAUC_cpp(x))
  m <- withr::with_seed(3, matrix(runif(4), ncol = 2))   # random pts
  expect_equal(calcTrap_cpp(m), empAUC_cpp(m))
})

test_that("empAUC_cpp() returns the expected values", {
  m <- withr::with_seed(1, matrix(runif(80), ncol = 2))
  # must order matrix by `x` so points are increasing left -> right on the ROC
  m <- m[order(m[, 1]), ]
  expect_equal(empAUC_cpp(m), 0.54289844487084)
})
