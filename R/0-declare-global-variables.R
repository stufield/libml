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
      "p_value",
      "feature",
      "RFU",
      "rfu_df",
      "L", "n", "nperm", # mack_wolfe
      "plot_y",
      "Feature",
      "type",
      "log_odds",
      "formula",
      "log2fc",
      "y",
      "pred",
      "Pr", "F1", "F2",    # bayes_bivariate_boundary
      "group",
      "lower.limit",
      "upper.limit",
      # calc_univariate
      "AptName", "EntrezGeneSymbol", "SeqId", "TargetFullName", "UniProt", "stats",
      "auc",
      # plot_contrast_tbls
      "p_value_x", "p_value_y", "xnoty", "ynotx", "xory", "xy", "x_cutoff", "y_cutoff",
      "truth",
      "ci",              # calc_confusion
      "estimate",        # calc_confusion
      "metric",          # getStat
      "Predicted",
      "SampleGroup",
      "Gini_Importance", # get_gini
      "slope",
      # plotEmpROC
      "specificity", "sensitivity",   "sens_upperCI", "sens_lowerCI", "spec_upperCI",
      "spec_lowerCI",
      "x1",            # plotROCbootCI95
      "y1",
      "y2"
    )
  )
}
