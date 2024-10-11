
# https://testthat.r-lib.org/reference/expect_snapshot_file.html
expect_snapshot_csv <- function(code, name) {
  name <- paste0(name, ".csv")
  # Announce the file before touching `code`. This way, if `code`
  # unexpectedly fails or skips, testthat will not auto-delete the
  # corresponding snapshot file.
  withr::defer(unlink(name, force = TRUE))
  announce_snapshot_file(name = name)
  path <- write_stat_tbl(code, file = name)
  # Remove ^Date, User, System lines b/c the date line will change
  # depending on when the test is executed or which OS
  lines <- grep("^Date|^System|^User", read_text(path), value = TRUE, invert = TRUE)
  write_text(path, lines, overwrite = TRUE)
  expect_snapshot_file(path, name)
}

check_roc_plot <- function(rocxy) {
  stopifnot("input the output of `roc_xy()`." = is.matrix(rocxy))
  ggplot2::ggplot(data.frame(rocxy), ggplot2::aes(x = x, y = y)) +
    geom_roc(shape = 19, outline = FALSE)
}
