#' Calculate Area Under Curve
#'
#' Calculates the area under the curve (AUC).
#'
#' @family auc
#' @inheritParams params
#' @param ... Additional arguments passed to [caTools::colAUC()].
#' @return All return a numeric scalar corresponding to the area under
#'   the curve. For 95% confidence intervals (`ci95 = TRUE`), [calcEmpAUC()]
#'   returns a `list` object with these elements:
#'     \item{auc}{The area under the curve (empirical).}
#'     \item{lower.limit}{lower 95% confidence limit based on standard error AUC.}
#'     \item{upper.limit}{upper 95% confidence limit based on standard error AUC.}
#' @author Stu Field
#' @examples
#' n <- 20
#' withr::with_seed(22, {
#'   true <- sample(c("control", "disease"), n, replace = TRUE)
#'   pred <- runif(n)
#' })
#' calcAUC(true, pred)
#'
#' @export
calcAUC <- function(truth, predicted, ...) {
  as.numeric(caTools::colAUC(predicted, truth, ...))
}


#' @describeIn calcAUC
#' Calculate the _empirical_ AUC, optionally with corresponding 95%
#'   confidence intervals according to the DeLong approach via the standard
#'   error of the AUC estimate. This empirical AUC estimate is calculated via
#'   the trapezoid area at each step along the x-axis of a ROC curve.
#' @param ci95 Logical. Should DeLong's standard error based confidence
#'   limits be included with the AUC estimate?
#' @seealso [plotEmpROC()], [roc_xy()]
#' @references DeLong et al. (1988) for the calculation of the Standard Error
#'   of the Area Under the Curve (AUC) and of the difference between two AUCs.
#' @examples
#' # Empirical AUC
#' calcEmpAUC(true, pred, "disease")
#' calcEmpAUC(true, pred, "disease", ci95 = TRUE)  # with CI95
#'
#' @importFrom stats var
#' @export
calcEmpAUC <- function(truth, predicted, pos.class, ci95 = FALSE) {

  auc <- empAUC_cpp(roc_xy(truth, predicted, pos.class))

  if ( ci95 ) {
    idx     <- which(truth == pos.class)
    pos_vec <- predicted[idx]
    neg_vec <- predicted[-idx]
    n_neg   <- length(neg_vec)
    n_pos   <- length(pos_vec)
    s_pos   <- vapply(pos_vec, function(.x) mean(neg_vec > .x), double(1L))
    s_neg   <- vapply(neg_vec, function(.x) mean(pos_vec >= .x), double(1L))
    auc_sd  <- sqrt(var(s_neg) / n_neg + var(s_pos) / n_pos)
    se      <- 1.959964 * auc_sd
    list(auc = auc, lower.limit = auc - se, upper.limit = auc + se)
  } else {
    auc
  }
}


#' @describeIn calcAUC
#'   Calculate the AUC according to Margaret Pepe's book.
#' @references `calcPepeAUC:` M. Pepe. The Statistical
#'   Evaluation of Medical Tests for Classification and Prediction.
#' @examples
#' # Pepe's AUC
#' calcPepeAUC(true, pred, "disease")
#'
#' @export
calcPepeAUC <- function(truth, predicted, pos.class) {
  stopifnot(
    "`truth` and `predicted` must be of equal length." = 
      length(truth) == length(predicted),
    "`pos.class` must be in `truth`." = pos.class %in% truth
  )
  idx     <- which(truth == pos.class)
  pos_vec <- predicted[idx]
  neg_vec <- predicted[-idx]
  auc     <- double(1)
  for ( neg_vote in neg_vec ) {
    for ( pos_vote in pos_vec ) {
      if ( pos_vote > neg_vote ) {
        auc <- auc + 1.0
      } else if ( pos_vote == neg_vote ) {
        auc <- auc + 0.5
      }
    }
  }
  auc / length(pos_vec) / length(neg_vec)
}


#' @describeIn calcAUC
#'   Bootstrapped confidence intervals for the 95% limits are calculated via
#'   _empirical_ bootstrap iterations and using Pepe's AUC calculation.
#' @inheritParams params
#' @return A list containing bootstrap intervals based on the number
#'   of bootstraps performed:
#'     \item{auc}{The raw Pepe AUC estimate from original data.}
#'     \item{lower.limit}{The lower CI95 of the estimate.}
#'     \item{upper.limit}{The upper CI95 of the estimate.}
#' @author Stu Field
#' @seealso [replicate()], [plotEmpROC()]
#' @examples
#' # bootstrapped AUC
#' calcBootAUC(true, pred, "disease")
#' calcBootAUC(true, pred, "disease", nboot = 100, r.seed = 100)  # reproducible
#' @importFrom stats quantile
#' @importFrom withr with_seed
#' @export
calcBootAUC <- function(truth, predicted, pos.class,
                        nboot = 1000, r.seed = sample(1000, 1)) {
  est <- calcPepeAUC(truth, predicted, pos.class)   # empirical AUC estimate
  # bench::mark(
  #   emp  = calcEmpAUC(truth, predicted, pos.class),
  #   pepe = calcPepeAUC(truth, predicted, pos.class)
  # )
  .data <- data.frame(truth = truth, predicted = predicted)
  boots <- with_seed(r.seed, {
    replicate(nboot, sample(seq_len(nrow(.data)), replace = TRUE), simplify = FALSE)
  })
  boot_pop <- vapply(boots, function(.x) { # iterate AUC over boots
      df <- .data[.x, ]
      # Pepe's AUC is MUCH faster than empirical AUC
      calcPepeAUC(df$truth, df$predicted, pos.class = pos.class)
    }, FUN.VALUE = 0.1)
  ci95 <- quantile(boot_pop, probs = c(0.025, 0.975), names = FALSE) # CI95
  list(auc = est, lower.limit = ci95[1L], upper.limit = ci95[2L])
}
