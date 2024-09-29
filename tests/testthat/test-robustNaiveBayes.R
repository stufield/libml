
# Setup ----
# clean up
withr::defer({
  if ( file.exists("Rplots.pdf") ) unlink("Rplots.pdf", force = TRUE)
})

# with 2-class iris dataset
dat <- dplyr::filter(iris, Species != "versicolor") |> refactorData()
nb2 <- robustNaiveBayes(Species ~ ., data = dat)
nb.data <- robustNaiveBayes(Species ~ ., data = dat, keep.data = TRUE)

# with full iris dataset (3-classes)
nb3  <- robustNaiveBayes(Species ~ ., data = iris)
nb3d <- robustNaiveBayes(Species ~ ., data = iris, keep.data = TRUE)

# Testing ----
test_that("robustNaiveBayes 2 class unit test", {
  expect_s3_class(nb2, "robustNaiveBayes")
  expect_false(nb2$data)
  pars <- matrix(c(4.9440828, 6.4808605, 0.3338141, 0.5965711,
                   3.3557601, 2.8981603, 0.3621399, 0.2915487,
                   1.4085769, 5.4466972, 0.1485469, 0.5653423,
                   0.16971777, 1.96307633, 0.07082684, 0.30792673),
                 ncol = 4)
  colnames(pars) <- c("Sepal.Length", "Sepal.Width",
                      "Petal.Length", "Petal.Width")
  expect_equal(vapply(nb2$tables, function(.x) as.numeric(.x), double(4)), pars)
  expect_equal(sum(nb2$apriori), 100)
  expect_named(nb2$apriori, c("setosa", "virginica"))
  expect_s3_class(nb.data$data, "data.frame")
  expect_s3_class(nb.data, "robustNaiveBayes")
})

test_that("robust naiveBayes 3 class unit test", {
  expect_s3_class(nb3, "robustNaiveBayes")
  pars <- matrix(c(4.9440828, 3.3557601, 1.4085769, 0.16971777,
                   5.8620749, 2.7373713, 4.2407807, 1.27408314,
                   6.4808605, 2.8981603, 5.4466972, 1.96307633,
                   0.3338141, 0.3621399, 0.1485469, 0.07082684,
                   0.5457867, 0.3140914, 0.4565049, 0.2025109,
                   0.5965711, 0.2915487, 0.5653423, 0.30792673),
                 ncol = 4, byrow = TRUE)
  colnames(pars) <- c("Sepal.Length", "Sepal.Width",
                      "Petal.Length", "Petal.Width")
  expect_equal(vapply(nb3$tables, function(.x) as.numeric(.x), double(6)), pars)
  expect_equal(sum(nb3$apriori), 150)
  expect_named(nb3$apriori, c("setosa", "versicolor", "virginica"))
  expect_false(nb3$data)
})


test_that("robust naiveBayes predict method generates correct values", {
  votes <- c(2.583911e-22, 1.205645e-21, 9.252954e-23,
             1.319086e-21, 8.465865e-23, 1.740150e-16)
  expect_equal(head(predict(nb2, dat, type = "post"))[, 2], votes)
  expect_equal(head(predict(nb2, dat, type = "post"))[, 1], rep(1, 6))
})


test_that("Predict method `type = class` gives correct class with 2 classes", {
  pred <- predict(nb2, dat, type = "class")
  expect_s3_class(pred, "factor")
  expect_length(pred, nrow(dat))
  expect_equal(levels(pred), levels(dat$Species))
  expect_equal(sum(pred == dat$Species), 100)
})

test_that("Predict method `type = class` gives correct class with 3 classes", {
  pred <- predict(nb3, iris, type = "class")
  expect_s3_class(pred, "factor")
  expect_length(pred, nrow(iris))
  expect_equal(levels(pred), levels(iris$Species))
  expect_equal(sum(pred != iris$Species), 8)   # 8 incorrect predictions
})

test_that("robust naiveBayes plotting unit test", {
  expect_error(plot(nb2, plot.type = "log"))
  expect_error(plot(nb2, plot.type = "plot"))
  expect_error(plot(nb3, iris, plot.type = "log"))
  expect_error(plot(nb3d, plot.type = "log"))
})
