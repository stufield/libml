
test_that("the `fake_iris` data set is correct and of the right form", {
  expect_s3_class(fake_iris, "tr_data")
  expect_s3_class(fake_iris, "soma_adat")
  expect_true(is.soma_adat(fake_iris))
  expect_s3_class(fake_iris, "tbl_df")
  expect_s3_class(fake_iris, "grouped_df")
  expect_equal(dim(fake_iris), c(100, 5))
  expect_equal(c(table(fake_iris$Response)),
               c(setosa = 50, virginica = 50))
  expect_equal(colSums(data.matrix(fake_iris[, -5])),
               c(Sepal.Length = 578.116040897835,
                 Sepal.Width  = 324.023245121725,
                 Petal.Length = 354.799698728416,
                 Petal.Width  = 118.807070604898))
})
