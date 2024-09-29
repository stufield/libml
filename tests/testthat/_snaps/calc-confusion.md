# confusion matrix S3 summary method gives expected values; cutoff = 0.75

    == Confusion Matrix Summary ====================================================
    -- Confusion -------------------------------------------------------------------
    
    Positive Class: disease
    
             Predicted
    Truth     control disease
      control       7       3
      disease       6       4
    
    -- Performance Metrics (CI95%) -------------------------------------------------
    
    # A tibble: 8 x 5
      metric            n estimate CI95_lower CI95_upper
      <chr>         <int>    <dbl>      <dbl>      <dbl>
    1 Sensitivity      10    0.4       0.0535      0.746
    2 Specificity      10    0.7       0.376       1    
    3 PPV_Precision     7    0.571     0.153       0.990
    4 NPV              13    0.538     0.229       0.848
    5 Accuracy         20    0.55      0.301       0.799
    6 Bal_Accuracy     20    0.55      0.301       0.799
    7 Prevalence       20    0.5       0.250       0.750
    8 MCC              NA    0.105    NA          NA    
    
    -- Additional Statistics -------------------------------------------------------
    
    F_measure    G_mean    Wt_Acc 
        0.471     0.529     0.475 

