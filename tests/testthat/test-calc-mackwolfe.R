
# Setup ----
withr::local_options(list(g.praise = FALSE))
apts <- c("seq.3332.57", "seq.3804.66", "seq.2670.67", "seq.3401.8", "seq.2632.5",
          "seq.2789.26", "seq.3580.25", "seq.2475.1", "seq.4541.49", "seq.2875.15")
small_adat <- dplyr::select(sample.adat, all_of(apts))
lett <- utils::head(LETTERS, 4)
small_adat$group <- factor(rep(lett, each = 5))


# Testing ----
# Error peak catch `calc.mackwolfe()` ----
test_that("`calc.mackwolfe()` generates the correct output", {
  expect_error(
    calc.mackwolfe(small_adat, response = "group"),
    "Please explicitly declare a `peak =` argument\\."
  )
})

# `calc.jt()` ----
test_that("`calc.jt()` generates the correct output", {
  jt <- calc.jt(small_adat, response = "group")
  expect_s3_class(jt, "stat_table")
  expect_s3_class(jt, "mackwolfe_table")
  expect_named(jt$stat.table, c("Ap", "Astar", "n", "peak", "p.value", "fdr",
                                "p.bonferroni", "rank"))
  out_sum <- c(Ap           = 498.00000000000000,
               Astar        = -16.957749939743419,
               n            = 20 * 10,
               p.value      = 0.070227000387787,
               fdr          = 0.114260583100164,
               p.bonferroni = 0.702270003877870,
               rank         = 55.00000000000000)
  expect_equal(colSums(jt$stat.table[, -4]), out_sum)
  expect_equal(jt$data.dim, c(nrow(small_adat), ncol(small_adat)))
  expect_equal(jt$data.frame, "small_adat")
  expect_equal(jt$counts, table(small_adat$group))
  expect_equal(jt$test, "Mack-Wolfe (JT) Test")
  expect_equal(jt$response, "group")
  expect_equal(jt$peak, "jt")
  expect_equal(jt$factor.order, lett)

  # Print method
  expect_snapshot_output(jt)

  # Write method
  withr::with_options(list(signal.quiet = TRUE), expect_snapshot_csv(jt, "jt"))
})

# `calc.mackwolfe()` ----
test_that("`calc.mackwolfe()` generates the correct output", {
  tbl <- calc.mackwolfe(small_adat, response = "group", peak = "B")
  expect_s3_class(tbl, "stat_table")
  expect_s3_class(tbl, "mackwolfe_table")
  expect_named(tbl$stat.table, c("Ap", "Astar", "n", "peak", "p.value", "fdr",
                                 "p.bonferroni", "rank"))
  out_sum <- c(Ap           = 577.00000000000,
               Astar        = 6.2014819501776,
               n            = 20 * 10,
               p.value      = 3.3939543271687,
               fdr          = 5.4527999950406,
               p.bonferroni = 9.5474672700381,
               rank         = 55.000000000000)
  expect_equal(colSums(tbl$stat.table[, -4]), out_sum)
  expect_equal(tbl$data.dim, c(nrow(small_adat), ncol(small_adat)))
  expect_equal(tbl$data.frame, "small_adat")
  expect_equal(tbl$counts, table(small_adat$group))
  expect_equal(tbl$test, "Mack-Wolfe Test")
  expect_equal(tbl$response, "group")
  expect_equal(tbl$peak, "B")
  expect_equal(tbl$factor.order, lett)

  # Print method
  expect_snapshot_output(tbl)

  # Write method
  withr::with_options(list(signal.quiet = TRUE),
                      expect_snapshot_csv(tbl, "calc-mack-peak-B"))
})
