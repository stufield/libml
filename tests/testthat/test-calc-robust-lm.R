
# Setup ----
withr::local_options(list(g.praise = FALSE, signal.quiet = TRUE))
apts <- c("seq.3590.8", "seq.3186.2", "seq.5317.3", "seq.3612.6", "seq.2643.57",
          "seq.4829.43", "seq.5340.24", "seq.5308.89", "seq.3585.54", "seq.3104.8")
small_adat <- dplyr::select(sample.adat, HybControlNormScale, all_of(apts))

# Testing ----
test_that("`calc.robust.lm()` trips a warning when not log-transformed", {
  expect_warning(
    calc.robust.lm(small_adat, response = "HybControlNormScale"),
    "Are you sure you wanted to perform a 'robust lm' test without log10"
  )
})


test_that("`calc.robust.lm()` generates correct output object", {
  for (i in apts) small_adat[[i]] <- log10(small_adat[[i]])
  tbl <- calc.robust.lm(small_adat, response = "HybControlNormScale")
  expect_s3_class(tbl, "stat_table")
  expect_s3_class(tbl, "rlm_table")
  expect_true(all(vapply(tbl$models, class, character(2)) == c("rlm", "lm")))
  colSums(tbl$stat.table)
  out_sum <- c(intercept    = 4.086290055895892,
               slope        = 1.463057807552697,
               t.slope      = 14.091889496713051,
               p.value      = 0.098664464217325,
               fdr          = 0.138565544297267,
               p.bonferroni = 0.986644642173251,
               rank         = 55.000000000000000)
  expect_equal(colSums(tbl$stat.table), out_sum)
  expect_equal(tbl$data.dim, c(nrow(small_adat), ncol(small_adat)))
  expect_equal(tbl$data.frame, "small_adat")
  expect_equal(length(tbl$models), length(getAnalytes(small_adat)))
  expect_true(setequal(names(tbl$models), getAnalytes(small_adat)))
  expect_true(setequal(rownames(tbl$stat.table), getAnalytes(small_adat)))
  expect_equal(tbl$test, "Robust Linear Regression")
  expect_match(tbl$y.response, "HybControlNormScale")
  expect_true(tbl$log)

  # Print method
  withr::with_options(list(width = 100, signal.quiet = FALSE),
                      expect_snapshot_output(tbl))

  # Write method
  expect_snapshot_csv(tbl, "rlm")
})
