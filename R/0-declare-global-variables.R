##################################
# Declaring Global Variables:
# This is mostly for passing R CMD checks
# global variables that come from other dependent
# packages, or objects in the data/ directory
# Reference: https://github.com/tidyverse/magrittr/issues/29
##################################
if ( getRversion() >= "2.15.1" ) {
  utils::globalVariables(
    c(".",
      "x",
      "target_names",
      "alpha",
      "p.value",
      "feature",
      "RFU",
      "rfu_df",
      "plot_y",
      "Feature",
      "type",
      "log_odds",
      "y",
      "pred",
      "Pr", "F1", "F2",    # Bayes bivariate boundary
      "group",
      "lower.limit",
      "upper.limit",
      "AptName", "EntrezGeneSymbol", "SeqId", "TargetFullName", "UniProt", "stats", # calc_univariate
      "auc",
      "truth",
      "ci",              # calc_confusion
      "estimate",        # calc_confusion
      "metric",          # getStat
      "Predicted",
      "SampleGroup",
      "log2.fold.change",
      "Gini_Importance",
      "Response",
      "specificity",   # plotEmpROC
      "sensitivity",   # plotEmpROC
      "sens_upperCI",  # plotEmpROC
      "sens_lowerCI",  # plotEmpROC
      "spec_upperCI",  # plotEmpROC
      "spec_lowerCI",  # plotEmpROC
      "x1",            # plotROCbootCI95
      "y1",
      "y2"
    )
  )
}
