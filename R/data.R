#' Iris Data Set as Training Data
#'
#' Generate a fake `tr_data` object based on the
#'   [datasets::iris] data set for use in
#'   examples sections of the libml package. First, the
#'   `versicolor` class observations are removed to make
#'   the result binary, then half (`n = 50`) of the observations
#'   are class scrambled, and the feature data is "jittered"
#'   to add some noise. This was because the original
#'   iris data set has a distinct decision boundary across the
#'   4 features, making classification examples "too" perfect.
#'   The format is a 4 feature + 1 class variable "tibble"
#'   object recast as a `tr_data` object.
#'   Contains 50 setosa and 50 virginica samples.
#'
#' @note This is the same as `fake_iris` pre-existing object.
#' @aliases fake_iris
#'
#' @references Fisher, R. A. (1936) The use of multiple
#'   measurements in taxonomic problems. *Annals of Eugenics*, **7**,
#'   Part II, 179-188.
#'   The data were collected by Anderson, Edgar (1935). The irises of
#'   the Gaspe Peninsula, *Bulletin of the American Iris Society*, **59**, 2-5.
#'
#' @examples
#' \dontrun{
#'   ?iris
#' }
#'
#' # print
#' tr_iris
"tr_iris"
