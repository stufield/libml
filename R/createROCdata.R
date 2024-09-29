#' Create ROC Data Frame
#'
#' Create a data frame of ROC performance at various
#' predefined operating points or cutoffs, one row
#' per cutoff evaluation.
#'
#' @family ROC
#' @inheritParams params
#' @param cutoffs Various cutoffs at which to evaluate performance.
#' @param do.ci Logical. Should binomial confidence limits be
#'   calculated and added to the return value.
#' @param include.auc Logical. Should AUC also be calculated and added as a
#'   column to the returned data frame.
#' @return [createROCdata()]: An object of class `roc_data`, a data frame,
#'   of the ROC data evaluated at each of the cutoff evaluation points.
#'   AUC is the area under the
#'   ROC curve, with values in \eqn{[0, 1]}.
#'   Youden's J is a method for choosing the "optimal" cut-off based on
#'   highest total sensitivity and specificity and is calculated via
#'   \deqn{
#'     Youden_J = sensitivity + specificity - 1
#'   }
#'   For details on all other classification metrics, see [calc_confusion()].
#' @author Mike Mehan and Stu Field
#' @seealso [calcROCperpendicular()], [calc_confusion()]
#' @examples
#' n <- 200
#' withr::with_seed(22, {
#'   true <- sample(c("control", "disease"), n, replace = TRUE)
#'   pred <- runif(n)
#' })
#' roc_data <- createROCdata(true, pred, "disease")
#' roc_data
#' createROCdata(true, pred, "disease", do.ci = TRUE)
#' createROCdata(true, pred, "disease", include.auc = TRUE)
#'
#' @export
createROCdata <- function(truth, predicted, pos.class, do.ci = FALSE,
                          cutoffs = seq(0.00001, 0.99999,
                                        length.out = length(truth)),
                          include.auc = FALSE) {

  stopifnot(pos.class %in% truth)
  ret <- lapply(cutoffs, function(.cut) {
           eval_cut_cpp(truth     = as.character(truth),
                        predicted = predicted,
                        pos_class = as.character(pos.class),
                        cutoff    = .cut)
  })
  ret <- data.frame(do.call(rbind, ret))

  ss_df <- data.matrix(ret[, c("specificity", "sensitivity")])
  ss_df[, 1L] <- 1 - ss_df[, 1L]
  ret$perpD <- apply(ss_df, 1, calcROCperpendicular)      # perpendicular dist
  ret$YoudenJ <- (ret$sensitivity + ret$specificity) - 1  # Youden Index

  if ( include.auc ) {
    auc <- calcEmpAUC(truth, predicted, pos.class, do.ci)
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
    sens_limits <- calcBinomCI(ret$sensitivity, n = n_disease, ci = sqrt(0.95))
    names(sens_limits) <- c("sens_lowerCI", "sens_upperCI")
    spec_limits <- calcBinomCI(ret$specificity, n = n_control, ci = sqrt(0.95))
    names(spec_limits) <- c("spec_lowerCI", "spec_upperCI")
    ret <- cbind(ret, sens_limits, spec_limits)    # add to end
  }
  addClass(ret, "roc_data")
}


#' @describeIn createROCdata A filtering method for class `roc_data`.
#' @param roc_data The result of a call to [createROCdata()].
#'   A `roc_data` object.
#' @param metric Character. The metric (a column of the `roc_data` object)
#'   on which to filter the ROC data.
#' @param method Character. The filtering method. Can be either the
#'   maximum ("max") or minimum ("min") of your metric, or can be a
#'   specific value ("value") on which to filter (e.g. `sensitivity = 0.8`).
#' @param value If `method == "value"`, the value in \verb{[-1, 1]} on which
#'   to filter.
#' @return [filterROCdata()]: A filtered `roc_data` data frame.
#' @examples
#' # filter method
#' filterROCdata(roc_data)
#' filterROCdata(roc_data, "sensitivity", "value", 0.8)
#'
#' # watch out for rounding rules when trying to return a specific value!
#' filterROCdata(roc_data, "sensitivity", "value", 0.85)
#' filterROCdata(roc_data, "cutoff", method = "value", value = 0.5)
#' @export
filterROCdata <- function(roc_data, metric = c("YoudenJ", "sensitivity",
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
