#' Plot AUCs and Error Bars
#'
#' Plots a list of AUCs as barplots and added error bars for each
#' corresponding to the 95% confidence interval for each. See
#' [calcEmpAUC()] for how to generate the AUCs and CI95s.
#'
#' @inheritParams params
#' @param data A `data.frame` object of AUCs and 95% confidence intervals.
#'   Each row is the result of a call to [calcEmpAUC()] with
#'   `ci95 = TRUE` and converted to a single row `data.frame`. See example.
#' @param color Character or numeric vector containing colors for each of
#'   the barplots, as used by [ggplot()].
#'   Vector length should match the number of rows in `data`.
#'   Colors are recycled as necessary.
#' @param flip Logical. Should the axes be flipped? See example.
#' @return A [ggplot()] plot.
#' @author Stu Field
#' @seealso [calcEmpAUC()]
#' @examples
#' # create random AUCs and CI95s
#' withr::with_seed(22, {
#'   true <- sample(c("control", "disease"), 20, replace = TRUE)
#'   auc_df <- lapply(1:5, function(.x) {
#'     data.frame(calcEmpAUC(true, runif(20), "disease", ci95 = TRUE))
#'   }) |> do.call(what = rbind)
#' })
#' auc_df
#' barplotAUCs(auc_df)
#'
#' # Set rownames to identify the bars
#' rownames(auc_df) <- LETTERS[1:nrow(auc_df)]
#' barplotAUCs(auc_df)
#'
#' # Flip axes
#' barplotAUCs(auc_df, color = SomaPlotr::soma_colors$purple, flip = TRUE)
#' @importFrom ggplot2 ggplot aes geom_errorbar
#' @importFrom ggplot2 geom_bar labs coord_flip
#' @export
barplotAUCs <- function(data, color = SomaPlotr::soma_colors$lightgrey,
                        flip = FALSE,
                        main = bquote("AUCs \U00B1 CI95")) {

  if ( is.na(.row_names_info(data, 0L)[[1L]]) ) {
    rownames(data) <- rownames(data)     # if implicit rn, assign them
  }

  df <- rn2col(data, "group")
  df$group <- factor(df$group, levels = df$group)
  p <- ggplot(df, aes(y = auc, x = group)) +
    geom_bar(stat = "identity", fill = color) +
    geom_errorbar(aes(ymin = lower.limit, ymax = upper.limit), width = 0.25) +
    labs(y = "AUC", title = main, x = NULL) +
    SomaPlotr::theme_soma()

  if ( flip ) {
    p <- p + coord_flip()
  }
  p
}
