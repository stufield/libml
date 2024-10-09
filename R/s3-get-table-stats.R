
#' @export
globalr::get_table_stats

#' @noRd
#' @export
get_table_stats.mackwolfe_table <- function(x, test.stat,
                                            field = c("fdr", "p.value", "p.bonferroni"),
                                            alpha = 0.05, n = NULL) {
  NextMethod("get_table_stats", test.stat = "Astar")
}

#' @noRd
#' @export
get_table_stats.ks_table <- function(x, test.stat,
                                   field = c("fdr", "p.value", "p.bonferroni"),
                                   alpha = 0.05, n = NULL) {
  NextMethod("get_table_stats", test.stat = "signed.ks.dist")
}

#' @noRd
#' @export
get_table_stats.t_table <- function(x, test.stat,
                                  field = c("fdr", "p.value", "p.bonferroni"),
                                  alpha = 0.05, n = NULL) {
  NextMethod("get_table_stats", test.stat = "signed.t.stat")
}

#' @noRd
#' @export
get_table_stats.lm_table <- function(x, test.stat,
                                   field = c("fdr", "p.value", "p.bonferroni"),
                                   alpha = 0.05, n = NULL) {
  NextMethod("get_table_stats", test.stat = "slope")
}

#' @noRd
#' @export
get_table_stats.kw_table <- function(x, test.stat,
                                   field = c("fdr", "p.value", "p.bonferroni"),
                                   alpha = 0.05, n = NULL) {
  NextMethod("get_table_stats", test.stat = "H.stat")
}

#' @noRd
#' @export
get_table_stats.wilcox_table <- function(x, test.stat,
                                       field = c("fdr", "p.value", "p.bonferroni"),
                                       alpha = 0.05, n = NULL) {
  NextMethod("get_table_stats", test.stat = ifelse(x$paired, "W", "U"))
}

#' @noRd
#' @export
get_table_stats.cor_table <- function(x, test.stat,
                                    field = c("fdr", "p.value", "p.bonferroni"),
                                    alpha = 0.05, n = NULL) {
  NextMethod("get_table_stats",
             test.stat = switch(x$method,
                                spearman = "rho",
                                pearson  = "cor.pearson",
                                kendall  = "tau"))
}
