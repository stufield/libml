#' Get Distance Cutoffs
#'
#' For given true class names and predictions, calculate the maximal
#'   perpendicular distance to the unit line, its corresponding
#'   specificity, then the cutoff corresponding to that specificity.
#'
#' @name get-cutoffs
#'
#' @inheritParams params
#'
#' @return [get_max_cutoff()]: a numeric cutoff representing
#'   the operating point at the maximal perpendicular distance
#'   from the unit line.
#'
#' @author Stu Field
#' @seealso [calc_roc_perpendicular()], [roc_xy()]
#'
#' @examples
#' n <- 20
#' withr::with_seed(122, {
#'   true <- sample(c("control", "disease"), n, replace = TRUE)
#'   pred <- runif(n)
#' })
#' get_max_cutoff(true, pred, "disease")
#'
#' @export
get_max_cutoff <- function(truth, predicted, pos_class) {
  xy <- roc_xy(truth, predicted, pos_class)   # ROC c(x,y) for `points()`
  perp_dist <- apply(xy, 1, calc_roc_perpendicular)
  spec <- 1 - xy[, "x"]
  max_spec <- spec[which.max(perp_dist)]     # specificity at max perp
  get_spec_cutoff(truth, predicted, spec = max_spec, pos_class)
}

#' Get Cutoff for a Given Specificity
#'
#' For a given specificity, calculate the corresponding
#' cutoff (operating point) from a set of predictions.
#'
#' @rdname get-cutoffs
#'
#' @param spec `numeric(1)`. The desired specificity.
#'
#' @return [get_spec_cutoff()]: a numeric cutoff representing
#'   the operating point for a given specificity.
#'
#' @examples
#' # via specificity
#' get_spec_cutoff(true, pred, 0.4, "disease")
#' @export
get_spec_cutoff <- function(truth, predicted, spec, pos_class) {
  n_neg <- sum(truth != pos_class)
  tol   <- .Machine$double.eps^0.5 # fix underflow
  fp    <- 0

  for ( i in seq_along(truth) ) {
    if ( truth[i] != pos_class ) {
      fp <- fp + 1
    }
    if ( (1 - fp / n_neg) - spec < -tol ) {
      return(predicted[i - 1L])
    }
  }
  stop(
    "Unable to determine cutoff. Please check predicted values.",
    call. = FALSE
  )
}
