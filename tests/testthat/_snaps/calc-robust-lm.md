# `calc.robust.lm()` generates correct output object

    
    == Stat Table Info: Robust Linear Regression =======================================================
      Call                      calc.robust.lm(data = log10(small_adat), response = "HybControlNormScale")
      Data Frame                log10(small_adat)
      Data Dims                 20 x 11
      Table Dims                10 x 7
      Statistical Test          Robust Linear Regression
      Log Transform             TRUE
      Number of rlm models      10
      Number of samples         20
      Response Variable         HybControlNormScale
    
    -- Stat Table --------------------------------------------------------------------------------------
                 intercept      slope   t.slope      p.value         fdr p.bonferroni rank
    seq.3590.8   6.3010125 -1.3675994 -4.319871 0.0004125211 0.004006435  0.004125211    1
    seq.3186.2   4.0391679 -0.8907773 -4.021095 0.0008012871 0.004006435  0.008012871    2
    seq.5317.3  -0.4010834  0.3717395  3.001952 0.0076528589 0.015673853  0.076528589    3
    seq.3612.6  -1.4268785  0.6039550  2.945522 0.0086501903 0.015673853  0.086501903    4
    seq.2643.57 -1.7868920  0.5979938  2.857904 0.0104524170 0.015673853  0.104524170    5
    seq.4829.43 -0.5542009  0.4855921  2.841230 0.0108341894 0.015673853  0.108341894    6

