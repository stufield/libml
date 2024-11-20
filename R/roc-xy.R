#' ROC Curve Coordinates
#'
#' Calculate the the \verb{(x, y)} coordinates of an empirical ROC curve.
#'
#' This algorithm was adapted from the one in Fawcett (2006)
#'   to account to a more accurate step calculation of indices
#'   with ties. The original paper suggests moving along the
#'   diagonal when tied according to the _expected_ sensitivity
#'   and specificity, however this does not account for ties
#'   that occur _within_ the same class, in which case a walk
#'   along the edge of the "unknown" box is the correct decision. In
#'   this algorithm, a step in the diagonal only occurs if there is
#'   a tie _and_ the current class name differs from the previous.
#'   Otherwise, a full step occurs in the appropriate direction, up
#'   for positive classes, right for negative classes.
#'
#' @family ROC
#'
#' @inheritParams params
#'
#' @return A matrix containing the `x` and `y` coordinates for the
#'   ROC curve. A matrix is preferred over a data frame for speed of indexing
#'   while iterating over the rows and having to convert between classes.
#'   Downstream code will often convert to data frame while the main AUC
#'   functionality prefers a matrix.
#'
#' @author Stu Field
#' @seealso [plot_emp_roc()], [create_roc_data()]
#'
#' @references Fawcett, Tom. 2006. An introduction to ROC analysis. Pattern
#'   Recognition Letters. 27:861-874.
#'
#' @examples
#' n <- 25
#' withr::with_seed(22, {
#'   true <- sample(c("control", "disease"), n, replace = TRUE)
#'   pred <- runif(n)
#' })
#' xy <- roc_xy(true, pred, "disease")
#' xy
#'
#' # simple plotting
#' ggplot2::ggplot(data.frame(xy), ggplot2::aes(x = x, y = y)) +
#'   geom_roc(outline = FALSE, shape = 19)
#' @export
roc_xy <- function(truth, predicted, pos_class) {
  stopifnot(
    length(truth) == length(predicted),
    pos_class %in% truth
  )

  if ( is.factor(truth) && typeof(pos_class) == "character" ) {
    truth <- as.character(truth)    # assume user intent is character
  }

  if ( typeof(truth) != typeof(pos_class) ) {
    warning(
      "You are passing un-matched types: ",
      "truth = ", value(typeof(truth)), " vs. ",
      "pos_class = ", value(typeof(pos_class)), ". ",
      "Matched types is safer and more robust.",
      call. = FALSE
    )
  }

  if ( length(unique(truth)) != 2L ) {
    stop(
      "Class labels are not binary. All disease? All control? 3 or more classes?\n",
      value(unique(truth)), call. = FALSE
    )
  }
  ord <- order(predicted, decreasing = TRUE)   # ord indices
  # must pre-order class names by decreasing prediction
  # for input into `roc_xy_cpp()`
  roc_xy_cpp(truth[ord], predicted[ord], as.character(pos_class))
}
