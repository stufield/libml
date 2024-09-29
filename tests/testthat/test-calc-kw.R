
# Setup ----
withr::local_options(list(g.praise = FALSE))
apts <- c("seq.3485.28", "seq.3083.71", "seq.4330.4", "seq.2609.59", "seq.3438.10",
          "seq.3364.76", "seq.4496.60", "seq.3152.57", "seq.3079.62", "seq.3604.6")
small_adat <- dplyr::select(sample.adat, SampleGroup, TimePoint, all_of(apts))
small_adat$Response <- factor(paste0(small_adat$SampleGroup, "_", small_adat$TimePoint))

# Testing ----
test_that("the `calc.kw` function generates the correct output", {
  kw <- calc.kw(small_adat)
  expect_s3_class(kw, "stat_table")
  expect_s3_class(kw, "kw_table")
  out_sum <- c(H       = 137.68135905980150,
               df      = 30.000000000000000,
               p.value = 0.035130032933633,
               fdr     = 0.054501593730013,
               p.bonferroni = 0.351300329336333,
               rank    = 55.000000000000000)
  expect_equal(colSums(kw$stat.table), out_sum)
  expect_equal(kw$data.dim, c(nrow(small_adat), ncol(small_adat)))
  expect_equal(kw$data.frame, "small_adat")
  expect_equal(kw$counts, c(table(small_adat$Response)))
  expect_match(kw$test, "Kruskal-Wallis rank sum test")
  expect_match(kw$response, "Response")

  # Print method
  expect_snapshot_output(kw)

  # Write method
  withr::with_options(list(signal.quiet = TRUE), expect_snapshot_csv(kw, "kw"))
})
