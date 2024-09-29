#include <Rcpp.h>
using namespace Rcpp;

/*
description:
  This algorithm was adapted from Fawcett (2006)
  to account to a more accurate step calculation of indices
  with ties. The original paper suggests moving along the
  diagonal when tied according to the *expected* sensitivity
  ans specificity, however this does not account for ties
  that occur *within* the same class, in which case a walk
  along the edge of the "unknown" box is the correct decision. In
  this algorithm, a step in the diagonal only occurs if there is
  a tie *and* the current class name differs from the previous.
  Otherwise, a full step occurs in the appropriate direction, up
  for positive classes, right for negative classes.

return:
  A n x 2 matrix containing the `x` and `y` coordinates for the
  ROC curve. A matrix is preferred over a data frame for speed of indexing
  while iterating over the rows and having to convert between classes.
  Downstream code will often convert to data frame while the main AUC
  functionality prefers a matrix.

author:
  Stu Field

references:
  Fawcett, Tom. 2006. An introduction to ROC analysis.
  Pattern Recognition Letters. 27:861-874.

used in:
  getROCxy()
*/

// [[Rcpp::export]]
NumericMatrix roc_xy_cpp(CharacterVector true_class, // MUST(!) be sorted according to predictions
                         NumericVector predictions,  // MUST(!) be sorted decreasing order
                         String pos_class) {         // the positive class; MUST be in true_class

  IntegerVector tbl = table(true_class);  // MUST be binary
  CharacterVector classes = tbl.names();
  String neg_class(0);
  if ( classes[0] == pos_class ) {
    neg_class = classes[1];
  } else {
    neg_class = classes[0];
  }
  double np = tbl[pos_class];   // n positive
  double nn = tbl[neg_class];   // n negative
  double tp = 0;                // true positive
  double fp = 0;                // false positive
  double pp = 0.00000000001;    // previous prob
  int n = true_class.size();         // length iter
  NumericMatrix m( n + 1, 2 );  // output matrix
  NumericVector pred_vec = clone(predictions);   // copy predictions
  CharacterVector class_vec = clone(true_class); // copy true_class

  // start loop
  double p = 0;
  String cc(0);
  int idx_unique = 0;
  bool tied_prob = false;

  for ( int i = 0; i < n; ++i ) {
    p  = pred_vec[i];     // current prediction
    cc = class_vec[i];    // current class
    if ( std::fabs(p - pp) > 1e-08 ) {      // if no prob ties
      // add to i-th row; c(x, y)
      m( i, _ ) = m( i, _ ) + NumericVector::create(fp / nn, tp / np);

      if ( tied_prob ) {
        /*
        this branch indicates that *preceding* cases had tied probs
        (linearly interpolate across the tied cases)
        */
        int ndx = i - idx_unique;
        NumericVector diffs = (m( i, _ ) - m( idx_unique, _ )) / ndx;
        for ( int j = idx_unique + 1; j <= i; ++j ) {
          m( j, _ ) = m( j - 1, _ ) + diffs;
        }
      }
      idx_unique = i;
      tied_prob  = false;
      pp = p;
    } else {              // if i tied with i - 1
      tied_prob = true;
    }

    if ( cc == pos_class ) {
      tp = tp + 1;
    } else {
      fp = fp + 1;
    }
  }
  // end loop
  m( n , _ ) = NumericVector::create(1, 1);  // set final row to c(1, 1)

  if ( tied_prob ) {
    // this branch indicates that the *final* cases had tied probs
    int ndx = n - idx_unique;
    NumericVector diffs = (m( n, _ ) - m( idx_unique, _ )) / ndx;
    for ( int j = idx_unique + 1; j < n; ++j ) {
      m( j, _ ) = m( j - 1, _ ) + diffs;
    }
  }
  colnames(m) = CharacterVector::create("x", "y");
  return m;
}


/*
description:
  This algorithm is an alternative to `roc_xy_cpp` above, and should
  benefit from some speed improvements (~3x). See comparisons below for
  speed tests.
author:
  Shannon Holloway
future dev:
  Implement by switching out `roc_xy_cpp` -> `roc_xy_cpp2` inside
  `getROCxy()`
*/

// [[Rcpp::export]]
NumericMatrix roc_xy_cpp2(CharacterVector& true_class, // MUST(!) be sorted according to predictions
                          NumericVector& predictions,  // MUST(!) be sorted decreasing order
                          String pos_class) {          // the positive class; MUST be in true_class

  int n = true_class.size();
  NumericVector fp(n+1);
  NumericVector tp(n+1);
  LogicalVector dups = duplicated(predictions);
  dups.push_back(0);
  NumericMatrix m(n+1,2);

  IntegerVector idx, idx2;
  NumericVector idxdf, nidx2;

  fp[0] = 0.0;
  tp[0] = 0.0;
  int i_unique = 0;
  for ( int i = 1; i < n + 1; ++i ) {
    fp[i] = fp[i - 1] + (true_class[i - 1] != pos_class);
    tp[i] = tp[i - 1] + (true_class[i - 1] == pos_class);
    if ( dups[i] ) continue;
    if ( (i_unique + 1) != i ) {
      idx   = seq(i_unique + 1, i);
      idx2  = seq(1, idx.size());
      nidx2 = as<NumericVector>(idx2);

      idxdf = nidx2 * ((fp[i] - fp[i_unique]) / idx.size()) + fp[i_unique];
      fp[idx] = idxdf;

      idxdf = nidx2 * ((tp[i] - tp[i_unique]) / idx.size()) + tp[i_unique];
      tp[idx] = idxdf;
    }
    i_unique = i;
  }

  m(_, 0) = fp / fp[n];
  m(_, 1) = tp / tp[n];
  colnames(m) = CharacterVector::create("x", "y");
  return m;
}


// [[Rcpp::export]]
NumericVector eval_cut_cpp(CharacterVector truth,   // true class labels
                           NumericVector predicted, // numeric class predictions
                           String pos_class,        // the positive class; MUST be in truth
                           double cutoff) {         // the operating point to make class predictions

  double tp = 0.0;
  double tn = 0.0;
  double fp = 0.0;
  double fn = 0.0;

  double cutoff2 = cutoff - 1e-08; // shift to test for equality
  bool test_lgl = false;

  for ( int i = 0; i < truth.size(); ++i ) {
    test_lgl = predicted[i] > cutoff2;
    ( (truth[i] == pos_class) ? (test_lgl ? tp : fn) += 1.0 : (test_lgl ? fp : tn) += 1.0 );
  }

  double mcc;

  if ( R_IsNA(cutoff) ) {
    mcc = NA_REAL;
  } else {
    mcc = ((tp * tn) - (fp * fn)) /
      (sqrt(tp + fp) * sqrt(tp + fn) * sqrt(tn + fp) * sqrt(tn + fn));
  }

  double sens = tp / ( tp + fn );   // sensitivity, recall
  double spec = tn / ( fp + tn );   // specificity (compliment to sensitivity)
  double ppv  = tp / ( tp + fp );   // precision (PPV)
  double npv  = tn / ( tn + fn );   // NPV

  NumericVector ret = NumericVector::create(cutoff, tp, fn, fp, tn,
                                            sens, spec, ppv, npv, mcc);
  ret.names() = CharacterVector::create("cutoff", "tp", "fn", "fp", "tn",
                                        "sensitivity", "specificity",
                                        "ppv", "npv", "mcc");
  return ret;
}


/* Testing output */
/***R
n <- 100
classes <- sample(c("a", "b"), n, replace = TRUE)
pred <- sort(runif(n))
check_roc_plot(roc_xy_cpp(classes, pred, "b"))

# ----
# benchmarking of 2 alternatives for ROC_xy calculations
bench::mark(
  roc_xy_cpp  = roc_xy_cpp(classes, pred, "b"),
  roc_xy_cpp2 = roc_xy_cpp2(classes, pred, "b")
)


# old version of eval_cutoff()
eval_cutoff <- function(truth, predicted, pos.class, cutoff) {
  tp  <- sum(truth == pos.class & predicted >= cutoff) # predict pos, is pos
  fn  <- sum(truth == pos.class & predicted <  cutoff) # predict neg, is pos
  fp  <- sum(truth != pos.class & predicted >= cutoff) # predict pos, is neg
  tn  <- sum(truth != pos.class & predicted <  cutoff) # predict neg, is neg
  sens <- tp / (tp + fn)   # sensitivity, recall
  spec <- tn / (fp + tn)   # specificity (compliment to sensitivity)
  ppv  <- tp / (tp + fp)   # precision (PPV)
  npv  <- tn / (tn + fn)   # NPV
  # For MCC calculation
  d1 <- tp + fp
  d2 <- tp + fn
  d3 <- tn + fp
  d4 <- tn + fn
  if ( is.na(cutoff) || d1 == 0 | d2 == 0 | d3 == 0 | d4 == 0 ) {
    mcc <- NA_real_
  } else {
    mcc <- ((tp * tn) - (fp * fn)) / sqrt(prod(d1, d2, d3, d4))
  }
  c(cutoff = cutoff,
    tp = as.double(tp), fn = as.double(fn),
    fp = as.double(fp), tn = as.double(tn),
    sensitivity = sens, specificity = spec,
    ppv = ppv, npv = npv, mcc = mcc
  )
}
n <- 1000
classes <- sample(c("a", "b"), n, replace = TRUE)
pred <- runif(n)
bench::mark(
  old = eval_cutoff(classes, pred, "b", 0.5),
  cpp = eval_cut_cpp(classes, pred, "b", 0.5)
)
*/
