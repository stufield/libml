#' Plot a Naive Bayes Decision Boundary
#'
#' Plots the bivariate curved decision boundary for a naive
#'   Bayes classifier/model for *two* (bivariate) features.
#'
#' @inheritParams params
#'
#' @param data A `data.frame` object containing 3 columns:
#'   \enumerate{
#'     \item __F1__: values for the first feature (x-axis).
#'     \item __F2__: values for the second feature (y-axis).
#'     \item __class__: vector of the response classes as a factor.
#'   }
#' @param res `integer(1)`. The resolution for the plot. Higher
#'   resolutions require more computation time.
#'
#' @author Stu Field
#' @seealso [geom_contour()], [fit_nb()]
#'
#' @examples
#' data <- data.frame(F1    = tr_iris$Petal.Length,
#'                    F2    = tr_iris$Sepal.Length,
#'                    class = tr_iris$Species)
#' head(data)
#' plot_bayes_boundary(data, pos_class = "virginica")
#' @importFrom stats predict
#' @importFrom ggplot2 aes ggplot geom_contour geom_raster
#' @importFrom ggplot2 geom_point labs scale_fill_gradient scale_color_manual
#' @export
plot_bayes_boundary <- function(data, pos_class, res = 50L, main = NULL) {
  stopifnot(
    "`data` must have at *least* 3 columns to plot." = ncol(data) == 3L,
    "`res` must be integer."                         = is_int(res)
  )
  train <- data |>
    dplyr::rename_if(is.factor, function(.x) "class") |> # rename response
    dplyr::rename_at(1:2L, function(.x) c("F1", "F2"))   # rename features 1,2
  train$class <- factor(train$class,    # pos_class 2nd
                        levels = c(setdiff(train$class, pos_class), pos_class))
  model <- fit_nb(class ~ F1 + F2, data = train)

  df <- expand_grid(
    list(F1 = seq(min(train$F1), max(train$F1), length = res),
         F2 = seq(min(train$F2), max(train$F2), length = res))
  )
  df$Pr <- predict(model, newdata = df, type = "posterior")[, 2L]

  p <- ggplot(df, aes(x = F1, y = F2))
  p + geom_raster(aes(fill = Pr), alpha = 0.5) +
    geom_contour(aes(x = F1, y = F2, z = Pr), binwidth = 0.5,
                 color = "navy", linetype = "dashed") +
    scale_fill_gradient(low  = col_palette$lightgreen,
                        high = col_palette$purple) +
    geom_point(data = train, mapping = aes(x = F1, y = F2, color = class),
               size = 2.5, alpha = 0.5) +
    scale_color_manual(values = c(col_palette$lightgreen,
                                  col_palette$purple)) +
    geom_point(data = train, aes(x = F1, y = F2),
               size = 2.5, shape = 21, color = "black") +
    labs(x = "Feature 1", y = "Feature 2", title = main) +
    SomaPlotr::theme_soma(base_size = 12)
}
