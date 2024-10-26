
# Setup ----
true <- c("control", "control", "disease", "disease", "disease",
          "disease", "disease", "disease", "control", "control",
          "disease", "disease", "control", "disease", "control",
          "control", "control", "control", "disease", "control")

pred <- c(0.222461252938956, 0.360352846328169, 0.532661496894434,
          0.796469530789182, 0.771267712814733, 0.922611774411052,
          0.466519388137385, 0.996413280023262, 0.213919642847031,
          0.214762558462098, 0.178224225528538, 0.258298496948555,
          0.805535813327879, 0.164836287265643, 0.977408259175718,
          0.0357247716747224, 0.825505221495405, 0.0411458793096244,
          0.0530758206732571, 0.513491039630026)

x <- create_roc_data(true, pred, "disease")
y <- create_roc_data(true, pred, "disease", do.ci = TRUE)
a <- create_roc_data(true, pred, "disease", include.auc = TRUE)
b <- create_roc_data(true, pred, "disease", include.auc = TRUE, do.ci = TRUE)
c <- dplyr::mutate(a, cutoff = 100 * cutoff)

# Testing ----
# default ----
test_that("the ROC data are correct", {
  expect_s3_class(x, "roc_data")
  expect_named(x, c("cutoff", "tp", "fn", "fp", "tn", "sensitivity",
                    "specificity", "ppv", "npv", "mcc", "perpD", "YoudenJ"))
  expect_equal(dim(x), c(20, 12))
  expect_true(max(dplyr::select(x, -tp, -fn, -fp, -tn, -YoudenJ), na.rm = TRUE) <= 1)
  expect_true(min(dplyr::select(x, -tp, -fn, -fp, -tn, -mcc, -YoudenJ),
                  na.rm = TRUE) >= 0)
  expect_equal(colSums(x, na.rm = TRUE),
               c(cutoff      = 10,
                 tp          = 103,
                 fn          = 97,
                 fp          = 85,
                 tn          = 115,
                 sensitivity = 10.3,
                 specificity = 11.5,
                 ppv         = 10.6715580171463,
                 npv         = 10.8859020064902,
                 mcc         = 2.10292473760508,
                 perpD       = 1.41421356237309,
                 YoudenJ     = 1.8))
})

# CIs ----
test_that("the ROC data are correct when confidence intervals are included", {
  expect_equal(x, dplyr::select(y, cutoff:YoudenJ))  # non ci related same
  # from here out only care about CI95 columns of df
  z <- dplyr::select(y, matches("up|lo"))
  expect_s3_class(z, "roc_data")
  expect_named(z, c("sens_lowerCI", "sens_upperCI", "spec_lowerCI", "spec_upperCI"))
  expect_equal(dim(z), c(20, 4))
  expect_true(max(z) <= 1)
  expect_true(min(z) >= 0)
  expect_equal(colSums(z), c(sens_lowerCI = 5.27253834716751,
                             sens_upperCI = 15.3810796593612,
                             spec_lowerCI = 6.37225362094411,
                             spec_upperCI = 16.4782340497756))
})

# AUC ----
test_that("the ROC data are correct when AUC is included", {
  expect_equal(x, dplyr::select(a, -auc))  # non ci related same
  # from here out only care about CI95 columns of df
  z <- dplyr::select(a, auc)
  expect_s3_class(z, "roc_data")
  expect_equal(
    data.frame(z),
    data.frame(auc = rep(calc_emp_auc(true, pred, "disease"), length(true)))
  )
})

# AUC and CIs ----
test_that("the ROC data are correct when AUC and confidence intervals are included", {
  # non ci related are same
  expect_equal(y, dplyr::select(b, -auc, -auc_upperCI, -auc_lowerCI))
  # from here out only care about AUC columns of df
  b <- dplyr::select(b, auc, auc_upperCI, auc_lowerCI)
  expect_s3_class(b, "roc_data")
  expect_equal(unique(data.frame(b)),
               data.frame(
                 auc         = 0.57,
                 auc_upperCI = 0.837941408154425,
                 auc_lowerCI = 0.302058591845575
               ))
})

# Filter function ----
test_that("`filterROCdata()` works as expected", {
  f1 <- filter_roc_data(x)
  f2 <- filter_roc_data(x, "sensitivity", method = "value", value = 0.8)
  f3 <- filter_roc_data(y)
  f4 <- filter_roc_data(a)
  f5 <- filter_roc_data(c, metric = "cutoff", method = "value", value = 5.264)

  expect_s3_class(f1, c("roc_data", "data.frame"))
  expect_named(f1, c("cutoff", "tp", "fn", "fp", "tn", "sensitivity",
                     "specificity", "ppv", "npv", "mcc", "perpD", "YoudenJ"))
  expect_equal(dim(f1), c(4, 12))
  expect_equal(colSums(f1), c(cutoff      = 1.36843368421053,
                              tp          = 27L,
                              fn          = 13L,
                              fp          = 19L,
                              tn          = 21L,
                              sensitivity = 2.7,
                              specificity = 2.1,
                              ppv         = 2.38055555555556,
                              npv         = 2.78333333333333,
                              mcc         = 0.937457478565265,
                              perpD       = 0.565685424949238,
                              YoudenJ     = 0.8)
  )
  expect_equal(colSums(f2), c(cutoff      = 0.31580316,
                              tp          = 16L,
                              fn          = 4L,
                              fp          = 16L,
                              tn          = 4L,
                              sensitivity = 1.6,
                              specificity = 0.4,
                              ppv         = 0.99607843,
                              npv         = 1.06666667,
                              mcc         = 0.02455795,
                              perpD       = 0.14142136,
                              YoudenJ     = 0.0)
  )
  expect_equal(colSums(f3), c(cutoff      = 1.36843368421053,
                              tp          = 27,
                              fn          = 13,
                              fp          = 19,
                              tn          = 21,
                              sensitivity = 2.7,
                              specificity = 2.1,
                              ppv         = 2.38055555555556,
                              npv         = 2.78333333333333,
                              mcc         = 0.937457478565265,
                              perpD       = 0.565685424949238,
                              YoudenJ     = 0.8,
                              sens_lowerCI = 1.6534350,
                              sens_upperCI = 3.7465650,
                              spec_lowerCI = 0.8829568,
                              spec_upperCI = 3.3758413)
  )
  expect_equal(colSums(f4), c(auc         = 2.2800000,
                              cutoff      = 1.36843368421053,
                              tp          = 27,
                              fn          = 13,
                              fp          = 19,
                              tn          = 21,
                              sensitivity = 2.7,
                              specificity = 2.1,
                              ppv         = 2.38055555555556,
                              npv         = 2.78333333333333,
                              mcc         = 0.937457478565265,
                              perpD       = 0.565685424949238,
                              YoudenJ     = 0.8)
  )

  expect_equal(colSums(f5), c(auc = 0.57,
                              cutoff = 5.26405263157895,
                              tp = 10,
                              fn = 0,
                              fp = 8,
                              tn = 2,
                              sensitivity = 1,
                              specificity = 0.2,
                              ppv = 0.555555555555556,
                              npv = 1,
                              mcc = 0.333333333333333,
                              perpD = 0.141421356237309,
                              YoudenJ = 0.2)
  )
})

# Errors ----
test_that("errors are triggered properly", {
  expect_error(
    filter_roc_data(x, "sensitivity", method = "value", value = "0.8"),
    "Please enter a non-null filtering `value` in [-1, 1].", fixed = TRUE
  )
  expect_error(
    filter_roc_data(x, "sensitivity", method = "value", value = 1.1),
    "Please enter a valid value for your filtering metric:"
  )
})
