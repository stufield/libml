#' Create Manhattan Plot
#'
#' Creates a Manhattan plot of the differences or log-ratios
#' of the training set for each analyte.
#'
#' @param training.data A `tr_data` object.
#' @param x.lab Character. Set the x-axis label.
#' @param as.pvalue Logical. Should p-values be plotted in linear space
#'   or log10-space (default)?
#' @param type Character. The type measure used to evaluate expression change.
#'   Can be one of: "median", "t.test", or "ks.test". Pattern is matched so
#'   abbreviated strings are allowed.
#' @author Stu Field
#' @seealso [calc.lr()], [calc.ks()], [calc.t()]
#' @examples
#' tr <- createTrainingData(sim_test_data,
#'                          class_response %in% c("control", "disease"),
#'                          group.var = class_response,
#'                          class1 = "normal", class2 = "alzheimers")
#'
#' # Various options for plotting
#' plotManhattan(tr, type = "med")
#' plotManhattan(tr, type = "t")
#' plotManhattan(tr, type = "ks")
#' plotManhattan(tr, type = "t", as.pvalue = TRUE)
#' @importFrom ggplot2 geom_point labs aes geom_hline
#' @importFrom ggplot2 scale_color_manual ggplot
#' @export
plotManhattan <- function(training.data, x.lab = "SOMAmers",
                          type = c("median", "t.test", "ks.test"),
                          as.pvalue = FALSE) {
  type <- match.arg(type)
  withr::local_options(list(g.praise = FALSE))

  if ( type == "median" ) {
    stat_table <- calc.lr(training.data, do.mean = FALSE)
    y.lab      <- bquote(log[2]~"Median Ratio")
  } else if ( type == "t.test" ) {
    y.lab      <- "t-test Statistic"
    stat_table <- calc.t(log10(training.data))
  } else if ( type == "ks.test" ) {
    stat_table <- withr::with_options(list(warn = -1), calc.ks(training.data))
    y.lab      <- "KS Distance"
  }

  # pull out stat.table from object
  stat_table <- stat_table$stat.table

  # reorder back to original SOMAmer order
  stat_table <- stat_table[getAnalytes(training.data), , drop = FALSE]
  idx <- grep("^signed", names(stat_table))
  stopifnot(is_int(idx))
  names(stat_table)[idx] <- "plot_y"

  if ( as.pvalue ) {
    if ( type == "median" ) {
      stop(
        "The `as.pvalue = TRUE` argument is invalid for `type =` 'median'.",
        call. = FALSE
      )
    }
    y.lab <- bquote(-log[10] ~ (italic(p) - value))
  }

  legend_string <- sprintf("%s expression",
                           levels(training.data$Response)[1:6], 1L)

  stat_table$expression <- ifelse(stat_table$plot_y > 0, "UP", "DOWN") |>
    factor(levels = c("UP", "DOWN"))
  stat_table$x <- seq_len(nrow(stat_table))

  if ( as.pvalue ) {
    stat_table$plot_y <- -log10(stat_table$p.value)
  }

  p <- stat_table |>
    ggplot(aes(x = x, y = plot_y, fill = expression, color = expression)) +
    geom_point(alpha = 0.25) +
    scale_color_manual(values = unname(unlist(SomaPlotr::soma_colors2)[1:2])) +
    labs(title = "Manhattan Plot", x = x.lab, y = y.lab,
         color = legend_string, fill = legend_string) +
    SomaPlotr::theme_soma()
  if ( as.pvalue ) {
    p <- p + geom_hline(yintercept = c(2, 3, 4), linetype = "dashed",
                        size = 0.25, color = "blue")
  }
  p
}
