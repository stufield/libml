#' Create a Log-Odds Plot
#'
#' Plot the log-odds, \deqn{log(Prob / (1 - Prob))} for each sample.
#'   See `Section` for note about extreme probabilities.
#'
#' @section Extreme probabilities:
#'   extreme values in \verb{[0, 1]} are thresholded at
#'   `.Machine$double.eps^0.5`, or `[1.490116119e-08, 0.9999999851]`
#'   to restrict the x-axis and avoid `Inf` values in log-odds space (\verb{0/1}).
#'
#' @inheritParams params
#'
#' @param scramble `logical(1)`. Should values be randomized to avoid
#'   monotonically decreasing probability scores (aesthetic)?
#' @param max_prob `numeric(1)`. Maximum probability value cutoff for
#'   the log-odds plot. Removes extreme samples from the plot
#'   to avoid distorting x-axis.
#'
#' @author Stu Field
#'
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
plot_log_odds <- function(truth, predicted, pos_class, cutoff = 0.5,
                          y_lab = NULL, max_prob = NULL, scramble = FALSE) {

  if ( !is.null(max_prob) ) {
    warning("The `max_prob =` argument needs implementation.",
            call. = FALSE)
  }

  sample_order <- c("FP", "TN", "TP", "FN")

  if ( is.null(y_lab) ) {
    y_lab <- paste("Sample Order:", paste(sample_order, collapse = "-"))
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

  if ( !pos_class %in% truth ) {
    stop(
      "Please check spelling of `pos_class =` argument: ",
      value(pos_class), call. = FALSE
    )
  }

  # assumes binary
  neg_class <- setdiff(unique(truth), pos_class) # nolint: object_usage_linter.

  types <- dplyr::case_when(
    predicted < cutoff  & truth == pos_class ~ "FN",
    predicted >= cutoff & truth == neg_class ~ "FP",
    predicted >= cutoff & truth == pos_class ~ "TP",
    predicted < cutoff  & truth == neg_class ~ "TN"
  )

  log_cutoff <- log(cutoff / (1 - cutoff))

  cols <- c(col_palette$purple,
            rep(col_palette$lightgrey, 2L),
            col_palette$lightgreen)

  df <- data.frame(predict = predicted) |>
    dplyr::mutate(log_odds = log(predict / (1 - predict)),
                  type     = factor(types, levels = sample_order)) |>
    dplyr::arrange(type) |>
    dplyr::mutate(y = dplyr::row_number())

  df |>
    ggplot(aes(x = log_odds, y = y, shape = type,
               color = type, fill = type) ) +
    geom_point(size = 3, alpha = 0.75) +
    scale_fill_manual(values = cols, name = "") +
    scale_color_manual(values = cols, name = "") +
    scale_shape_manual(values = c(19, 17, 15, 19), name = "") +
    labs(
      x = bquote(italic(log)[e] ~ (italic(p) / (1 - italic(p)))),
      y = y_lab) +
    geom_vline(xintercept = log_cutoff, linetype = "longdash") +
    xlim(-ceiling(max(abs(df$log_odds))), ceiling(max(abs(df$log_odds)))) +
    # TODO: implement `max_prob` here eventually
    libml_theme()
}
