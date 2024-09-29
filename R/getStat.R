#' Get a classification performance metric/statistic
#'
#' Indexes into the S3 summary method for `confusion_matrix`
#' class object.
#'
#' Optional statistics are restricted to the output of the summary
#'   method. One of:\cr
#'   \itemize{
#'     \item{"Sensitivity"}
#'     \item{"Recall"}
#'     \item{"Specificity"}
#'     \item{"Precision"}
#'     \item{"PPV"}
#'     \item{"NPV"}
#'     \item{"Accuracy"}
#'     \item{"Error"}
#'     \item{"F_measure"}
#'     \item{"G_mean"}
#'     \item{"Wt_Acc"}
#'   }
#' @param x A summary object from a call to [calc_confusion()],
#'   a `summary.confusion_matrix` object.
#' @param which Character. A matched string for the test statistic desired.
#' @return Double. The desired classification performance statistic.
#' @author Stu Field
#' @seealso [calc_confusion()]
#' @examples
#' n <- 20
#' withr::with_seed(22, {
#'   true  <- sample(c("control", "disease"), n, replace = TRUE)
#'   pred  <- runif(n)
#' })
#'
#' # Summary of confusion matrix
#' c_mat <- calc_confusion(true, pred, pos.class = "disease") |> summary()
#' class(c_mat)
#'
#' # pull out elements
#' getStat(c_mat, "Spec")
#' getStat(c_mat, "Sens")
#' getStat(c_mat, "Recall")    # same
#' getStat(c_mat, "Accuracy")
#' getStat(c_mat, "Error")     # 1 - accuracy
#' getStat(c_mat, "PPV")
#' getStat(c_mat, "NPV")
#' getStat(c_mat, "F_measure")
#' getStat(c_mat, "Wt_Acc")
#' @export
getStat <- function(x, which = c("Sensitivity", "Recall",
                                 "Specificity", "Precision",
                                 "PPV", "NPV", "Accuracy", "MCC",
                                 "Error", "F_measure",
                                 "G_mean", "Wt_Acc")) {
  stopifnot(inherits(x, "summary.confusion_matrix"))
  which     <- match.arg(which)
  str_match <- switch(which,
                      Precision   =, # nolint: infix_spaces_linter2.
                      PPV         = "PPV_Precision",
                      Recall      =, # nolint: infix_spaces_linter2.
                      Sensitivity = "Sensitivity",
                      Specificity = "Specificity",
                      Error       =, # nolint: infix_spaces_linter2.
                      Accuracy    = "Accuracy",
                      MCC         = "MCC",
                      F_measure   = "F_measure",
                      G_mean      = "G_mean",
                      Wt_Acc      = "Wt_Acc",
                      NPV         = "NPV")
  if ( which %in% c("G_mean", "Wt_Acc", "F_measure") ) {
    est <- x$stats[[str_match]]
  } else {
    est <- dplyr::filter(x$metrics, metric == str_match)$estimate
    if ( which == "Error" ) {
      est <- 1 - est
    }
  }
  if ( !is_dbl(est) ) {
    stop("More than one value matches metric.", call. = FALSE)
  }
  est
}
