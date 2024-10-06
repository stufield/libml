
test_that("the `tr_iris` data set is correct and of the right form", {
  expect_s3_class(tr_iris, "tr_data")
  expect_s3_class(tr_iris, "tbl_df")
  expect_equal(dim(tr_iris), c(100, 5L))
  expect_equal(c(table(tr_iris$Species)), c(setosa = 50, virginica = 50))
  expect_equal(colSums(data.matrix(tr_iris[, -5L])),
               c(Sepal.Length = 578.11604089784,
                 Sepal.Width  = 324.02324512172,
                 Petal.Length = 354.79969872842,
                 Petal.Width  = 118.80707060490))
  expect_named(attributes(tr_iris),
               c("names", "row.names", "response_var", "is_factor",
                 "counts", "class_labels", "n_groups", "class"))
  expect_equal(c(table(tr_iris$Species)), attr(tr_iris, "counts"))
  expect_equal(2, attr(tr_iris, "n_groups"))
  expect_equal(c("setosa", "virginica"), attr(tr_iris, "class_labels"))
  expect_true(attr(tr_iris, "is_factor"))
  expect_equal("Species", attr(tr_iris, "response_var"))
})
