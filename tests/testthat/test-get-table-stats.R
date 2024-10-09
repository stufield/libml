
# Setup ----
withr::local_options(list(g.praise = FALSE, stringsAsFactors = FALSE))
withr::local_output_sink("/dev/null")      # dump console output
t_tab <- calc.t(log10(sample.adat), response = "SampleGroup")


# Testing ----
test_that("returns correct when no features at threshold", {
  expect_message(get_table_stats(t_tab),
                 "No significant features at this threshold")
  expect_null(get_table_stats(t_tab))
})

test_that("returns correct when alpha relaxed; 1 feature", {
  tab <- get_table_stats(t_tab, alpha = 0.5)
  expect_equal(dim(tab), c(1L, 7L))
  expect_equal(tab,
               data.frame("seq.4330.4", 5.541887902,
                          5.541887902, 0.000212384733,
                          0.2397823636, 0.2397823636, 1),
               ignore_attr = TRUE)
  expect_named(tab, c("AptName", "t-statistic", "Signed t-statistic",
                      "p-value", "FDR", "Bonferroni p-value", "rank"))
})

test_that("returns correct when `p.value` field used and alpha increased", {
  tab <- get_table_stats(t_tab, field = "p.value", alpha = 0.01)
  expect_equal(dim(tab), c(7L, 7L))
  expect_named(tab, c("AptName", "t-statistic", "Signed t-statistic",
                      "p-value", "FDR", "Bonferroni p-value", "rank"))
  expect_equal(colSums(tab[, -1]), c("t-statistic" = 25.87421703352,
                                     "Signed t-statistic" = 18.56070352284,
                                     "p-value" = 0.03072901044,
                                     "FDR" = 5.08432350997,
                                     "Bonferroni p-value" = 6.23978236360,
                                     "rank" = 28))
})

test_that("returns correct when `n = ` argument is passed", {
  expect_equal(dim(get_table_stats(t_tab, n = 25)), c(25L, 7L))
})
