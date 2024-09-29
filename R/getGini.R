#' Calculate Sorted Gini Importance
#'
#' Generate a table of sorted Gini importance scores for a
#' random forest model.
#'
#' @param rf.model A random forest model object, class `randomForest`.
#' @return A `tibble` of the sorted importance(s). `MeanDecreaseAccuracy` is
#'   the mean decrease in accuracy resulting from removing the feature.
#' @author Stu Field
#' @seealso [randomForest()]
#' @examples
#' # Use fake_iris training data from iris data set
#' library(randomForest)
#' rf <- withr::with_seed(101, {
#'   randomForest(Response ~ ., data = fake_iris, importance = TRUE,
#'                proximity = TRUE, keep.inbag = TRUE)
#' })
#' getGini(rf)
#' @importFrom tibble as_tibble
#' @export
getGini <- function(rf.model) {
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
