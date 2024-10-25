# the `calc.t()` generates the expected output

    
    == Stat Table Info: Student t-test =============================================
      Call                      calc.t(data = small_adat, response = "SampleGroup")
      Data Frame                small_adat
      Data Dims                 20 x 11
      Table Dims                10 x 6
      Statistical Test          Student t-test
      Paired Samples            FALSE
      Outliers Removed          FALSE
      Response                  SampleGroup
      Response Counts           F=11 vs M=9
      Log Transform             TRUE
    
    -- Stat Table ------------------------------------------------------------------
                  t.stat signed.t.stat      p.value         fdr p.bonferroni rank
    seq.4330.4  5.541888      5.541888 0.0002123847 0.002123847  0.002123847    1
    seq.2819.23 3.847544      3.847544 0.0014363355 0.007181678  0.014363355    2
    seq.2953.31 3.656757     -3.656757 0.0024332809 0.008110936  0.024332809    3
    seq.2474.54 3.231235      3.231235 0.0047535587 0.011631849  0.047535587    4
    seq.2711.6  3.168877      3.168877 0.0058159246 0.011631849  0.058159246    5
    seq.3396.54 3.292163      3.292163 0.0076893340 0.011983131  0.076893340    6

