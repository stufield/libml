# Setup ----
tr <- createTrainingData(sample.adat, SampleGroup %in% c("M", "F"))

# Testing ----
test_that("`createTrainingData()` can use quoted or unquoted `group.var` argument", {
  expect_error_free(
    createTrainingData(sample.adat, SampleGroup %in% c("M", "F"),
                       group.var = "SampleGroup")
  )
  expect_equal(
    createTrainingData(datasets::iris, group.var = "Species"),
    createTrainingData(datasets::iris, group.var = Species)
  )
  expect_equal(
    createTrainingData(sample.adat, SampleGroup %in% c("M", "F"),
                        group.var = "SampleGroup"),
    createTrainingData(sample.adat, SampleGroup %in% c("M", "F"),
                       group.var = SampleGroup)
  )
})

test_that("the `createTrainingData()` function generates correct object", {
  expect_s3_class(tr, "tr_data")
  expect_s3_class(tr, "soma_adat")
  expect_s3_class(tr, "grouped_df")
  expect_s3_class(tr, "tbl_df")
  expect_true("Response" %in% names(tr))
  ord_rn <- rownames(sample.adat)[order(sample.adat$SampleGroup)]
  expect_equal(rownames(tr), ord_rn)
  expect_equal(class(tr), c("tr_data", "soma_adat", "grouped_df",
                            "tbl_df", "tbl", "data.frame"))
  expect_equal(c(table(tr$Response)), c(`F` = 11, `M` = 9))
  expect_equal(dim(tr), c(20L, 1145L))
  expect_equal(dim(tr), dim(sample.adat) + c(0, 1))   # add 1 column Response
  expect_equal(dplyr::group_vars(tr), "Response")
  expect_equal(group_labels(tr)$Response, factor(c("F", "M")))
  atts      <- attributes(tr)
  att_names <- c(names(attributes(sample.adat)), "groups")  # same atts + "groups"
  expect_named(atts, att_names)
  expect_equal(as.list(dplyr::group_rows(tr)), list(1:11, 12:20))
  expect_equal(dplyr::group_rows(tr), atts$groups$.rows)
  expect_equal(atts$groups$Response, dplyr::group_data(tr)$Response, ignore_attr = TRUE)
  expect_equal(atts$groups$.rows, dplyr::group_data(tr)$.rows, ignore_attr = TRUE)
  expect_s3_class(atts$groups, "tbl_df")
  expect_equal(atts$names, c(names(sample.adat), "Response"))
})

test_that("the `convert2TrainingData()` function converts properly", {
  irisTR <- convert2TrainingData(datasets::iris, Species)
  expect_s3_class(irisTR, "tr_data")
  expect_s3_class(irisTR, "grouped_df")
  expect_s3_class(irisTR, "tbl_df")
  expect_true("Response" %in% names(irisTR))
  expect_true(all(rownames(irisTR) %in% seq_len(nrow(iris))))
  expect_equal(c(table(irisTR$Response)), c(setosa = 50,
                                            versicolor = 50,
                                            virginica = 50))
  expect_equal(dim(irisTR), c(150L, 6L))
  expect_equal(dim(irisTR), dim(iris) + c(0, 1L))
  expect_named(irisTR, c("Sepal.Length", "Sepal.Width",
                         "Petal.Length", "Petal.Width",
                         "Species", "Response"))
  # 'soma_adat'
  TR <- convert2TrainingData(sample.adat, SampleGroup)
  expect_s3_class(TR, "tr_data")
  expect_s3_class(TR, "grouped_df")
  expect_s3_class(TR, "tbl_df")
  expect_true("Response" %in% names(TR))
  # ensure same as `createTrainingData()`
  expect_equal(TR, tr)
})

test_that("`convert2TrainingData()` can use quoted and unquoted `group.var` argument", {
  expect_equal(convert2TrainingData(datasets::iris, "Species"),
               convert2TrainingData(datasets::iris, Species))
})
