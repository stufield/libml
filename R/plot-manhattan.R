#' Create Manhattan Plot
#'
#' Creates a Manhattan plot of the differences or log-ratios
#' of the training set for each analyte.
#'
#' @param data A training data `tr_data` object.
#' @param x.lab Character. Set the x-axis label.
#' @param as.pvalue Logical. Should p-values be plotted in linear space
#'   or log10-space?
#' @param type Character. The type measure used to evaluate expression change.
#'   Can be one of: "log2fc", "t.test", or "ks.test". Pattern is matched so
#'   abbreviated strings are allowed.
#' @author Stu Field
#' @examples
#' tr <- create_train(sim_test_data,
#'                    class_response %in% c("control", "disease"),
#'                    group.var = class_response,
#'                    classes = c("control", "disease"))
#'
#' # Various options for plotting
#' plot_manhattan(tr, type = "log2")
#' plot_manhattan(tr, type = "t")
#' plot_manhattan(tr, type = "ks")
#' plot_manhattan(tr, type = "t", as.pvalue = TRUE)
#' @importFrom ggplot2 geom_point labs aes geom_hline
#' @importFrom ggplot2 scale_color_manual ggplot
#' @export
plot_manhattan <- function(data, x.lab = "Feature",
                           type = c("t.test", "log2fc", "ks.test"),
                           as.pvalue = FALSE) {
  type <- match.arg(type)
  withr::local_options(list(praise_usr = FALSE))

  if ( type == "log2fc" ) {
    stat_table <- calc_univariate(data, var = .get_response(data), test = type)
    y_lab      <- bquote(log[2] ~ (Median~Ratio))
  } else if ( type == "t.test" ) {
    y_lab      <- "t-test Statistic"
    stat_table <- calc_univariate(data, var = .get_response(data), test = type)
  } else if ( type == "ks.test" ) {
    stop("Fix for KS option in `calc_univariate()`", call. = FALSE)
    stat_table <- withr::with_options(list(warn = -1), calc_univariate(data))
    y_lab      <- "KS Distance"
  }

  # reorder back to original order in `data`
  .idx <- match(names(data), stat_table$feature, nomatch = 0L)
  stat_table <- stat_table[.idx, ]

  stat_idx <- grep("^t$|^ks$|^log2fc$", names(stat_table))  # get stat column
  stopifnot(
    "Couldn't identify the test statistic in the stat-table." = is_int(stat_idx)
  )
  names(stat_table)[stat_idx] <- "plot_y"

  if ( as.pvalue ) {
    if ( type == "median" ) {
      stop(
        "The `as.pvalue = TRUE` argument is invalid for `type =` 'median'.",
        call. = FALSE
      )
    }
    y_lab <- bquote(-log[10] ~ (italic(p) - value))
  }

  stat_table$expression <- ifelse(stat_table$plot_y > 0, "UP", "DOWN") |>
    factor(levels = c("UP", "DOWN"))
  stat_table$x <- seq_len(nrow(stat_table))

  if ( as.pvalue ) {
    stat_table$plot_y <- -log10(stat_table$p.value)
  }

  p <- stat_table |>
    ggplot(aes(x = x, y = plot_y, fill = expression, color = expression)) +
    geom_point(alpha = 0.75) +
    scale_color_manual(values = unlist(col_palette, use.names = FALSE)[1:2L]) +
    labs(title = "Manhattan Plot", x = x.lab, y = y_lab) +
    SomaPlotr::theme_soma()
  if ( as.pvalue ) {
    p <- p + geom_hline(yintercept = c(2, 3, 4), linetype = "dashed",
                        size = 0.25, color = "blue")
  }
  p
}
