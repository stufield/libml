#' Calculate bootstrapped AUC
#'
#' Confidence intervals for the 95% limits are calculated via
#' _empirical_ bootstrap iterations and using Pepe's AUC calculation.
#'
#' @family auc
#' @inheritParams params
#' @return A list containing bootstrap intervals based on the number
#'   of bootstraps performed:
#'     \item{auc}{The raw Pepe AUC estimate from original data.}
#'     \item{lower.limit}{The lower CI95 of the estimate.}
#'     \item{upper.limit}{The upper CI95 of the estimate.}
#' @note This function is used primarily in [plotEmpROC()].
#' @author Stu Field
#' @seealso [replicate()], [plotEmpROC()]
#' @examples
#' withr::with_seed(10, {
#'   true <- sample(c("cont", "disease"), 20, replace = TRUE)
#'   pred <- runif(20)
#' })
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
  boots <- withr::with_seed(r.seed, {
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
