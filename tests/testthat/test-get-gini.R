
# Setup ----
gini <- withr::with_seed(101, {
  randomForest::randomForest(
    Species ~ ., data = tr_iris, importance = TRUE,
    proximity = TRUE, keep.inbag = TRUE) |> get_gini()
})

# Testing ----
test_that("the returned object is the correct size and shape", {
  expect_s3_class(gini, "tbl_df")
  expect_equal(dim(gini), c(4L, 5L))
  true <- data.frame(stringsAsFactors = FALSE,
                  Feature = c("Sepal.Length",
                              "Petal.Width",
                              "Petal.Length",
                              "Sepal.Width"),
          Gini_Importance = c(14.5558039613695,
                              14.0043655790973,
                              11.6656496099034,
                              9.20334084962966),
                   setosa = c(0.0584938597005214,
                              0.0381691786471407,
                              0.0364739574963407,
                              0.0107142527209259),
                virginica = c(0.0898560721091426,
                              0.0434587011870636,
                              -0.00260719162995512,
                              0.00967158407545204),
     MeanDecreaseAccuracy = c(0.0725938615186959,
                              0.0395122974644968,
                              0.0153458534750518,
                              0.00981778626487738)
  )
  expect_equal(data.frame(gini), true)
})
