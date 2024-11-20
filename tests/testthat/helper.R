
check_roc_plot <- function(rocxy) {
  stopifnot("input the output of `roc_xy()`." = is.matrix(rocxy))
  ggplot2::ggplot(data.frame(rocxy), ggplot2::aes(x = x, y = y)) +
    geom_roc(shape = 19, outline = FALSE)
}
