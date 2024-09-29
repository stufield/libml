#' Plot a Naive Bayes Decision Boundary
#'
#' Plots the bivariate curved decision boundary for a naive
#' Bayes classifier/model for _two_ features.
#'
#' @inheritParams params
#' @param data A `data.frame` object containing 3 columns:
#'   \enumerate{
#'     \item __F1__: values for the first feature (x-axis).
#'     \item __F2__: values for the second feature (y-axis).
#'     \item __class__: vector of the response classes as a factor.
#'   }
#' @param res Integer. The resolution for the plot. Higher
#'   resolutions require more computation time.
#' @author Stu Field
#' @seealso [geom_contour()], [robustNaiveBayes()]
#' @examples
#' data <- data.frame(F1    = fake_iris$Petal.Length,
#'                    F2    = fake_iris$Sepal.Length,
#'                    class = fake_iris$Response)
#' head(data)
#' plotBivariateBayesBoundary(data, pos.class = "virginica")
#' @importFrom stats predict
#' @importFrom ggplot2 aes ggplot geom_contour geom_raster
#' @importFrom ggplot2 geom_point labs scale_fill_gradient scale_color_manual
#' @export
plotBivariateBayesBoundary <- function(data, pos.class, res = 50, main = NULL) {
  stopifnot(ncol(data) == 3L, is.numeric(res))
  train <- data |>
    dplyr::rename_if(is.factor, function(.x) "class") |> # rename response
    dplyr::rename_at(1:2, function(.x) c("F1", "F2"))    # rename features 1,2
  train$class <- factor(train$class,    # pos.class 2nd
                        levels = c(setdiff(train$class, pos.class), pos.class))
  model <- robustNaiveBayes(class ~ F1 + F2, data = train)

  df <- expand_grid(
    list(F1 = seq(min(train$F1), max(train$F1), length = res),
         F2 = seq(min(train$F2), max(train$F2), length = res))
  )
  df$Pr <- predict(model, newdata = df, type = "posterior")[, 2L]

  p <- ggplot(df, aes(x = F1, y = F2))
  p + geom_raster(aes(fill = Pr), alpha = 0.5) +
    geom_contour(aes(x = F1, y = F2, z = Pr), binwidth = 0.5,
                 color = "navy", linetype = "dashed") +
    scale_fill_gradient(low  = SomaPlotr::soma_colors2$teal,
                        high = SomaPlotr::soma_colors2$purple) +
    geom_point(data = train, mapping = aes(x = F1, y = F2, color = class),
               size = 2.5, alpha = 0.5) +
    scale_color_manual(values = c(SomaPlotr::soma_colors2$teal,
                                  SomaPlotr::soma_colors2$purple)) +
    geom_point(data = train, aes(x = F1, y = F2),
               size = 2.5, shape = 21, color = "black") +
    labs(x = "Feature 1", y = "Feature 2", title = main) +
    SomaPlotr::theme_soma(base_size = 12)
}
