
# Setup ----
# with iris dataset (2-classes)
iris2 <- dplyr::filter(iris, Species != "versicolor") |> refactor_data()
nb2c <- fit_nb(Species ~ ., data = iris2)
nb2c_data <- fit_nb(Species ~ ., data = iris2, keep.data = TRUE)

# with full iris dataset (3-classes)
nb3c  <- fit_nb(Species ~ ., data = iris)
nb3cd <- fit_nb(Species ~ ., data = iris, keep.data = TRUE)

# Testing ----
test_that("the `fit_nb()` 2 class unit test generates expected output", {
  expect_s3_class(nb2c, "libml_nb")
  expect_false(nb2c$data)
  pars <- matrix(c(4.9440828, 6.4808605, 0.3338141, 0.5965711,
                   3.3557601, 2.8981603, 0.3621399, 0.2915487,
                   1.4085769, 5.4466972, 0.1485469, 0.5653423,
                   0.16971777, 1.96307633, 0.07082684, 0.30792673),
                 ncol = 4L)
  colnames(pars) <- c("Sepal.Length", "Sepal.Width",
                      "Petal.Length", "Petal.Width")
  expect_equal(vapply(nb2c$tables, function(.x) as.numeric(.x), double(4)), pars)
  expect_equal(sum(nb2c$apriori), 100)
  expect_named(nb2c$apriori, c("setosa", "virginica"))
  expect_s3_class(nb2c_data$data, "data.frame")
  expect_s3_class(nb2c_data, "libml_nb")
})

test_that("robust naiveBayes 3 class unit test", {
  expect_s3_class(nb3c, "libml_nb")
  pars <- matrix(c(4.9440828, 3.3557601, 1.4085769, 0.16971777,
                   5.8620749, 2.7373713, 4.2407807, 1.27408314,
                   6.4808605, 2.8981603, 5.4466972, 1.96307633,
                   0.3338141, 0.3621399, 0.1485469, 0.07082684,
                   0.5457867, 0.3140914, 0.4565049, 0.2025109,
                   0.5965711, 0.2915487, 0.5653423, 0.30792673),
                 ncol = 4, byrow = TRUE)
  colnames(pars) <- c("Sepal.Length", "Sepal.Width",
                      "Petal.Length", "Petal.Width")
  expect_equal(vapply(nb3c$tables, function(.x) as.numeric(.x), double(6)), pars)
  expect_equal(sum(nb3c$apriori), 150)
  expect_named(nb3c$apriori, c("setosa", "versicolor", "virginica"))
  expect_false(nb3c$data)
})

test_that("`libml_nb` predict method generates correct values", {
  preds <- c(2.583911e-22, 1.205645e-21, 9.252954e-23,
             1.319086e-21, 8.465865e-23, 1.740150e-16)
  expect_equal(head(predict(nb2c, iris2, type = "post"))[, 2L], preds)
  expect_equal(head(predict(nb2c, iris2, type = "post"))[, 1L], rep(1, 6L))
  # type param is identical b/w post & raw
  expect_equal(
    predict(nb2c, iris2),  # default: "raw"
    predict(nb2c, iris2, type = "post")
  )
})

test_that("the predict method `type = class` returns correct 2 class", {
  pred <- predict(nb2c, iris2, type = "class")
  expect_s3_class(pred, "factor")
  expect_length(pred, nrow(iris2))
  expect_equal(levels(pred), levels(iris2$Species))
  expect_equal(sum(pred == iris2$Species), 100)
})

test_that("the predict method `type = class` returns correct 3 class", {
  pred <- predict(nb3c, iris, type = "class")
  expect_s3_class(pred, "factor")
  expect_length(pred, nrow(iris))
  expect_equal(levels(pred), levels(iris$Species))
  expect_equal(sum(pred != iris$Species), 8)   # 8 incorrect predictions
})

test_that("`libml_nb` plot method unit test", {
  expect_error(plot(nb2c, plot.type = "log"))
  expect_error(plot(nb2c, plot.type = "plot"))
  expect_error(plot(nb3c, iris, plot.type = "log"))
  expect_error(plot(nb3cd, plot.type = "log"))
})
