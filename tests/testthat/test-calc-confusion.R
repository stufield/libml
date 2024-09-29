
# Setup ----
# set local seed for this testing context
# so that external seeds don't interfere with
# sampling within tests for this scope
withr::local_seed(123)

true <- c("control", "control", "disease", "disease", "disease", "disease",
          "disease", "disease", "control", "control", "disease", "disease",
          "control", "disease", "control", "control", "control", "control",
          "disease", "control")

pred <- c(0.222461252938956, 0.360352846328169, 0.532661496894434,
          0.796469530789182, 0.771267712814733, 0.922611774411052,
          0.466519388137385, 0.996413280023262, 0.213919642847031,
          0.214762558462098, 0.178224225528538, 0.258298496948555,
          0.805535813327879, 0.164836287265643, 0.977408259175718,
          0.0357247716747224, 0.825505221495405, 0.0411458793096244,
          0.0530758206732571, 0.513491039630026)


# Testing ----
test_that("calc_conf traps and errors: `truth` must be character, integer, or factor", {
  n <- 10
  expect_error_free(calc_confusion(sample(0:1, n, replace = TRUE), runif(n), "1"))
  x <- sample(c("a", "b"), n, replace = TRUE)
  expect_error_free(calc_confusion(x, runif(n), "b"))
  expect_error_free(calc_confusion(factor(x), runif(n), "b"))
})

test_that("pos.class numeric or character when in `truth`", {
  x <- sample(0:1, 10, replace = TRUE)
  y <- runif(10)
  expect_equal(
    calc_confusion(x, y, "1"),
    calc_confusion(x, y, 1)
  )
  expect_equal(
    calc_confusion(factor(x), y, "1"),
    calc_confusion(factor(x), y, 1)
  )
})

test_that("calc_conf traps that `truth` & `predicted` must be same length", {
  expect_error(
    calc_confusion(0:1, runif(9)),
    "length(truth) == length(predicted) is not TRUE", fixed = TRUE
  )
})

test_that("calc_conf traps and errors: truth not binary", {
  true3 <- withr::with_seed(1, sample(letters[1:3L], length(true), replace = TRUE))
  expect_error(
    calc_confusion(true3, pred, "a"),
    "There do not appear to be a binary classes"
  )
})

test_that("calc_conf traps and errors: pos.class missing", {
  expect_error(
    calc_confusion(true, pred),
    "You must pass a `pos.class` argument specifying the event class."
  )
  # Also trips when truth is a factor
  expect_error(
    calc_confusion(factor(true), pred),
    "You must pass a `pos.class` argument specifying the event class."
  )
})

test_that("calc_conf traps and errors: `pos.class` not in `truth`", {
  expect_error(
    calc_confusion(true, pred, "event"),
    paste("Your choice of `pos.class` is not contained in `truth`.",
          "Please choose one of: 'control', 'disease'")
    )

})

test_that("calc_conf returns expected shape, dimensions, and values", {
  tbl <- calc_confusion(true, pred, "disease")
  expect_s3_class(tbl, "confusion_matrix")
  expect_s3_class(tbl, "table")
  expect_equal(dimnames(tbl), list(Truth = c("control", "disease"),
                                   Predicted = c("control", "disease")))
  expect_length(tbl, 4L)
  expect_equal(dim(tbl), c(2, 2))
  expect_equal(as.numeric(tbl), c(6L, 5L, 4L, 5L))
  # Reverse positive class = control
  tbl <- calc_confusion(true, pred, "control")   # by pos.class =
  expect_equal(as.numeric(tbl), c(5L, 6L, 5L, 4L))
})

test_that("calc_conf returns expected values at different cutoff", {
  tbl <- calc_confusion(true, pred, "disease", 0.25)
  expect_equal(as.numeric(tbl), c(5L, 3L, 5L, 7L))
  tbl <- calc_confusion(true, pred, "disease", 0.75)
  expect_equal(as.numeric(tbl), c(7L, 6L, 3L, 4L))
})

test_that("calc_conf ignores factor levels and uses pos.class argument", {
  f1 <- factor(true, levels = c("control", "disease"))
  f2 <- factor(true, levels = c("disease", "control"))
  c1 <- calc_confusion(f1, pred, "disease")
  c2 <- calc_confusion(f2, pred, "disease")
  expect_equal(c1, c2)
  # Reverse classes
  c1 <- calc_confusion(f1, pred, "control")
  c2 <- calc_confusion(f2, pred, "control")
  expect_equal(c1, c2)
})


# Summary ----
test_that("confusion matrix S3 summary method gives expected values; cutoff = 0.75", {
  sumry <- summary(calc_confusion(true, pred, pos.class = "disease", 0.75))
  expect_type(sumry, "list")
  expect_s3_class(sumry, "summary.confusion_matrix")
  expect_named(sumry, c("confusion", "metrics", "stats"))
  expect_equal(sumry$confusion,
               calc_confusion(factor(true), pred, pos.class = "disease", 0.75))
  expect_s3_class(sumry$metrics, "tbl_df")
  expect_equal(dim(sumry$metrics), c(8, 5))
  expect_named(sumry$metrics, c("metric", "n", "estimate",
                                "CI95_lower", "CI95_upper"))
  expect_equal(vapply(sumry$metrics, typeof, character(1)),
               c(metric     = "character",
                 n          = "integer",
                 estimate   = "double",
                 CI95_lower = "double",
                 CI95_upper = "double"))
  expect_equal(sumry$metrics$metric,
               c("Sensitivity",
                 "Specificity",
                 "PPV_Precision",
                 "NPV",
                 "Accuracy",
                 "Bal_Accuracy",
                 "Prevalence",
                 "MCC"))
  expect_equal(sumry$metrics$estimate, c(0.4000000000,
                                         0.7000000000,
                                         0.5714285714,
                                         0.5384615385,
                                         0.5500000000,
                                         0.5500000000,
                                         0.5000000000,
                                         0.1048284837))
  expect_equal(sumry$metrics$n, c(10, 10, 7, 13, 20, 20, 20, NA_integer_))
  expect_equal(sumry$metrics$CI95_lower, c(0.05352652806,
                                           0.37590374360,
                                           0.15310924434,
                                           0.22923697581,
                                           0.30120767938,
                                           0.30120767938,
                                           0.24995431,
                                           NA_integer_))
  expect_equal(sumry$metrics$CI95_upper, c(0.7464734719,
                                           1.0000000000,
                                           0.9897478985,
                                           0.8476861011,
                                           0.7987923206,
                                           0.7987923206,
                                           0.7500457,
                                           NA_integer_))
  # Print method
  expect_snapshot_output(sumry)
})
