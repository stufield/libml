# the full unit test for `calc.glm()` return expected object result

    
    == Stat Table Info: Logistic Regression ============================================================
      Call                      calc.glm(data = convert2TrainingData(small_adat, "SampleGroup"))
      Data Frame                convert2TrainingData(small_adat, "SampleGroup")
      Data Dims                 20 x 12
      Table Dims                10 x 7
      Statistical Test          Logistic Regression
      Response Counts           F=11 vs M=9
      Log Transform             FALSE
      Number of glm models      10
      Number of samples         20
      Class Variable            Response
    
    -- Stat Table --------------------------------------------------------------------------------------
                 intercept        slope odds_ratio    p.value        fdr p.bonferroni rank
    seq.3795.6   -7.076786 0.0020109979   1.002013 0.01960636 0.03316901    0.1960636    1
    seq.3004.67 -15.351706 0.0029317486   1.002936 0.02299092 0.03316901    0.2299092    2
    seq.5034.79  -3.281092 0.0011539493   1.001155 0.02658850 0.03316901    0.2658850    3
    seq.3073.51  -4.264207 0.0003780662   1.000378 0.02770618 0.03316901    0.2770618    4
    seq.2750.3  -11.420124 0.0006617856   1.000662 0.02823407 0.03316901    0.2823407    5
    seq.2474.54 -10.234554 0.0001932281   1.000193 0.02889851 0.03316901    0.2889851    6

