
# Setup ----
# simplify color output for print methods
withr::local_options(list(g.praise = FALSE, signal.quiet = TRUE))
# for speed -> pre-select 10 analytes with correlation signal
apts <- c("seq.3186.2", "seq.3590.8", "seq.2643.57", "seq.5242.37", "seq.5317.3",
          "seq.5340.24", "seq.2619.72", "seq.2649.77", "seq.3612.6", "seq.3403.1")
small_adat <- dplyr::select(sample.adat, HybControlNormScale, all_of(apts))

# Testing ----
test_that("`calc.cor()` trips a warning when not log-transformed", {
  expect_warning(    # no log-transform warning
    calc.cor(small_adat,
             method = "pearson",
             response = "HybControlNormScale")
  )
})

test_that("`calc.cor()` with `method = pearson` generates correct values", {
  for ( i in apts ) small_adat[[i]] <- log10(small_adat[[i]])
  r <- calc.cor(small_adat, response = "HybControlNormScale",
                method = "pearson")
  expect_s3_class(r, "stat_table")
  expect_s3_class(r, "cor_table")
  out_sum <- c(r            = 0.941213064630697,
               t.stat       = 4.072090274930265,
               loCI95       = -2.343362660006326,
               upCI95       = 3.896526111874651,
               p.value      = 0.094798226277372,
               fdr          = 0.139665524370771,
               p.bonferroni = 0.947982262773718,
               rank         = 55.00000000000000)
  expect_equal(colSums(r$stat.table), out_sum)
  expect_equal(r$data.dim, c(nrow(small_adat), ncol(small_adat)))
  expect_equal(r$data.frame, "small_adat")
  expect_match(r$test, "Pearson's product-moment correlation")
  expect_match(r$response, "HybControlNormScale")
  expect_true(r$log)

  # Print method
  withr::with_options(list(width = 100, signal.quiet = FALSE),
                      expect_snapshot_output(r))

  # Write method
  expect_snapshot_csv(r, "pearson")
})

test_that("`calc.cor()` with `method = spearman` generates correct values", {
  # mute p-values with ties warnings in KS-test
  withr::local_options(c(warn = -1))
  rho <- calc.cor(small_adat, response = "HybControlNormScale") # spearman default
  expect_s3_class(rho, "stat_table")
  expect_s3_class(rho, "cor_table")
  out_sum <- c(rho          = 1.10375939849624,
               S            = 11832.0000000000,
               t.stat       = 5.11479344209006,
               p.value      = 0.21065460868158,
               cov          = 38.63157894736842,
               fdr          = 0.27665607225270,
               p.bonferroni = 2.10654608681581,
               rank         = 55.0000000000000)
  expect_equal(colSums(rho$stat.table), out_sum)
  expect_equal(rho$data.dim, c(nrow(small_adat), ncol(small_adat)))
  expect_equal(rho$data.frame, "small_adat")
  expect_match(rho$test, "Spearman's rank correlation rho")
  expect_match(rho$response, "HybControlNormScale")
  expect_false(rho$log)

  # Print method
  withr::with_options(list(width = 100, signal.quiet = FALSE),
                      expect_snapshot_output(rho))

  # Write method
  expect_snapshot_csv(rho, "spearman")
})

test_that("`calc.cor()` with `method = kendall` generates correct values", {
  # mute p-values with ties warnings in KS-test
  tau <- calc.cor(small_adat, response = "HybControlNormScale",
                  method = "kendall")
  expect_s3_class(tau, "stat_table")
  expect_s3_class(tau, "cor_table")
  out_sum <- c(tau          = 0.67368421052632,
               "T"          = 1014.00000000000,
               p.value      = 0.19339710291009,
               fdr          = 0.25449938337444,
               p.bonferroni = 1.93397102910093,
               rank         = 55.0000000000000)
  expect_equal(colSums(tau$stat.table), out_sum)
  expect_equal(tau$data.dim, c(nrow(small_adat), ncol(small_adat)))
  expect_equal(tau$data.frame, "small_adat")
  expect_match(tau$test, "Kendall's rank correlation tau")
  expect_match(tau$response, "HybControlNormScale")
  expect_false(tau$log)

  # Print method
  withr::with_options(list(signal.quiet = FALSE), expect_snapshot_output(tau))

  # Write method
  expect_snapshot_csv(tau, "kendall")
})
