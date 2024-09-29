
# Setup ----
n  <- 6
df <- withr::with_seed(22,
        data.frame(
          true = sample(c("control", "disease"), n, replace = TRUE),
          pred = runif(n)
        ))


# Testing ----
test_that("`getROCxy()` generates expected output", {
  expect_equal(getROCxy(df$true, df$pred, "disease"),
               cbind(x = c(0, 0, 1, 1, 1, 1, 1),
                     y = c(0, 0.2, 0.2, 0.4, 0.6, 0.8, 1))
  )

  # test linear interpolation for all cases with equal prob
  expect_equal(getROCxy(df$true[1:5L], rep(0.5, 5L), "disease"),
               cbind(x = c(0, 0.2, 0.4, 0.6, 0.8, 1.0),
                     y = c(0, 0.2, 0.4, 0.6, 0.8, 1.0))
  )

  # test linear interpolation for some cases with equal prob
  # 1st  point is (1/3, 0)
  # last point is (2/3, 1)
  # dx is 1/3 over 3 pts
  # dy is 1 over 3 pts
  expect_equal(getROCxy(c("a", "d", "a", "d", "a"), c(0.4, 0.5, 0.5, 0.5, 0.6), "d"),
               cbind(x = c(0.0, 1.0 / 3.0,
                           1.0 / 3.0 + 1.0 / 9.0,
                           1.0 / 3.0 + 2.0 / 9.0,
                           1.0 / 3.0 + 3.0 / 9.0,
                           1.0),
                     y = c(0.0, 0.0, 1.0 / 3.0, 2.0 / 3.0, 3.0 / 3.0, 1.0))
  )
})

test_that("`getROCxy()` generates correct 2-sample edge case output", {
  expect_equal(
    getROCxy(c("a", "b"), c(0.1, 0.9), "b"),
    cbind(x = c(0, 0, 1), y = c(0, 1, 1))
  )
  expect_equal(
    getROCxy(c("a", "b"), c(0.2, 0.2), "b"),    # tied (unit line)
    cbind(x = c(0, 0.5, 1), y = c(0, 0.5, 1))
  )
})

test_that("`getROCxy()` doesn't matter what probs are with all ties", {
  n <- 6L   # n must be even integer
  expect_equal(
    getROCxy(rep(c("a", "b"), n / 2), rep(0.1, n), "b"),
    getROCxy(rep(c("a", "b"), each = n / 2), rep(0.3, n), "b")
  )
})

test_that("`getROCxy()` generates correct output for edge cases and ties", {
  classes <- c("disease", "disease", "control", "control")
  pred <- c(0.9, 0.9, 0.2, 0.2)   # ordered decreasing; tie within class
  expect_equal(getROCxy(classes, pred, "disease"),
               cbind(x = c(0, 0, 0, 0.5, 1),
                     y = c(0, 0.5, 1.0, 1.0, 1.0))
  )
  pred <- c(0.9, 0.5, 0.5, 0.2)   # decreasing; tie and switch class; 1/2 step
  expect_equal(getROCxy(classes, pred, "disease"),
               cbind(x = c(0, 0, 0.25, 0.5, 1),
                     y = c(0, 0.5, 0.75, 1.0, 1.0))
  )
})

test_that("`getROCxy()` trips correct errors", {
  expect_error(
    getROCxy("case", 0.1, "case"),
    "Class labels are not binary. All disease? All control? 3 or more classes?",
    fixed = TRUE
  )
  expect_error(
    getROCxy(df$true, df$pred, "diseaseeeeee"),
    "pos.class %in% truth is not TRUE",
  )
  expect_error(
    getROCxy(df$true,  df$pred[-1L], "disease"),
    "length(truth) == length(predicted) is not TRUE",
    fixed = TRUE
  )
})

test_that("`getROCxy()` trips correct warning", {
  x <- c(0, 1, 0, 1, 1, 1, 0)
  y <- c(0.001, 0.999, 0.001, 0.999, 0.999, 0.999, 0.001)
  expect_warning(
    a <- getROCxy(x, y, 1), NA     # no warning; types match (double)
  )
  expect_warning(
    b <- getROCxy(x, y, 1L),       # warning; double vs integer
    "You are passing un-matched types: truth = 'double' vs. pos.class = 'integer'"
  )
  expect_warning(
    z <- getROCxy(x, y, "1"),       # warning; double vs character
    "You are passing un-matched types: truth = 'double' vs. pos.class = 'character'"
  )

  # expect NO warning; special case; factor type matched with character type
  expect_warning(
    j <- getROCxy(factor(df$true), df$pred, "control"), NA
  )
  expect_equal(a, b)
  expect_equal(a, z)
})

test_that("`getROCxy()` more edge cases", {
  pred <- c(0.8, 0.7, 0.6, 0.5, 0.4)
  true <- c(1L, 1L, 1L, 0L, 0L) # integer
  mat  <- cbind(c(0, 0, 0, 0, 0.5, 1.0), c(0.0, 1 / 3, 2 / 3, 1.0, 1.0, 1.0))
  colnames(mat) <- c("x", "y")
  # true (integer) vs pos.class (double)
  expect_warning(x <- getROCxy(true, pred, 1.0), "integer.*double")
  expect_equal(x, mat)
  expect_warning(x <- getROCxy(true, pred, "1"), "integer.*character")
  expect_equal(x, mat)
  true <- c(1, 1, 1, 0, 0)      # double
  expect_warning(x <- getROCxy(true, pred, 1L),   # double vs integer
                 "double.*integer")
  expect_equal(x, mat)
  expect_warning(x <- getROCxy(true, pred, "1"),  # double vs character
                 "double.*character")
  expect_equal(x, mat)
  expect_warning(x <- getROCxy(true, pred, 1), NA) # no warning
  expect_equal(x, mat)
  expect_warning(x <- getROCxy(as.integer(true), pred, 1L), NA) # no warning
  expect_equal(x, mat)
})
