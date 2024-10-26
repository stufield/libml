#' Create ROC Data Table
#'
#' Create a data frame of ROC performance at various
#'   predefined operating points or cutoffs, one row
#'   per cutoff evaluation.
#'
#' @family ROC
#' @inheritParams params
#' @param cutoffs Various cutoffs at which to evaluate performance.
#' @param do.ci Logical. Should binomial confidence limits be
#'   calculated and added to the return value.
#' @param include.auc Logical. Should AUC also be calculated and added as a
#'   column to the returned data frame.
#' @return [create_roc_data()]: An object of class `roc_data`, a `tibble`,
#'   of the ROC data evaluated at each of the cutoff evaluation points.
#'   AUC is the area under the ROC curve, with values in \eqn{[0, 1]}.
#'   Youden's J is a method for choosing the "optimal" cut-off based on
#'   highest total sensitivity and specificity and is calculated via:
#'   \deqn{
#'     Youden_J = sensitivity + specificity - 1
#'   }
#'   For details on all other classification metrics, see [calc_confusion()].
#' @author Stu Field
#' @seealso [calc_roc_perpendicular()], [calc_confusion()]
#' @examples
#' n <- 200
#' withr::with_seed(22, {
#'   true <- sample(c("control", "disease"), n, replace = TRUE)
#'   pred <- runif(n)
#' })
#' roc_data <- create_roc_data(true, pred, "disease")
#' roc_data
#'
#' create_roc_data(true, pred, "disease", do.ci = TRUE)
#' create_roc_data(true, pred, "disease", include.auc = TRUE)
#'
#' @importFrom tibble as_tibble
#' @export
create_roc_data <- function(truth, predicted, pos.class, do.ci = FALSE,
                            cutoffs = seq(0.00001, 0.99999,
                                          length.out = length(truth)),
                            include.auc = FALSE) {

  stopifnot(
    "The `pos.class` must be in `truth`." = pos.class %in% truth
  )
  ret <- lapply(cutoffs, function(.cut) {
           eval_cut_cpp(truth     = as.character(truth),
                        predicted = predicted,
                        pos_class = as.character(pos.class),
                        cutoff    = .cut)
  })
  ret  <- data.frame(do.call(rbind, ret))
  ss_m <- data.matrix(ret[, c("specificity", "sensitivity")])
  ss_m[, 1L]  <- 1 - ss_m[, 1L]
  ret$perpD   <- apply(ss_m, 1, calc_roc_perpendicular)  # perpendicular dist
  ret$YoudenJ <- (ret$sensitivity + ret$specificity) - 1 # Youden Index

  if ( include.auc ) {
    auc <- calc_emp_auc(truth, predicted, pos.class, do.ci)
    if ( do.ci ) {
      ret$auc_lowerCI <- auc$lower.limit   # add to end
      ret$auc_upperCI <- auc$upper.limit   # add to end
      ret <- cbind(auc = auc$auc, ret)     # add to beginning
    } else {
      ret <- cbind(auc = auc, ret)         # add to beginning
    }
  }

  if ( do.ci ) {
    counts      <- table(truth)
    n_disease   <- counts[[pos.class]]
    n_control   <- counts[[setdiff(names(counts), pos.class)]]
    sens_limits <- calc_ci_binom(ret$sensitivity, n = n_disease, ci = sqrt(0.95))
    names(sens_limits) <- c("sens_lowerCI", "sens_upperCI")
    spec_limits <- calc_ci_binom(ret$specificity, n = n_control, ci = sqrt(0.95))
    names(spec_limits) <- c("spec_lowerCI", "spec_upperCI")
    ret <- cbind(ret, sens_limits, spec_limits)    # add to end
  }
  add_class(as_tibble(ret), "roc_data")
}


#' @describeIn create_roc_data
#'   A filtering method for class `roc_data`.
#' @param roc_data The result of a call to [create_roc_data()], a
#'   `roc_data` object.
#' @param metric Character. The metric (a column of the `roc_data` object)
#'   on which to filter the ROC data.
#' @param method `character(1)`. The filtering method. Can be either the
#'   maximum ("max") or minimum ("min") of your metric, or can be a
#'   specific value ("value") on which to filter (e.g. `sensitivity = 0.8`).
#' @param value If `method == "value"`, the value in \eqn{[-1, 1]} on which
#'   to filter.
#' @return [filter_roc_data()]: A filtered `roc_data` data frame.
#' @examples
#' # filter method
#' filter_roc_data(roc_data)
#' filter_roc_data(roc_data, "sensitivity", "value", 0.8)
#'
#' # watch out for rounding rules when trying to return a specific value!
#' filter_roc_data(roc_data, "sensitivity", "value", 0.85)
#' filter_roc_data(roc_data, "cutoff", method = "value", value = 0.5)
#'
#' @export
filter_roc_data <- function(roc_data, metric = c("YoudenJ", "sensitivity",
                                                 "specificity",
                                                 "ppv", "npv", "mcc",
                                                 "perpD", "cutoff"),
                          method = c("max", "min", "value"), value = NULL) {
  stopifnot(inherits(roc_data, "roc_data"))
  metric <- match.arg(metric)
  method <- match.arg(method)

  if ( method %in% c("max", "min") ) {
    func <- ifelse(method == "max", base::max, base::min)
    ret  <- roc_data[roc_data[[metric]] == func(roc_data[[metric]], na.rm = TRUE) &
                     !is.na(roc_data[[metric]]), ]
  } else {
    if ( is.null(value) || !is.numeric(value) ) {
      stop("Please enter a non-null filtering `value` in [-1, 1].", call. = FALSE)
    }
    if ( abs(value) > 1 && metric != "cutoff" ) {
      stop(
        "Please enter a valid value for your filtering metric: ",
        "a value between -1 and 1 for Youden's J; any real number for cutoffs; ",
        "or between 0 and 1 for all other metrics.", call. = FALSE
      )
    }
    decimals <- gsub("\\d+\\.", "0.", value)
    n_digits <- nchar(decimals) - 2 # subtract 2 for the leading digit and the decimal
    if ( value %in% round(roc_data[[metric]], n_digits) ) {
      ret <- roc_data[round(roc_data[[metric]], n_digits) == value, ]
    } else {
      # re-order so that the filter code works in all situations
      rd  <- roc_data[order(roc_data[[metric]]), ]
      ret <- rbind(rd[min(which(value <= rd[[metric]])), ],
                   rd[max(which(value >= rd[[metric]])), ])
    }
  }
  ret
}


#  Calculate Perpendicular Distance

#' @describeIn create_roc_data
#'   In receiver operating criterion curves, calculate the
#'   optimal operating point for a binary test given a series of
#'   \eqn{(x, y)} coordinates of the ROC curve, by calculating the
#'   _perpendicular_ distance between the curve and the unit \eqn{x = y} line.
#'   The Youden distance is similar but differs in that it corresponds
#'   to the _vertical_ distance between the ROC curve and the unit
#'   line, see [create_roc_data()].
#'
#' @param xy `numeric(2)`. An `(x, y)` coordinate on the ROC curve.
#' @examples
#' # distance from unit line
#' calc_roc_perpendicular(c(0.5, 0.5)) # on the line
#' calc_roc_perpendicular(c(0, 0))     # bottom-left corner
#' calc_roc_perpendicular(c(0, 1))     # top-left corner
#' calc_roc_perpendicular(c(1, 0))     # bottom-right corner
#' calc_roc_perpendicular(c(1, 1))     # top-right corner
#' @return [calc_roc_perpendicular()]: the perpendicular distance between the
#'   curve and the unit line.
#' @author Stu Field
#' @note [calc_roc_perpendicular()] differs slightly from the
#'   Youden's Index (J), see [create_roc_data()].
#' @seealso [stats::dist()]
#' @references Schisterman, et al. 2005. Optimal Cut-point and
#'   its Corresponding Youden Index to Discriminate Individuals Using
#'   Pooled Blood Samples. Epidemiology. 16: 73-81.
#' @importFrom stats dist
#' @export
calc_roc_perpendicular <- function(xy) {
  stopifnot(
    "`xy` coordinates must be numeric." = is.numeric(xy),
    "length of `xy` must be 2." = length(xy) == 2L,
    "`x` and `y` coordinates cannot sum > 2." = sum(xy, na.rm = TRUE) <= 2,
    "`x` and `y` coordinates must sum >= 0." = sum(xy, na.rm = TRUE) >= 0
  )
  as.numeric(dist(rbind(xy, rep(sum(xy) / 2, 2) ), method = "euclidean"))
}


# Calculate Corner Distance

#' @describeIn create_roc_data
#' An alternative optimal operating point is the _minimal_ distance
#'   from the ROC curve to the \eqn{(0, 1)} point of the operating space,
#'   the "top-left" corner.
#' @return [calc_roc_corner()]: the distance from the ROC curve to the
#'   top-left corner of the ROC.
#' @importFrom stats dist
#' @export
calc_roc_corner <- function(xy) {
  stopifnot(
    "`xy` coordinates must be numeric." = is.numeric(xy),
    "length of `xy` must be 2." = length(xy) == 2L,
    "`x` and `y` coordinates cannot sum > 2." = sum(xy, na.rm = TRUE) <= 2,
    "`x` and `y` coordinates must sum >= 0." = sum(xy, na.rm = TRUE) >= 0
  )
  as.numeric(dist(rbind(xy, c(0, 1)), method = "euclidean"))
}
