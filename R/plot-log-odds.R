#' Create a Log-Odds Plot
#'
#' Plot the log-odds, \deqn{log(Prob / (1 - Prob))} for each sample.
#' See `Details` for note about extreme probabilities.
#'
#' __Note:__ extreme values in \verb{[0, 1]} are thresholded at
#' `.Machine$double.eps^0.5`, or `[1.490116119e-08, 0.9999999851]`
#' to restrict the x-axis and avoid `Inf` values in log-odds space (\verb{0/1}).
#'
#' @inheritParams params
#' @param scramble Logical. Should values be randomized to avoid
#'   monotonically decreasing probability scores (aesthetic)?
#' @param max.prob Numeric. Maximum probability value cutoff for
#'   the log-odds plot. Removes extreme samples from the plot
#'   to avoid distorting x-axis.
#' @author Stu Field
#' @examples
#' n <- 20
#' withr::with_seed(22, {
#'   true <- sample(c("control", "disease"), n, replace = TRUE)
#'   pred <- runif(n)
#' })
#' plot_log_odds(true, pred, "disease")
#' plot_log_odds(true, pred, "disease", scramble = TRUE)
#' @importFrom ggplot2 ggplot aes geom_point labs xlim geom_vline
#' @importFrom ggplot2 scale_fill_manual scale_color_manual scale_shape_manual
#' @export
plot_log_odds <- function(truth, predicted, pos.class,  cutoff = 0.5,
                          main = NULL, y.lab = NULL, max.prob = NULL,
                          scramble = FALSE) {

  if ( !missing(max.prob) ) {
    warning("The `max.prob =` argument needs implementation.", call. = FALSE)
  }

  sample_order <- c("FP", "TN", "TP", "FN")

  if ( is.null(y.lab) ) {
    y.lab <- paste("Sample Order:", paste(sample_order, collapse = "-"))
  }

  # threshold machine precision for edge case 1/0; Inf
  thresh <- .Machine$double.eps^0.5
  predicted[predicted <= thresh]     <- thresh
  predicted[predicted >= 1 - thresh] <- 1 - thresh

  if ( scramble ) {
    withr::with_seed(1001, {
      scr_idx   <- sample(seq_along(truth))
      truth     <- truth[scr_idx]
      predicted <- predicted[scr_idx]
    })
  }

  if ( !pos.class %in% truth ) {
    stop(
      "Please check spelling of `pos.class =` argument: ",
      value(pos.class), call. = FALSE
    )
  }

  # assumes binary
  neg_class <- setdiff(unique(truth), pos.class) # nolint: object_usage_linter.

  types <- dplyr::case_when(
    predicted < cutoff  & truth == pos.class ~ "FN",
    predicted >= cutoff & truth == neg_class ~ "FP",
    predicted >= cutoff & truth == pos.class ~ "TP",
    predicted < cutoff  & truth == neg_class ~ "TN"
  )

  log_cutoff <- log(cutoff / (1 - cutoff))

  cols <- c(SomaPlotr::soma_colors$purple,
            rep(SomaPlotr::soma_colors$lightgrey, 2),
            SomaPlotr::soma_colors$lightgreen)

  df <- data.frame(predict = predicted) |>
    dplyr::mutate(log_odds = log(predict / (1 - predict)),
                  type     = factor(types, levels = sample_order)) |>
    dplyr::arrange(type) |>
    dplyr::mutate(y = dplyr::row_number())

  df |>
    ggplot2::ggplot(ggplot2::aes(x = log_odds, y = y,
                                 shape = type, color = type,
                                 fill = type) ) +
    ggplot2::geom_point(size = 3, alpha = 0.7) +
    ggplot2::scale_fill_manual(values = cols, name = "") +
    ggplot2::scale_color_manual(values = cols, name = "") +
    ggplot2::scale_shape_manual(values = c(19, 17, 15, 19), name = "") +
    ggplot2::labs(x = bquote(italic(log)[e] ~ (italic(p) / (1 - italic(p)))),
                  y = y.lab, title = main) +
    ggplot2::geom_vline(xintercept = log_cutoff, linetype = "longdash") +
    ggplot2::xlim(-ceiling(max(abs(df$log_odds))),
                  ceiling(max(abs(df$log_odds)))) +
    # implement max.prob here eventually
    SomaPlotr::theme_soma() +
    NULL
}
