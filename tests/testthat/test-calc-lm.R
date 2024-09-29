
# Setup ----
withr::local_options(list(g.praise = FALSE, signal.quiet = TRUE))
apts <- c("seq.3590.8", "seq.3186.2", "seq.5317.3", "seq.3612.6", "seq.2643.57",
          "seq.4829.43", "seq.5340.24", "seq.5308.89", "seq.3585.54", "seq.3104.8")
small_adat <- dplyr::select(sample.adat, HybControlNormScale, all_of(apts))

# Testing ----
test_that("`calc.lm()` with `do.log` deprecation error", {
  expect_error(
    calc.lm(small_adat, response = "HybControlNormScale", do.log = TRUE),
    paste("The `do.log` argument of `calc.lm()` was deprecated in",
          "fittr 0.0.1 and is now defunct."),
    fixed = TRUE, class = "lifecycle_error_deprecated"
  )
  # even if FALSE
  expect_error(
    calc.lm(small_adat, response = "HybControlNormScale", do.log = FALSE),
    paste("The `do.log` argument of `calc.lm()` was deprecated in",
          "fittr 0.0.1 and is now defunct."),
    fixed = TRUE, class = "lifecycle_error_deprecated"
  )
  expect_error(
    calc.lm(iris, response = "HybControlNormScale", do.log = FALSE),
    paste("The `do.log` argument of `calc.lm()` was deprecated in",
          "fittr 0.0.1 and is now defunct."),
    fixed = TRUE, class = "lifecycle_error_deprecated"
  )
})

test_that("`calc.lm()` trips a warning when not log-transformed", {
  expect_warning(
    calc.lm(small_adat, response = "HybControlNormScale"),
    paste("Are you sure you wanted to perform a 'linear regression'",
    "test without log10-transformation")
  )
})

test_that("`calc.lm()` generates expected output object", {
  lm <- calc.lm(log10(small_adat), response = "HybControlNormScale")
  expect_s3_class(lm, "stat_table")
  expect_s3_class(lm, "lm_table")
  out_sum <- c(intercept    = 4.34426402395175,
               slope        = 1.37803125978768,
               t.slope      = 13.72552593897377,
               p.value      = 0.14035688661159,
               fdr          = 0.20116525076327,
               p.bonferroni = 1.40356886611592,
               rank         = 55.00000000000000)
  expect_equal(colSums(lm$stat.table), out_sum)
  expect_equal(lm$data.dim, c(nrow(small_adat), ncol(small_adat)))
  expect_equal(lm$data.frame, "log10(small_adat)")
  expect_true(all(vapply(lm$models, class, "") == "lm"))
  expect_equal(length(lm$models), getAnalytes(small_adat, n = TRUE))
  expect_true(setequal(names(lm$models), getAnalytes(small_adat)))
  expect_true(setequal(rownames(lm$stat.table), getAnalytes(small_adat)))
  expect_type(lm$call, "language")
  expect_equal(as.character(lm$call),
               c("calc.lm", "log10(small_adat)", "HybControlNormScale"))
  expect_equal(lm$test, "Linear Regression")
  expect_match(lm$y.response, "HybControlNormScale")
  expect_true(lm$log)

  # Print method
  withr::with_options(list(width = 100, signal.quiet = FALSE),
                      expect_snapshot_output(lm))

  # Write method
  expect_snapshot_csv(lm, "lm")
})
