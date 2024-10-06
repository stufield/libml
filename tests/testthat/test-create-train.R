# Setup ----
classes <- c("setosa", "versicolor")

# Testing ----
test_that("`create_train()` can use quoted or unquoted `group.var` argument", {
  expect_error(
    create_train(iris),
    "The `group.var` param must be passed."
  )
  expect_identical(
    create_train(iris, Species %in% classes, group.var = Species),
    create_train(iris, Species %in% classes, group.var = "Species")
  )
})

test_that("the `create_train()` function generates correct object", {
  tr <- create_train(iris, Species %in% classes, group.var = Species)
  expect_s3_class(tr, "tr_data")
  expect_s3_class(tr, "tbl_df")
  expect_true("Species" %in% names(tr))
  expect_equal(class(tr), c("tr_data", "tbl_df", "tbl", "data.frame"))
  expect_equal(c(table(tr$Species)), attr(tr, "counts"))
  expect_equal(dim(tr), c(100L, 5L))
  expect_equal(ncol(tr), ncol(iris))   # no new columns added
  expect_equal(.get_response(tr), "Species")
  expect_equal(attr(tr, "class_labels"), c("setosa", "versicolor"))
  expect_equal(attr(tr, "counts"), c(setosa = 50, versicolor = 50))
  expect_equal(attr(tr, "counts"), c(table(tr$Species)))
  expect_true(attr(tr, "is_factor"))
})

test_that("the `create_train()` function converts properly", {
  irisTR <- create_train(iris, group.var = Species)
  expect_s3_class(irisTR, "tr_data")
  expect_s3_class(irisTR, "tbl_df")
  expect_true("Species" %in% names(irisTR))
  expect_true(all(rownames(irisTR) %in% seq_len(nrow(iris))))
  expect_equal(c(setosa = 50, versicolor = 50, virginica = 50),
               attr(irisTR, "counts"))
  expect_equal(dim(irisTR), c(150L, 5L))
  expect_named(irisTR, c("Sepal.Length", "Sepal.Width",
                         "Petal.Length", "Petal.Width", "Species"))
})


test_that("the `create_train()` classes argument function properly", {
  # should reclass levels of Species
  expect_no_message(
    tr1 <- create_train(iris, Species %in% classes, group.var = Species,
                        classes = classes)
  )
  atts1 <- attributes(tr1)
  expect_equal(atts1$class_labels, classes)
  expect_equal(.get_response(tr1), "Species")
  expect_true(atts1$is_factor, classes)
  expect_equal(atts1$counts, c(setosa = 50, versicolor = 50))

  expect_message(
    tr2 <- create_train(iris, Species %in% classes, group.var = Species,
                        classes = rev(classes)),
    "Class order is non-alphabetic: 'versicolor > setosa'"
  )
  atts2 <- attributes(tr2)
  expect_equal(atts2$class_labels, rev(classes))
  expect_equal(.get_response(tr2), "Species")
  expect_true(atts2$is_factor, classes)
  expect_equal(atts2$counts, c(versicolor = 50, setosa = 50))
})

test_that("the `create_train()` S3 print method generates expected output", {
  expect_snapshot_output(
    create_train(iris, Species %in% classes, group.var = Species)
  )
})
