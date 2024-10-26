#' Calculate Binomial Confidence Interval
#'
#' Calculates the _joint_ binomial confidence interval based
#' on the binomial variance given the data. Uses normal
#' approximation of the binomial.
#'
#' @param p Numeric. The classification metric in \verb{[0, 1]}. Can also be a
#'   vector of values representing the metric of interest (sens or spec).
#' @param n Integer. The total number of counts in the denominator
#'   for the metric being calculated.
#' @param ci Numeric. The width of the confidence interval
#'   to be calculated. Must be within \verb{[0.5, 1]}.
#' @return A `tibble` object of the upper and lower binomial
#'   confidence limits corresponding to the value of `ci`.
#' @author Stu Field
#' @seealso [qnorm()]
#' @references Margaret Pepe. 2003. The Statistical Evaluation of Medical
#'   Tests for Classification and Prediction. (maybe?)
#' @examples
#' tp <- 16
#' fn <- 4
#' sens <- tp / (tp + fn)
#' calc_ci_binom(sens, tp + fn)
#' @importFrom stats qnorm
#' @importFrom tibble tibble
#' @export
calc_ci_binom <- function(p, n, ci = sqrt(0.95)) {
  if ( ci < 0.5 || ci > 1 ) {
    stop("Invalid confidence interval value. Must be in [0.5, 1.0].",
         call. = FALSE)
  }
  intv <- -qnorm((1 - ci) / 2) * sqrt(p * (1 - p) / n)
  ret  <- tibble(lower = p - intv, upper = p + intv)
  ret[ret < 0] <- 0
  ret[ret > 1] <- 1
  ret
}
