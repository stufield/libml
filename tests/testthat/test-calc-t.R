
# Setup ----
withr::local_options(list(g.praise = FALSE))
apts <- c("seq.4330.4", "seq.2819.23", "seq.2953.31", "seq.2474.54", "seq.2711.6",
          "seq.4135.84", # contains outliers for rm.outliers
          "seq.3396.54", "seq.3795.6", "seq.2750.3", "seq.5034.79")
small_adat <- dplyr::select(sample.adat, SampleGroup, all_of(apts))

# Testing ----
test_that("the `calc.t()` generates the expected warning without log10-transform", {
  expect_warning(
    calc.t(small_adat, response = "SampleGroup"),
    "Are you sure you wanted to perform a 't-test' test without log10-transformation"
  )
})

test_that("the `calc.t()` generates the expected output", {
  t_test <- calc.t(log10(small_adat), response = "SampleGroup")
  expect_s3_class(t_test, "stat_table")
  expect_s3_class(t_test, "t_table")
  out_sum <- c(t.stat        = 33.0284159725113,
               signed.t.stat = 25.7149024618326,
               p.value       = 0.24222006769713,
               fdr           = 0.27978695242455,
               p.bonferroni  = 1.52562706875122,
               rank          = 55.0000000000000)
  expect_equal(colSums(t_test$stat.table), out_sum)
  expect_equal(t_test$data.dim, c(nrow(small_adat), ncol(small_adat)))
  expect_equal(t_test$counts, c(table(small_adat$SampleGroup)))
  expect_equal(t_test$test, "Student t-test")
  expect_equal(t_test$response, "SampleGroup")
  expect_true(t_test$log)
  expect_false(t_test$rm.outliers)
  expect_false(t_test$paired)

  # Print method
  expect_snapshot_output(t_test)

  # Write method
  withr::with_options(list(signal.quiet = TRUE), expect_snapshot_csv(t_test, "t-test"))
})


test_that("`calc.t()` generates the correct output when `rm.outliers = TRUE`", {
  t_test_o <- calc.t(log10(small_adat), response = "SampleGroup", rm.outliers = TRUE)
  expect_s3_class(t_test_o, "t_table")
  expect_s3_class(t_test_o, "stat_table")
  out_sum <- c(t.stat        = 36.007994872211029,
               signed.t.stat = 28.694481361532389,
               p.value       = 0.053615911965347,
               nGrp1         = 89.00000000000000,
               nGrp2         = 106.0000000000000,
               fdr           = 0.080888276882318,
               p.bonferroni  = 0.536159119653468,
               rank          = 55.0000000000000)
  expect_equal(colSums(t_test_o$stat.table), out_sum)
  expect_equal(t_test_o$data.dim, c(nrow(small_adat), ncol(small_adat)))
  expect_equal(t_test_o$counts, c(table(small_adat$SampleGroup)))
  expect_equal(t_test_o$test, "Student t-test")
  expect_equal(t_test_o$response, "SampleGroup")
  expect_true(t_test_o$log)
  expect_true(t_test_o$rm.outliers)
  expect_false(t_test_o$paired)
})


# generate random pairings variable 'Group'
small_adat$Group <- rep(c("A", "B"), each = 10)

test_that("`calc.t()` generates the correct output when paired samples are used", {
  t_test_p <- calc.t(log10(small_adat), response = "Group", paired = TRUE)
  expect_s3_class(t_test_p, "t_table")
  expect_s3_class(t_test_p, "stat_table")
  out_sum <- c(t.stat        = 4.06846013226537,
               signed.t.stat = 0.22255706304384,
               p.value       = 7.07815998327175,
               fdr           = 9.33956654606428,
               p.bonferroni  = 10.0000000000000,
               rank          = 55.0000000000000)
  expect_equal(colSums(t_test_p$stat.table), out_sum)
  expect_equal(t_test_p$data.dim, c(nrow(small_adat), ncol(small_adat)))
  expect_equal(t_test_p$counts, c(table(small_adat$Group)))
  expect_equal(t_test_p$test, "Student t-test")
  expect_equal(t_test_p$response, "Group")
  expect_true(t_test_p$log)
  expect_false(t_test_p$rm.outliers)
  expect_true(t_test_p$paired)
})


test_that("`calc.t()` generates correct output with paired AND outlier removal", {
  t_test_op <- calc.t(log10(small_adat), response = "Group", paired = TRUE,
                      rm.outliers = TRUE)
  expect_s3_class(t_test_op, "t_table")
  expect_s3_class(t_test_op, "stat_table")
  out_sum <- c(t.stat        = 4.16671110877156,
               signed.t.stat = 0.32080803955002,
               p.value       = 6.99232765806008,
               nGrp1         = 96.0000000000000,
               nGrp2         = 96.0000000000000,
               fdr           = 9.33956654606428,
               p.bonferroni  = 10.0000000000000,
               rank          = 55.0000000000000)
  expect_equal(colSums(t_test_op$stat.table), out_sum)
  expect_equal(t_test_op$data.dim, c(nrow(small_adat), ncol(small_adat)))
  expect_equal(t_test_op$counts, c(table(small_adat$Group)))
  expect_equal(t_test_op$test, "Student t-test")
  expect_equal(t_test_op$response, "Group")
  expect_true(t_test_op$log)
  expect_true(t_test_op$rm.outliers)
  expect_true(t_test_op$paired)
})
