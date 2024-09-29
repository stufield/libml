#include <Rcpp.h>
using namespace Rcpp;

/* Calculate the trapezoidal area under 2 pts */
// [[Rcpp::export]]
double calcTrap_cpp(NumericMatrix x) {
  int nc = x.cols();
  int nr = x.rows();
  if ( nc != 2 || nr != 2 ) {
    stop("'x' must be a 2x2 numeric matrix, dim(x) = %ix%i", nr, nc);
  }
  double width = std::abs(x( 1, 0 ) - x( 0, 0 ));
  // Rcout << "print width: " << width << "\n";
  if ( width == 0 ) {
    return width;  // if vertical, no width & no area, early exit 0
  }
  double tri_y = std::abs(x( 1, 1 ) - x( 0, 1 ));
  double min_y = std::min(x( 0 , 1 ), x( 1 , 1 ));
  return width * (min_y + 0.5 * tri_y);
}


/* Calculate the accumulated trapezoidal area across a ROC curve */
// [[Rcpp::export]]
double empAUC_cpp(NumericMatrix xy) {
  int nc = xy.cols();
  if ( nc != 2 ) {
    stop("'xy' must be a 2x2 numeric matrix (ncol = %i)", nc);
  }
  int n = xy.rows();
  double res = 0;
  NumericMatrix m( 2, 2 );
  for ( int i = 1; i < n; ++i ) {
    m = xy( Range(i - 1, i), _ );
    res += calcTrap_cpp(m);
  }
  return res;
}


/* Testing output */
/***R
# speed-testing trap area
calcTrapezArea <- function(xy) {   # old version
  width <- abs(xy[1, 1] - xy[2, 1])
  tri_y <- abs(xy[1, 2] - xy[2, 2])
  min_y <- min(xy[, 2])
  width * (min_y + 0.5 * tri_y)
}
set.seed(22)
x <- matrix(runif(4), ncol = 2)
bench::mark(
  old = calcTrapezArea(x),
  new = calcTrap_cpp(x)
)

# speed-testing AUC calculation (sum of paired points)
.aucEmp <- function(xy) {
  stopifnot(inherits(xy, "matrix"))
  rowiter <- seq(nrow(xy))[-1L]  # not first row
  .f <- function(.i) calcTrapezArea(xy[c(.i - 1, .i), ])
  area <- vapply(rowiter, .f, FUN.VALUE = double(1L), USE.NAMES = FALSE)
  sum(area)
}
m <- matrix(runif(1000), ncol = 2)
m <- m[order(m[, 1L]), ]
bench::mark(
  old = .aucEmp(m),
  new = empAUC_cpp(m)
)
*/
