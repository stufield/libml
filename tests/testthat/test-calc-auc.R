
# Setup ----
n <- 20
df <- withr::with_seed(22,
  data.frame(stringsAsFactors = FALSE,
             true = sample(c("control", "disease"), n, replace = TRUE),
             pred = runif(n)
             )
)


# Testing ----
test_that("`calc_emp_auc()` generates expected output", {
  expect_equal(calc_emp_auc(df$true, df$pred, "disease"), 0.47252747252747)
  auc <- calc_emp_auc(df$true, df$pred, "disease", TRUE)
  expect_type(auc, "list")
  expect_equal(auc$auc, 0.47252747252747)
  expect_equal(auc$lower.limit, 0.19502890465025)
  expect_equal(auc$upper.limit, 0.75002604040469)
  # pos.class typo error
  expect_error(
    calc_emp_auc(df$true, df$pred, "diseaseeee"),
    "pos.class %in% truth is not TRUE"
  )
})

test_that("`calc_emp_auc()` generates expected output with edge case", {
  x <- c(0, 1, 0, 1, 1, 1, 0)
  y <- c(0.001, 0.999, 0.001, 0.999, 0.999, 0.999, 0.001)
  expect_equal(calc_emp_auc(x, y, 1), 1)        # no warning; both 'double'
  expect_warning(a <- calc_emp_auc(x, y, 1L))   # warning tested in roc_xy()
  expect_equal(a, 1)
  expect_warning(a <- calc_emp_auc(x, y, "1"))  # warning tested in roc_xy()
  expect_equal(a, 1)
})

test_that("`calc_emp_auc()` converts factors -> character to match pos.class type", {
  x <- c(0, 1)
  y <- c(0.1, 0.9)
  expect_warning(calc_emp_auc(factor(x), y, "1"), NA)   # expect no warning!
})
