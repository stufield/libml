
true <- c("cont", "cont", "disease", "disease", "cont", "cont", "disease",
          "cont", "disease", "disease", "disease", "disease", "disease",
          "disease", "cont", "disease", "disease", "cont", "cont", "cont")

pred <- c(0.700711545301601, 0.956837461562827, 0.213352001970634,
          0.661061500199139, 0.923318882007152, 0.795719761401415,
          0.0712125543504953, 0.389407767681405, 0.406451216200367,
          0.659355078125373, 0.423347146715969, 0.320984446210787,
          0.197730733314529, 0.163170094368979, 0.523311075055972,
          0.913478652015328, 0.206772719044238, 0.814283016137779,
          0.0201671982649714, 0.924804413458332)

# Generate confusion summary object ----
c_mat <- summary(calc_confusion(true, pred, pos.class = "disease"))

# Testing ----
test_that("`pull_stat()` pulls the correct values from 'summary.confusion_matrix'", {
  expect_equal(pull_stat(c_mat, "Spec"), 0.222222222222)
  expect_equal(pull_stat(c_mat, "Sens"), 0.272727272727)
  expect_equal(pull_stat(c_mat, "Recall"), pull_stat(c_mat, "Sens"))    # same
  expect_equal(pull_stat(c_mat, "Accuracy"), 0.25)
  expect_equal(pull_stat(c_mat, "Error"), 1 - pull_stat(c_mat, "Accuracy"))
  expect_equal(pull_stat(c_mat, "NPV"), 0.2)
  expect_equal(pull_stat(c_mat, "PPV"), 0.3)
  expect_equal(pull_stat(c_mat, "Precision"), pull_stat(c_mat, "PPV"))
  expect_equal(pull_stat(c_mat, "MCC"), -0.502518907629606)
  expect_equal(pull_stat(c_mat, "F_measure"), 0.285714285714286)
  expect_equal(pull_stat(c_mat, "G_mean"), 0.246182981958665)
  expect_equal(pull_stat(c_mat, "Wt_Acc"), 0.26010101010101)
})
