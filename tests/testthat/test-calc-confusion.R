
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
  expect_no_error(
    calc_confusion(sample(0:1, n, replace = TRUE), runif(n), "1")
  )
  x <- sample(c("a", "b"), n, replace = TRUE)
  expect_no_error(calc_confusion(x, runif(n), "b"))
  expect_no_error(calc_confusion(factor(x), runif(n), "b"))
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
  expect_equal(dim(sumry$metrics), c(10L, 5L))
  expect_named(sumry$metrics, c("metric", "n", "estimate",
                                "CI95_lower", "CI95_upper"))
  expect_equal(vapply(sumry$metrics, typeof, character(1)),
               c(metric     = "character",
                 n          = "integer",
                 estimate   = "double",
                 CI95_lower = "double",
                 CI95_upper = "double"))

  x <- tibble::tibble(
    metric = c("Sensitivity",
               "Specificity",
               "PPV (Precision)",
               "NPV",
               "Accuracy",
               "Bal Accuracy",
               "Prevalence",
               "AUC",
               "Brier Score",
               "MCC"),
         n = c(10L, 10L, 7L, 13L, 20L, 20L, 20L, 20L, 20L, NA_integer_),
  estimate = c(0.4, 0.7, 0.571428571428571, 0.538461538461538, 0.55, 0.55, 0.5,
               0.57, 0.31229479451574, 0.104828483672192),
  CI95_lower = c(0.053526528057833,
                 0.375903743596594,
                 0.153109244339309,
                 0.229236975812673,
                 0.301207679383086,
                 0.301207679383086,
                 0.249954309633907,
                 0.322416883725584,
                 0.080537774567429,NA),
  CI95_upper = c(0.746473471942167,
                 1.00,
                 0.989747898517834,
                 0.847686101110404,
                 0.798792320616914,
                 0.798792320616914,
                 0.750045690366093,
                 0.817583116274416,
                 0.544051814464051,NA)
  )
  expect_equal(sumry$metrics, x)

  # Print method
  expect_snapshot_output(sumry)
})
