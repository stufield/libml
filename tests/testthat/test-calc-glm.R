
# Setup ----
withr::local_options(list(g.praise = FALSE, signal.quiet = TRUE))
apts <- c("seq.3795.6", "seq.3004.67", "seq.5034.79", "seq.3073.51", "seq.2750.3",
          "seq.2474.54", "seq.2819.23", "seq.2620.4", "seq.3431.54", "seq.4929.55")
small_adat <- dplyr::select(sample.adat, SampleGroup, all_of(apts))

# Testing ----
test_that("the full unit test for `calc.glm()` return expected object result", {
  # mute glm.fit: fitted probabilities numerically 0 or 1 occurred warning
  withr::local_options(c(warn = -1))
  glm <- calc.glm(create_train(small_adat, group.var = SampleGroup))

  expect_s3_class(glm, "stat_table")
  expect_s3_class(glm, "glm_table")
  out_sum <-   c(intercept    = -73.2992358842200531,
                 slope        = 0.0090464251574861,
                 odds_ratio   = 10.0090546132415117,
                 p.value      = 0.2798793237727377,
                 fdr          = 0.3316900653838916,
                 p.bonferroni = 2.7987932377273763,
                 rank         = 55.0000000000000000)
  expect_equal(colSums(glm$stat.table), out_sum)
  expect_equal(glm$data.dim, dim(small_adat))
  expect_equal(glm$data.frame, "create_train(small_adat, group.var = SampleGroup)")
  expect_true(all(vapply(glm$models, class, character(2)) == c("glm", "lm")))
  expect_equal(length(glm$models), getAnalytes(small_adat, n = TRUE))
  expect_true(setequal(names(glm$models), getAnalytes(small_adat)))
  expect_true(setequal(rownames(glm$stat.table), getAnalytes(small_adat)))
  expect_equal(glm$test, "Logistic Regression")
  expect_equal(glm$y.response, "SampleGroup")
  expect_type(glm$call, "language")
  expect_equal(as.character(glm$call),
               c("calc.glm",
                 "create_train(small_adat, group.var = SampleGroup)"))
  expect_equal(glm$counts, c("F" = 11, "M" = 9))

  # Print method
  withr::with_options(list(warn = 0, width = 100, signal.quiet = FALSE),
                      expect_snapshot_output(glm))

  # Write method
  expect_snapshot_csv(glm, "glm")
})
