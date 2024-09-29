# the standard defaults to `calc.ks()` are correct

    
    == Stat Table Info: Kolmogorov-Smirnov Test ====================================
      Call                      calc.ks(data = small_adat, response = "SampleGroup")
      Data Frame                small_adat
      Data Dims                 20 x 11
      Table Dims                10 x 6
      Statistical Test          Kolmogorov-Smirnov Test
      Outliers Removed          FALSE
      Response                  SampleGroup
      Response Counts           F=11 vs M=9
    
    -- Stat Table ------------------------------------------------------------------
                  ks.dist signed.ks.dist      p.value          fdr p.bonferroni
    seq.2696.87 0.9090909      0.9090909 0.0001190760 0.0005953799  0.001190760
    seq.4330.4  0.9090909      0.9090909 0.0001190760 0.0005953799  0.001190760
    seq.2819.23 0.8181818      0.8181818 0.0007620862 0.0019052155  0.007620862
    seq.3367.8  0.8181818     -0.8181818 0.0007620862 0.0019052155  0.007620862
    seq.3004.67 0.7272727      0.7272727 0.0040962134 0.0058517334  0.040962134
    seq.3073.51 0.7272727      0.7272727 0.0040962134 0.0058517334  0.040962134
                rank
    seq.2696.87    1
    seq.4330.4     2
    seq.2819.23    3
    seq.3367.8     4
    seq.3004.67    5
    seq.3073.51    6

