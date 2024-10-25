#' Get Maximal Distance Cutoff
#'
#' For given true class names and predictions, calculate the maximal
#' perpendicular distance to the unit line, its corresponding
#' specificity, then the cutoff corresponding to that specificity.
#'
#' @inheritParams params
#' @return A numeric cutoff representing the operating point
#'   at the maximal perpendicular distance from the unit line.
#' @author Stu Field
#' @seealso [getCutoffSpec()], [calc_roc_perpendicular()], [roc_xy()]
#' @examples
#' n <- 20
#' withr::with_seed(122, {
#'   true <- sample(c("control", "disease"), n, replace = TRUE)
#'   pred <- runif(n)
#' })
#' getCutoffMax(true, pred, "disease")
#' @export
getCutoffMax <- function(truth, predicted, pos.class) {
  xy <- roc_xy(truth, predicted, pos.class)   # ROC c(x,y) for `points()`
  perp_dist <- apply(xy, 1, calc_roc_perpendicular)
  spec <- 1 - xy[, "x"]
  max_spec <- spec[which.max(perp_dist)]     # specificity at max perp
  getCutoffSpec(truth, predicted, spec = max_spec, pos.class)
}
