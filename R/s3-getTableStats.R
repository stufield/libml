
#' @export
globalr::getTableStats

#' @noRd
#' @export
getTableStats.mackwolfe_table <- function(x, test.stat,
                                          field = c("fdr", "p.value", "p.bonferroni"),
                                          alpha = 0.05, n = NULL) {
  NextMethod("getTableStats", test.stat = "Astar")
}

#' @noRd
#' @export
getTableStats.ks_table <- function(x, test.stat,
                                   field = c("fdr", "p.value", "p.bonferroni"),
                                   alpha = 0.05, n = NULL) {
  NextMethod("getTableStats", test.stat = "signed.ks.dist")
}

#' @noRd
#' @export
getTableStats.t_table <- function(x, test.stat,
                                  field = c("fdr", "p.value", "p.bonferroni"),
                                  alpha = 0.05, n = NULL) {
  NextMethod("getTableStats", test.stat = "signed.t.stat")
}

#' @noRd
#' @export
getTableStats.lm_table <- function(x, test.stat,
                                   field = c("fdr", "p.value", "p.bonferroni"),
                                   alpha = 0.05, n = NULL) {
  NextMethod("getTableStats", test.stat = "slope")
}

#' @noRd
#' @export
getTableStats.kw_table <- function(x, test.stat,
                                   field = c("fdr", "p.value", "p.bonferroni"),
                                   alpha = 0.05, n = NULL) {
  NextMethod("getTableStats", test.stat = "H.stat")
}

#' @noRd
#' @export
getTableStats.wilcox_table <- function(x, test.stat,
                                       field = c("fdr", "p.value", "p.bonferroni"),
                                       alpha = 0.05, n = NULL) {
  NextMethod("getTableStats", test.stat = ifelse(x$paired, "W", "U"))
}

#' @noRd
#' @export
getTableStats.cor_table <- function(x, test.stat,
                                    field = c("fdr", "p.value", "p.bonferroni"),
                                    alpha = 0.05, n = NULL) {
  NextMethod("getTableStats",
             test.stat = switch(x$method,
                                spearman = "rho",
                                pearson  = "cor.pearson",
                                kendall  = "tau"))
}
