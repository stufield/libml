#' Get Cutoff for a Given Specificity
#'
#' For a given specificity, [getCutoffSpec()] calculates the
#' corresponding cutoff (operating point) from a set of predictions.
#'
#' @inheritParams params
#' @param spec Numeric. The desired specificity.
#' @return A numeric cutoff representing the operating point
#'   for a given specificity.
#' @author Stu Field
#' @examples
#' n <- 20
#' withr::with_seed(22, {
#'   true <- sample(c("control", "disease"), n, replace = TRUE)
#'   pred <- runif(n)
#' })
#' getCutoffSpec(true, pred, 0.4, "disease")
#' @export
getCutoffSpec <- function(truth, predicted, spec, pos.class) {
  n_neg <- sum(truth != pos.class)
  tol   <- .Machine$double.eps^0.5    # account for underflow
  fp    <- 0

  for ( i in seq_along(truth) ) {
    if ( truth[i] != pos.class ) {
      fp <- fp + 1
    }
    if ( (1 - fp / n_neg) - spec < -tol ) {
      return(predicted[i - 1])
    }
  }
  stop("Unable to determine cutoff. Please check predicted values.", call. = FALSE)
}
