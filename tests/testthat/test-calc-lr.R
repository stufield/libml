
# Setup ----
withr::local_options(list(g.praise = FALSE))
nlist <- c("stat.table", "call", "test", "response", "counts",
           "rm.outliers", "log", "paired", "do.mean",
           "data.frame", "data.dim")
apts <- c("seq.3032.11", "seq.2788.55", "seq.5346.24", "seq.4914.10",
          "seq.3310.62", "seq.4929.55", "seq.2953.31",
          "seq.4135.84", # contains outliers
          "seq.2682.68", "seq.5034.79")
small_adat <- dplyr::select(sample.adat, SampleGroup, all_of(apts))

# Testing ----
test_that("the `calc.lr` generates correct output", {
  lr <- calc.lr(small_adat, response = "SampleGroup")
  expect_s3_class(lr, "stat_table")
  expect_s3_class(lr, "logratio_table")
  expect_named(lr, nlist)
  expect_equal(lr$test, "Log Ratios")
  out_sum <- c(log2.fold.change        = 17.0610649069593,
               signed.log2.fold.change = -6.6286978754762,
               rank                    = 55.0000000000000)
  expect_equal(colSums(lr$stat.table), out_sum)
  expect_equal(lr$response, "SampleGroup")
  expect_false(lr$log)
  expect_false(lr$do.mean)
  expect_false(lr$rm.outliers)
  expect_equal(as.numeric(lr$counts), c(11, 9))
  expect_equal(lr$data.frame, "small_adat")
  expect_equal(lr$data.dim, c(20, 11))
  expect_equal(dim(lr$stat.table),
               c(getAnalytes(small_adat, n = TRUE), 3))
  expect_true(setequal(rownames(lr$stat.table),
                       getAnalytes(small_adat)))

  # Print method
  expect_snapshot_output(lr)

  # Write method
  withr::with_options(list(signal.quiet = TRUE), expect_snapshot_csv(lr, "lr"))
})

test_that("the `calc.lr` generates correct output when outliers are removed", {
  lr2 <- calc.lr(small_adat, response = "SampleGroup", rm.outliers = TRUE)
  expect_s3_class(lr2, "stat_table")
  expect_s3_class(lr2, "logratio_table")
  expect_named(lr2, nlist)
  expect_equal(lr2$data.frame, "small_adat")
  expect_equal(lr2$test, "Log Ratios")
  expect_false(lr2$log)
  expect_false(lr2$do.mean)
  expect_equal(lr2$response, "SampleGroup")
  expect_true(lr2$rm.outliers)
  expect_equal(lr2$data.dim, c(20, 11))
  expect_equal(as.numeric(lr2$counts), c(11, 9))
  out_sum <- c(log2.fold.change        = 16.8512044012449,
               signed.log2.fold.change = -5.9411486963091,
               nGrp1                   = 88.0000000000000,
               nGrp2                   = 105.000000000000,
               rank                    = 55.0000000000000)
  expect_equal(colSums(lr2$stat.table), out_sum)
  expect_equal(dim(lr2$stat.table),
               c(getAnalytes(small_adat, n = TRUE), 5))
  expect_true(setequal(rownames(lr2$stat.table),
                       getAnalytes(small_adat)))
})
