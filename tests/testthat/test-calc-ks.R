
# Setup ---
# mute p-values with ties warnings in KS-test
withr::local_options(list(warn = -1, g.praise = FALSE))
apts <- c("seq.2696.87", "seq.4330.4", "seq.2819.23", "seq.3367.8", "seq.3004.67",
          "seq.3073.51", "seq.2953.31", "seq.2711.6", "seq.3389.7", "seq.3431.54")
small_adat <- dplyr::select(sample.adat, SampleGroup, all_of(apts))

# Testing ---
test_that("the standard defaults to `calc.ks()` are correct", {
  ks <- calc.ks(small_adat, response = "SampleGroup")
  expect_s3_class(ks, "stat_table")
  expect_s3_class(ks, "ks_table")
  out_sum <- c(ks.dist        = 7.757575757575758,
               signed.ks.dist = 4.666666666666667,
               p.value        = 0.036341986187188,
               fdr            = 0.044847412649269,
               p.bonferroni   = 0.363419861871879,
               rank           = 55.00000000000000)
  expect_equal(colSums(ks$stat.table), out_sum)
  expect_equal(ks$data.dim, c(nrow(small_adat), ncol(small_adat)))
  expect_equal(ks$counts, c(table(small_adat$SampleGroup)))
  expect_match(ks$test, "Kolmogorov-Smirnov Test")
  expect_match(ks$response, "SampleGroup")
  expect_false(ks$rm.outliers)

  # Print method
  withr::with_options(list(warn = 0), expect_snapshot_output(ks))

  # Write method
  withr::with_options(list(signal.quiet = TRUE), expect_snapshot_csv(ks, "ks"))
})

test_that("removing outliers generates correct output", {
  kso <- calc.ks(small_adat, response = "SampleGroup", rm.outliers = TRUE)
  expect_s3_class(kso, "stat_table")
  expect_s3_class(kso, "ks_table")
  out_sum <- c(ks.dist        = 7.757575757575758,
               signed.ks.dist = 4.666666666666667,
               p.value        = 0.036341986187188,
               nGrp1          = 90.0000000000000,
               nGrp2          = 110.000000000000,
               fdr            = 0.044847412649269,
               p.bonferroni   = 0.363419861871879,
               rank           = 55.00000000000000)
  expect_equal(colSums(kso$stat.table), out_sum)
  expect_equal(kso$data.dim, c(nrow(small_adat), ncol(small_adat)))
  expect_equal(kso$counts, c(table(small_adat$SampleGroup)))
  expect_match(kso$test, "Kolmogorov-Smirnov Test")
  expect_match(kso$response, "SampleGroup")
  expect_true(kso$rm.outliers)
})
