#' Calculate Sorted Gini Importance
#'
#' Generate a table of sorted Gini importance
#'   scores for a random forest model.
#'
#' @param rf.model A random forest model object (see \pkg{randomForest}).
#'
#' @return A `tibble` of the sorted importance(s). `MeanDecreaseAccuracy` is
#'   the mean decrease in accuracy resulting from removing the feature.
#'
#' @author Stu Field
#' @seealso [randomForest()]
#'
#' @examples
#' # Use tr_iris training data from iris data set
#' rf <- withr::with_seed(101, {
#'   randomForest::randomForest(
#'     Species ~ ., data = tr_iris, importance = TRUE,
#'     proximity = TRUE, keep.inbag = TRUE)
#' })
#' get_gini(rf)
#' @importFrom tibble as_tibble
#' @export
get_gini <- function(rf.model) {
  stopifnot(
    "Model must be a random forest model." = inherits(rf.model, "randomForest")
  )
  gini <- as_tibble(rf.model$importance, rownames = "Feature")
  names(gini) <- gsub("^MeanDecreaseGini$", "Gini_Importance", names(gini))
  if ( nrow(gini) > 1L ) {
    gini <- dplyr::arrange(gini, dplyr::desc(Gini_Importance))
  }
  if ( ncol(gini) > 1L ) {
    gini <- dplyr::select(gini, Feature, Gini_Importance, dplyr::everything())
  }
  gini
}
