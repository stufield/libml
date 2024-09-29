
# Setup ----
# mute p-values with ties warnings in KS-test
# also remove fancy print formatting for output tests
withr::local_options(list(warn = -1, g.praise = FALSE))
apts <- c("seq.4330.4", "seq.3004.67", "seq.2696.87", "seq.2819.23",
          "seq.4135.84",  # contains outliers
          "seq.2953.31", "seq.3073.51", "seq.3367.8", "seq.2711.6", "seq.2972.57")
small_adat <- dplyr::select(sample.adat, SampleGroup, all_of(apts))

# Testing ----
test_that("calc.wilcox Rank-Sum (M-W) generates the correct output table", {
  w <- calc.wilcox(small_adat, response = "SampleGroup")
  expect_s3_class(w, "stat_table")
  expect_s3_class(w, "wilcox_table")
  out_sum <- c(U            = 722.0000000000000,
               p.value      = 0.15770421528935,
               fdr          = 0.17023422054382,
               p.bonferroni = 1.26899261728983,
               rank         = 55.00000000000000)
  expect_equal(colSums(w$stat.table), out_sum)
  expect_equal(w$data.dim, c(nrow(small_adat), ncol(small_adat)))
  expect_equal(w$counts, c(table(small_adat$SampleGroup)))
  expect_equal(w$test, "Wilcoxon rank-sum test (Mann-Whitney)")
  expect_match(w$response, "SampleGroup")
  expect_false(w$paired)
  expect_false(w$rm.outliers)

  # Print method
  withr::with_options(list(warn = 0), expect_snapshot_output(w))

  # Write method
  withr::with_options(list(signal.quiet = TRUE), expect_snapshot_csv(w, "wilcox"))
})

test_that("`calc.wilcox` with rm.outliers = TRUE is correct", {
  wo <- calc.wilcox(small_adat, response = "SampleGroup", rm.outliers = TRUE)
  expect_s3_class(wo, "stat_table")
  expect_s3_class(wo, "wilcox_table")
  out_sum <- c(U            = 707.0000000000000,
               p.value      = 0.027520862350584,
               nGrp1        = 89.00000000000000,
               nGrp2        = 106.0000000000000,
               fdr          = 0.036211162991349,
               p.bonferroni = 0.275208623505837,
               rank         = 55.00000000000000)
  expect_equal(colSums(wo$stat.table), out_sum)
  expect_equal(wo$data.dim, c(nrow(small_adat), ncol(small_adat)))
  expect_equal(wo$counts, c(table(small_adat$SampleGroup)))
  expect_equal(wo$test, "Wilcoxon rank-sum test (Mann-Whitney)")
  expect_match(wo$response, "SampleGroup")
  expect_false(wo$paired)
  expect_true(wo$rm.outliers)
})

# generate random pairing variable 'Group'
small_adat$Group <- rep(c("A", "B"), each = 10)

test_that("the `calc.wilcox` Signed-Rank (paired) unit test", {
  wp <- calc.wilcox(small_adat, response = "Group", paired = TRUE)
  expect_s3_class(wp, "stat_table")
  expect_s3_class(wp, "wilcox_table")
  out_sum <- c(W            = 291.000000,
               p.value      = 6.45703125,
               fdr          = 9.21875000,
               p.bonferroni = 10.0000000,
               rank         = 55.0000000)
  expect_equal(colSums(wp$stat.table), out_sum)
  expect_equal(wp$data.dim, c(nrow(small_adat), ncol(small_adat)))
  expect_equal(wp$counts, c(table(small_adat$Group)))
  expect_equal(wp$test, "Wilcoxon signed-rank test")
  expect_match(wp$response, "Group")
  expect_true(wp$paired)
  expect_false(wp$rm.outliers)
})

test_that("`calc.wilcox` paired AND outliers removed generates correct output", {
  wpo <- calc.wilcox(small_adat, response = "Group", paired = TRUE, rm.outliers = TRUE)
  expect_s3_class(wpo, "stat_table")
  expect_s3_class(wpo, "wilcox_table")
  out_sum <- c(W            = 270.0000000,
               p.value      = 6.962890625,
               nGrp1        = 97.00000000,
               nGrp2        = 97.00000000,
               fdr          = 9.375000000,
               p.bonferroni = 10.00000000,
               rank         = 55.00000000)
  expect_equal(colSums(wpo$stat.table), out_sum)
  expect_equal(wpo$data.dim, c(nrow(small_adat), ncol(small_adat)))
  expect_equal(wpo$counts, c(table(small_adat$Group)))
  expect_equal(wpo$test, "Wilcoxon signed-rank test")
  expect_match(wpo$response, "Group")
  expect_true(wpo$paired)
  expect_true(wpo$rm.outliers)
})
