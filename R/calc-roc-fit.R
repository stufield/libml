#' Calculate ROC Curve Parameters
#'
#' Use non-linear least squares to calculate the parameters
#'   \eqn{\alpha, \beta} necessary to draw a ROC curve from
#'   empirical data. The objective function assumed is of the form:
#'     \deqn{y \sim 1 - (1 - x^\beta)^{(1/\alpha)}}{y ~ 1 - (1 - x^beta)^(1/alpha)}
#'     \deqn{ \alpha \in (0, 1]}{alpha in (0, 1]}
#'     \deqn{ \beta \in (0, 1]}{beta in (0, 1]}
#'     \deqn{ x \in (0, 1]}{x in (0, 1]}
#' \cr
#'   where the extreme x-values (0 and 1) are on the `y = x` equilibrium line.
#'
#' @family ROC
#'
#' @param xy A data frame containing "x" (1 - tnr) and "y" (tpr)
#'   coordinates of an empirical ROC curve. This is typically
#'   the return value of a call to [roc_xy()].
#' @param optim `character(1)`. Either "ML" or "LS" indicating whether
#'   Maximum Likelihood (default) or Non-linear Least Squares should
#'   be used in the optimization.
#' @param start `numeric(2)`. A *named* vector of initial start
#'   values for \eqn{\alpha} and \eqn{\beta}.
#'   \eqn{\alpha} is the cost of a false positive and \eqn{\beta} is
#'   the cost of a false negative.
#'
#' @return Model estimates of \eqn{\alpha} and \eqn{\beta}.
#'
#' @author Stu Field
#' @seealso [nls()], [optim()], [roc_xy()]
#'
#' @examples
#' n    <- 15
#' true <- rep(c("control", "case"), each = n)
#' pred <- withr::with_seed(1, c(rnorm(n, 0.45, 0.2), rnorm(n, 0.65, 0.2)))
#'
#' rocxy <- data.frame(roc_xy(true, pred, pos.class = "case"))
#' calc_roc_fit(rocxy)        # Max Lik
#' calc_roc_fit(rocxy, "LS")  # Least Squares
#'
#' # ML with new starting values
#' calc_roc_fit(rocxy, start = c(alpha = 0.3, beta = 0.6))
#'
#' # See the fit through the fitted values
#' ggplot2::ggplot(rocxy, ggplot2::aes(x = x, y = y)) +
#'   geom_roc(shape = 19, size = 2) +
#'   geom_rocfit(data = rocxy, col = "blue")
#' @importFrom stats nls optim dnorm nls.control coef
#' @export
calc_roc_fit <- function(xy, optim = c("ML", "LS"),
                       start = c(alpha = 0.5, beta = 0.5)) {

  optim <- match.arg(optim)
  xy <- data.frame(xy)
  xy <- xy[!(abs(xy$x - 1) < 1e-06), ] # exclude x=1 limit case --> x in [0, 1)
                                       # for model convergence

  with(xy, {    # local attach()
    if ( optim == "ML" ) {
      # nolint next: object_usage_linter.
      loglik <- function(theta) {   # -loglikelihood function
        alpha <- theta["alpha"]
        beta  <- theta["beta"]
        pwr   <- 1 / alpha
        ymean <- 1 - (1 - x^beta)^pwr
        n     <- length(x)
        -sum(dnorm(y, mean = ymean, sd = sd(y - ymean) * (n - 1) / n,
                   log = TRUE))
      }
      tryCatch(optim(start, loglik, lower = c(0, 0), upper = c(1, 1),
                     method = "L-BFGS-B")$par,
               error = function(e) NULL)

    } else {
      tryCatch(coef(
                 nls(y ~ 1 - (1 - x^beta)^(1 / alpha),
                     start = as.list(start), lower = c(0, 0), upper = c(1, 1),
                     algorithm = "port",
                     control = nls.control(maxiter   = 2000,
                                           minFactor = 1 / 1024,
                                           warnOnly  = TRUE))),
               error = function(e) NULL)
    }
  })
}
