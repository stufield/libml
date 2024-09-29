
# Setup ----
lett <- LETTERS[1:4]
#                                       A     B     C     D
v <- withr::with_seed(101, rnorm(40, c(1000, 1200, 1100, 1050), sd = 100))
g <- factor(rep(lett, 10))
# boxplot(split(v, g))    # nolint: commented_code_linter.


# Testing ----
# `mackwolfe()` ----
test_that("the `missing(x)` runs the Hollander & Wolfe example", {
  mw <- mackwolfe()
  expect_s3_class(mw, "mack_wolfe")
  expect_equal(unclass(mw), list(Ap      = 157,
                                 Astar   = 4.1848182035888,
                                 n       = 26,
                                 p.value = 2.85394411251042e-05,
                                 Acrit   = 1.64485362695147,
                                 alpha   = 0.05,
                                 groups  = c("Jan-Feb", "Mar-Apr", "May-Jun",
                                             "Jul-Aug", "Sep-Oct", "Nov-Dec"),
                                 peak    = "Jul-Aug | k = 4"))
})

# Unknown `mackwolfe()` ----
test_that("peak unknown with true peak at 'B'", {
  mw <- mackwolfe(v, g)            # peak unknown
  expect_s3_class(mw, "mack_wolfe")
  expect_equal(unclass(mw), list(Ap      = NA,
                                 Astar   = 3.5795716689757,
                                 n       = 40,
                                 p.value = 0.00034415785384659,
                                 Acrit   = 1.6448536269515,
                                 alpha   = 0.05,
                                 groups  = lett,
                                 peak    = "B | k = 2"))
  # Print method
  expect_snapshot_output(mw)
})

 # Known `mackwolfe()` ----
test_that("`mackwolfe()` with peak known", {
  mw <- mackwolfe(v, g, peak = "B")   # peak known
  expect_s3_class(mw, "mack_wolfe")
  expect_equal(unclass(mw), list(Ap      = 324,
                                 Astar   = 3.5795716689757,
                                 n       = 40,
                                 p.value = 0.00034415785384659,
                                 Acrit   = 1.6448536269515,
                                 alpha   = 0.05,
                                 groups  = lett,
                                 peak    = "B | k = 2"))
  # Print method
  expect_snapshot_output(mw)
})

# MW with rm outliers ----
test_that("`mackwolfe()` generates the expected list output when `rm.outliers = TRUE`", {
  v[c(10, 20)] <- 25000   # create 2 outliers

  expect_warning(
    mwo <- mackwolfe(v, group = g, peak = "B", rm.outliers = TRUE),
    "Outliers removed during analysis ... 2", fixed = TRUE
  )

  expect_s3_class(mwo, "mack_wolfe")
  expect_equal(unclass(mwo), list(Ap      = 277,
                                  Astar   = 3.2125240144552,
                                  n       = length(v) - 2,   # 2 outliers rm
                                  p.value = 0.0013157414824197,
                                  Acrit   = 1.64485362695147,
                                  alpha   = 0.05,
                                  groups  = lett,
                                  peak    = "B | k = 2"))
  # Print method
  expect_snapshot_output(mwo)
})

test_that("`mackwolfe()` peak unknown doesn't do permutation p-values (ignored)", {
  a <- mackwolfe(v, g)
  b <- mackwolfe(v, g, nperm = 1000)  # `nperm` ignored
  expect_identical(a, b)              # identical
})

# p-value permutation ----
test_that("`mackwolfe()` peak known with permutation p-values", {
  withr::local_options(list(signal.quiet = TRUE))
  # permutations need a stable seed (no outside seeds)
  x <- withr::with_seed(1, mackwolfe(v, g, peak = "B", nperm = 1000))
  expect_equal(x$p.value, 0)
  y <- mackwolfe(v, g, peak = "B")
  # x,y identical except for p-values; rest is tested above
  expect_equal(x[-4L], y[-4L])
})
