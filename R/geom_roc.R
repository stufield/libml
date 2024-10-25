#' Plot a ROC Curve
#'
#' Create a \verb{"geom"} layer to generate a receiver operator criterion (ROC)
#'   curve in the \pkg{ggplot2} style grammar of graphics.
#'   Its primary input is the output of [roc_xy()], and is used
#'   primarily used in support of the wrapper [plotEmpROC()].
#'
#' @inheritParams ggplot2::geom_line
#' @family ROC
#' @param data A `data.frame` containing "x" and "y" coordinates corresponding
#'   to an empirical ROC curve. This is result of a call to [roc_xy()], and
#'   corresponds to the `1 - "tnr"` and `"tpr"` values respectively.
#' @param lwd Line width. See [par()].
#' @param shape Numeric. Shape of points. Must be a number between 0 and 25,
#'   similar to `pch` of [graphics::points()]. See [geom_point()].
#' @param size Numeric. Size of points. Similar to `cex` of [graphics::points()].
#'   Modifying `size` will not affect the plot if `shape` is set to
#'   `NULL` (the default). See [geom_point())].
#' @param outline Logical. Should black outlines be drawn around the main plot line?
#' @param ... Additional arguments passed to [layer()], often `lty`, `shape`,
#'   `lwd`, etc.
#' @author Stu Field, Amanda Hiser
#' @seealso [roc_xy()], [calc_roc_fit()], [geom_line()], [layer()]
#' @examples
#' library(ggplot2)
#'
#' # Generate dummy data
#' true <- rep(c("control", "disease"), each = 10)
#' pred <- withr::with_seed(8,
#'   c(rnorm(10, mean = 0.4, sd = 0.2),
#'     rnorm(10, mean = 0.6, sd = 0.2))
#' )
#' rocxy <- roc_xy(true, pred, "disease") |> data.frame()
#'
#' # Plotting options
#' ggplot(rocxy, aes(x = x, y = y)) + geom_roc()
#' ggplot(rocxy, aes(x = x, y = y)) + geom_roc(col = "blue")
#' ggplot(rocxy, aes(x = x, y = y)) + geom_roc(col = "blue", outline = FALSE)
#'
#' # Draw a fit line with `geom_rocfit()`
#' # (to add a fit-layer, you *must* pass the data argument)
#' ggplot(rocxy, aes(x = x, y = y)) + geom_rocfit(data = rocxy)
#'
#' # Layer a fit line over a ROC curve
#' ggplot(rocxy, aes(x = x, y = y)) +
#'   geom_roc(col = "blue") +
#'   geom_rocfit(data = rocxy, col = "red", linetype = "dashed")
#'
#' # Multiple curves can be drawn on the same plot.
#' # First, generate a 2nd set of dummy data
#' true2 <- rep(c("control", "disease"), each = 20)
#' pred2 <- withr::with_seed(9,
#'   c(rnorm(20, mean = 0.4, sd = 0.2),
#'     rnorm(20, mean = 0.8, sd = 0.2))
#' )
#'
#' # Cast input to a data frame (this is required for ggplot)
#' rocxy2 <- roc_xy(true2, pred2, "disease") |> data.frame()
#'
#' # The 2nd line can be added via standard `+` ggplot2 syntax,
#' # but the data argument must be passed for each geom, as each curve was
#' # generated from a unique dataset
#' ggplot() +
#'   geom_roc(aes(x = x, y = y), data = rocxy, col = "red") +
#'   geom_roc(aes(x = x, y = y), data = rocxy2, col = "blue")
#' @importFrom ggplot2 geom_abline geom_line geom_function layer
#' @importFrom ggplot2 theme element_line element_blank
#' @export
geom_roc <- function(mapping = NULL, data = NULL, stat = "identity",
                     position = "identity", na.rm = FALSE, shape = NULL,
                     size = 2, lwd = 1, outline = TRUE, show.legend = NA,
                     inherit.aes = TRUE, ...) {

  if ( is.matrix(data) ) {
    data <- data.frame(data)
  }

  p <- layer(
    geom = ggplot2::GeomLine, mapping = mapping,
    data = data, stat = stat, position = position,
    show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(na.rm = na.rm, lwd = lwd, ...)
  )

  if ( outline ) {
    p <- c(
      layer(
        geom = ggplot2::GeomLine, mapping = mapping,
        data = data, stat = stat, position = position,
        params = list(color = "black", lwd = lwd * 1.5)
      ),
      p
    )
  }

  if ( !is.null(shape) ) {
    if ( shape > 25 ) {
      stop("`shape` must be a numeric in [0, 25], similar to `pch`.",
           call. = FALSE)
    }
    p <- c(p,
           layer(
             geom = ggplot2::GeomPoint, mapping = mapping,
             data = data, stat = stat, position = position,
             params = list(shape = shape, size = size, color = "black")
           )
    )
  }
  p
}

#' @describeIn geom_roc
#'   Add a fitted line (layer) to ROC.
#' @export
geom_rocfit <- function(mapping = NULL, data = NULL, stat = "identity",
                        position = "identity", ...) {
  if ( is.null(data) ) {
    stop("Must pass `data =` when calling `geom_rocfit()`", call. = FALSE)
  }
  pars <- calc_roc_fit(data, "ML")
  # Attempts Least-Squares method if MaxLik didn't converge
  if ( is.null(pars) ) {
    pars <- calc_roc_fit(data, "LS")
  }
  # Define function to be used for plotting fit
  .rocFun <- function(x, alpha, beta) {
    1 - (1 - x^beta) ^ (1 / alpha)
  }
  geom_function(mapping = mapping, position = position,
                fun = .rocFun, args = as.list(pars), ...)
}


