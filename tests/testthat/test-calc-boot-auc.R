
# Setup ----
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

auc <- calc_boot_auc(true, pred, "disease", 1000, r.seed = 100)


# Testing ----
test_that("the shape and dimensions are returned correctly", {
  expect_named(auc, c("auc", "lower.limit", "upper.limit"))
  expect_type(auc, "list")
  expect_length(auc, 3L)
})

test_that("the values are correct for r.seed provided", {
  expect_equal(auc, list(auc = 0.222222222222222,
                         lower.limit = 0.0208175505050505,
                         upper.limit = 0.48))
})

test_that("the values are correct for r.seed different r.seed", {
  auc <- calc_boot_auc(true, pred, "disease", 1000, r.seed = 10)
  expect_equal(auc, list(auc = 0.222222222222222,
                         lower.limit = 0.0301406926406926,
                         upper.limit = 0.505654761904762))
})
