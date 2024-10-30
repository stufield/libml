
# Setup ----
lett <- LETTERS[1:4L]
#                                       A     B     C     D
v <- withr::with_seed(101, rnorm(40, c(1000, 1200, 1100, 1050), sd = 100))
g <- factor(rep(lett, 10))


# Testing ----
# `mack_wolfe()` ----
test_that("the default S3 method runs the Hollander & Wolfe example", {
  default <- mack_wolfe()
  expect_s3_class(default, "mack_wolfe")
  expect_equal(unclass(default),
               list(Ap      = 157,
                    Astar   = 4.1848182035888,
                    n       = 26,
                    p_value = 2.85394411251042e-05,
                    Acrit   = 1.64485362695147,
                    alpha   = 0.05,
                    groups  = c("Jan-Feb", "Mar-Apr", "May-Jun",
                                "Jul-Aug", "Sep-Oct", "Nov-Dec"),
                    peak    = "Jul-Aug | k = 4"))
})

# Known `mack_wolfe()` ----
test_that("`mack_wolfe()` returns correctly with peak known at 'B'", {
  mw <- mack_wolfe(v, g, peak = "B")   # peak known
  expect_s3_class(mw, "mack_wolfe")
  expect_equal(unclass(mw),
               list(Ap      = 324,
                    Astar   = 3.5795716689757,
                    n       = 40,
                    p_value = 0.00034415785384659,
                    Acrit   = 1.6448536269515,
                    alpha   = 0.05,
                    groups  = lett,
                    peak    = "B | k = 2"))
  expect_snapshot_output(mw)   # print method
})

# Unknown `mack_wolfe()` ----
test_that("`mack_wolfe()` with peak *unknown* and a true peak at 'B'", {
  mw <- mack_wolfe(v, g, peak = NULL) # peak unknown
  expect_s3_class(mw, "mack_wolfe")
  expect_equal(unclass(mw),
               list(Ap      = NA_integer_,
                    Astar   = 3.5795716689757,
                    n       = 40,
                    p_value = 0.00034415785384659,
                    Acrit   = 1.6448536269515,
                    alpha   = 0.05,
                    groups  = lett,
                    peak    = "B | k = 2"))
  expect_snapshot_output(mw) # print method
})

test_that("`mack_wolfe()` with peak at the end (JT)", {
  mw_jt <- mack_wolfe(v, g, peak = "jt")
  expect_s3_class(mw_jt, "mack_wolfe")
  expect_equal(unclass(mw_jt),
               list(Ap      = 258,
                    Astar   = -1.01369266,
                    n       = 40,
                    p_value = 0.31072943,
                    Acrit   = 1.644853626,
                    alpha   = 0.05,
                    groups  = lett,
                    peak    = "D | k = 4"))
})

# rm outliers ----
test_that("`mack_wolfe()` generates the expected output when `rm_outliers = TRUE`", {
  # create 2 outliers
  v[c(10L, 20L)] <- 25000

  expect_warning(
    mwo <- mack_wolfe(v, group = g, peak = "B", rm_outliers = TRUE),
    "Outliers removed during analysis ... 2", fixed = TRUE
  )

  expect_s3_class(mwo, "mack_wolfe")
  expect_equal(unclass(mwo),
               list(Ap      = 277,
                    Astar   = 3.2125240144552,
                    n       = length(v) - 2L,   # 2 outliers rm
                    p_value = 0.0013157414824197,
                    Acrit   = 1.64485362695147,
                    alpha   = 0.05,
                    groups  = lett,
                    peak    = "B | k = 2"))
  expect_snapshot_output(mwo) # print method
})

test_that("`mack_wolfe()` peak unknown doesn't do permutation p-values (ignored)", {
  a <- mack_wolfe(v, g, peak = NULL)
  b <- mack_wolfe(v, g, peak = NULL, nperm = 1000)  # `nperm` ignored
  expect_identical(a, b)
})

# p-value permutation ----
test_that("`mack_wolfe()` peak known with permutation p-values", {
  withr::local_options(list(signal.quiet = TRUE))
  # permutations need a stable seed (no outside seeds)
  x <- withr::with_seed(1, mack_wolfe(v, g, peak = "B", nperm = 100L))
  expect_equal(x$p_value, 0)
  y <- mack_wolfe(v, g, peak = "B")
  # x,y identical except for p-values
  # rest is tested above
  idx <- which(names(x) == "p_value")
  idy <- which(names(y) == "p_value")
  expect_equal(x[-idx], y[-idy])
})

test_that("`mack_wolfe()` formula interface produced identical output", {
  a  <- mack_wolfe(v, g, peak = "B")
  df <- data.frame(v = v, g = g)
  b  <- mack_wolfe(v ~ g, data = df, peak = "B")
  expect_identical(a, b)
})
