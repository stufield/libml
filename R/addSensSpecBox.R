#' Add a Sensitivity/Specificity Box
#'
#' Add a shaded box, typically to a ROC curve, that
#' corresponds to the 95% joint binomial confidence interval
#' of the sensitivity and specificity.
#'
#' Recall that the ROC curve is `1 - specificity`, therefore the
#' added box involves internally inverting the specificity limits
#' so that the interval matches the plot.
#'
#' @inheritParams params
#' @param x A \verb{2x2} data frame containing the lower and upper CI95
#'   joint confidence limits for sensitivity and specificity.
#'   A call to [calcJointCI95()] generates this matrix in the specified format.
#' @author Stu Field, Amanda Hiser
#' @examples
#' g <- ggplot2::ggplot(data.frame(x = 0.2, y = 0.8), ggplot2::aes(x = x, y = y)) +
#'   ggplot2::geom_point(shape = 18, size = 3) +
#'   ggplot2::lims(x = 0:1, y = 0:1) +
#'   ggplot2::labs(y = "Sensitivity", x = "1 - Specificity")
#' g
#'
#' @export
addSensSpecBox <- function(x, col = "black", alpha = 0.35) {
  add_box(left   = 1 - x[2L, 1L],
          right  = 1 - x[2L, 2L],
          bottom = x[1L, 1L],
          top    = x[1L, 2L],
          col    = col,
          alpha  = alpha)
}


#' Calculate Joint 95% CI
#'
#' Calculate the joint 95% confidence interval
#' given sensitivity and specificity.
#'
#' @rdname addSensSpecBox
#' @param sens Numeric. The sensitivity: \verb{[0, 1]}.
#' @param spec Numeric. The specificity: \verb{[0, 1]}.
#' @param n.controls Integer. Number of control or non-cases.
#' @param n.cases Integer. Number of cases/disease.
#' @return A \verb{2x2} matrix containing rows of sensitivity and
#'   specificity respectively and columns of lower and upper 95%
#'   joint confidence intervals respectively.
#' @author Mike Mehan
#' @seealso [calcBinomCI()]
#' @examples
#' # calculate CI95s for 80/80 sens/spec
#' ci95 <- calcJointCI95(0.8, 0.8, 35, 65)
#' ci95
#'
#' # unequal box due to class imbalance (65/35)
#' g + addSensSpecBox(ci95, col = "blue", alpha = 0.25)
#' @export
calcJointCI95 <- function(sens, spec, n.controls, n.cases) {
  rbind(sens = calcBinomCI(sens, n = n.cases),
        spec = calcBinomCI(spec, n = n.controls))
}


#' Adds a background box to an existing plot area.
#'
#' @noRd
#' @param bottom Value for the bottom of the box.
#' @param top Value for the top of the box.
#' @param left Value for the left side of the box.
#' @param right Value for the right side of the box.
#' @param col Color of the box.
#' @param alpha Shading value of the box, passed to [ggplot2::alpha()].
#' @author Stu Field, Amanda Hiser
#' @importFrom graphics par
#' @importFrom ggplot2 annotate
add_box <- function(bottom = NULL, top = NULL, left = NULL,
                    right = NULL, col, alpha) {
  par <- par("usr")   # nolint: undesirable_linter.
  bottom <- bottom %||% par[3L]
  left   <- left %||% par[1L]
  top    <- top %||% par[4L]
  right  <- right %||% par[2L]
  annotate("rect", xmin = left, xmax = right, ymin = bottom, ymax = top,
           fill = col, alpha = alpha)
}
