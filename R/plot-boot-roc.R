#' Plot a ROC with CI95
#'
#' Plots a ROC curve with bootstrapped 95% confidence interval
#'   boundary overlay.
#'
#' @family ROC
#'
#' @inheritParams params
#'
#' @param shade_color The color for the bootstrap shaded region.
#'   Passed as a `fill` argument to downstream `ggplot2` machinery.
#' @param add Logical. Should a plotting layer be added to an existing plot?
#' @param ... Additional arguments passed to [geom_roc()], e.g. `color =`.
#'
#' @author Stu Field, Amanda Hiser
#'
#' @examples
#' n <- 75
#' true <- rep(c("control", "disease"), each = n)
#' pred <- withr::with_seed(1, c(rnorm(n, 0.2, 0.3), rnorm(n, 0.8, 0.3)))
#' plot_boot_roc(true, pred, pos_class = "disease", nboot = 200, color = "blue")
#'
#' # add layer
#' pred2 <- withr::with_seed(1, c(rnorm(n, 0.2, 0.3), rnorm(n, 0.5, 0.3)))
#' plot_boot_roc(true, pred, pos_class = "disease", nboot = 200,
#'               shade_color = "blue", color = "blue") +
#' plot_boot_roc(true, pred2, pos_class = "disease", nboot = 200,
#'               shade_color = "green", color = "red", add = TRUE)
#' @importFrom stats quantile
#' @importFrom purrr detect_index
#' @export
plot_boot_roc <- function(truth, predicted, pos_class, shade_color = "black",
                          nboot = 1000, r_seed = 101, add = FALSE, ...) {

  withr::with_seed(r_seed, {
    # Bootstrapping the original datasets (truth & predicted) 'nboot' times
    boots <- replicate(nboot, {
      idx <- sample(seq_len(length(truth)), replace = TRUE)
      data.frame(truth = truth[idx], predicted = predicted[idx])
    }, simplify = FALSE)
  })

  # Calculating AUCs for all bootstrapped datasets
  aucs <- vapply(boots, function(.x) {
    calc_emp_auc(.x$truth, .x$predicted, pos_class = pos_class)}, double(1))

  # Identifying AUC values @ the 2.5th percentile & 97.5th percentile
  qq <- quantile(aucs, probs = c(0.025, 0.975), names = FALSE)
  hi <- detect_index(sort(aucs) > qq[2L], isTRUE)                    # first
  lo <- detect_index(sort(aucs) < qq[1L], isTRUE, .dir = "backward") # last

  # Selecting corresponding bootstrapped datasets for the AUCs above
  boots <- boots[order(aucs)][c(lo, hi)]   # pull just upper & lower

  # Calculating CI95 for the chosen bootstrapped datasets
  ci95 <- lapply(boots, function(.x) { # boots now length = 2
    pars <- calc_roc_fit(roc_xy(.x$truth, .x$predicted, pos_class))
    x <- seq(0, 1, length = 100)
    y <- 1 - (1 - x^pars["beta"])^(1 / pars["alpha"])
    list(x = x, y = y)
  }) |> setNames(c("upper", "lower"))

  # Assigning CI95 interval coordinates
  lim <- data.frame(x1 = ci95$upper[[1L]],   # line1 x-values
                    y1 = ci95$upper[[2L]],   # line1 y-values
                    x2 = ci95$lower[[1L]],   # line2 x-values
                    y2 = ci95$lower[[2L]])   # line2 y-values

  # Generating ROC data for curve
  rocxy <- roc_xy(truth, predicted, pos_class = pos_class) |> data.frame()

  # Setting up grid & plot theme
  p <- ggplot(rocxy, aes(x = x, y = y)) +
    geom_abline(slope = 1, intercept = 0, size = 0.2,
                linetype = "dashed", color = "grey") +
    libml_theme() +
    theme(panel.grid.minor = element_line(linetype = "dashed",
                                          color = "#B9BDBE",
                                          size  = 0.2),
          panel.grid.major = element_line(linetype = "dashed",
                                          color = "#B9BDBE",
                                          size  = 0.2)) +
    labs(x = "1 - Specificity", y = "Sensitivity")

  # Generating final ROC plot w/ boundary overlay
  g <- list(geom_roc(data = rocxy, aes(x = x, y = y), ...),
            geom_ribbon(data = lim, aes(x = x1, y = x1, ymin = y2, ymax = y1),
                        fill = shade_color, alpha = 0.25))

  if ( add ) {
    invisible(g)
  } else {
    p + g
  }
}
