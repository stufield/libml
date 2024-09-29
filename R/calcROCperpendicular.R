#' Calculate Perpendicular Distance
#'
#' In receiver operating criterion curves, calculate the
#' optimal operating point for a binary test given a series of
#' `(x, y)` coordinates of the ROC curve, by calculating the
#' _perpendicular_ distance between the curve and the unit (`x = y`) line.
#' The Youden distance is similar but differs in that it corresponds
#' to the _vertical_ distance between the ROC curve and the unit
#' line, see [createROCdata()].
#'
#' @family ROC
#' @param xy `numeric(2)`. An `(x, y)` coordinate on the ROC curve.
#' @return
#'   \item{[calcROCperpendicular()]}{the perpendicular distance between the
#'                                   curve and the unit line.}
#'   \item{[calcROCcorner()]}{the distance from the ROC curve to the
#'                            top-left corner of the ROC.}
#' @author Stu Field, Shintaro Kato
#' @note Differs slightly from the Youden Index (J), see [createROCdata()].
#' @seealso [stats::dist()]
#' @references Schisterman, et al. 2005. Optimal Cut-point and
#'   its Corresponding Youden Index to Discriminate Individuals Using
#'   Pooled Blood Samples. Epidemiology. 16: 73-81.
#' @importFrom stats dist
#' @export
calcROCperpendicular <- function(xy) {
  stopifnot(
    is.numeric(xy),
    length(xy) == 2L,
    sum(xy, na.rm = TRUE) <= 2,
    sum(xy, na.rm = TRUE) >= 0
  )
  as.numeric(dist(rbind(xy, rep(sum(xy) / 2, 2) ), method = "euclidean"))
}


# Calculate Corner Distance

#' @describeIn calcROCperpendicular
#' An alternative optimal operating point is the _minimal_ distance
#'   from the ROC curve to the \verb{(0, 1)} point of the operating space,
#'   the "top-left" corner.
#' @export
calcROCcorner <- function(xy) {
  stopifnot(
    is.numeric(xy),
    length(xy) == 2L,
    sum(xy, na.rm = TRUE) <= 2,
    sum(xy, na.rm = TRUE) >= 0
  )
  as.numeric(dist(rbind(xy, c(0, 1)), method = "euclidean"))
}
