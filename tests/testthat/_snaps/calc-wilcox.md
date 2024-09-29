# calc.wilcox Rank-Sum (M-W) generates the correct output table

    
    == Stat Table Info: Wilcoxon rank-sum test (Mann-Whitney) ======================
      Call                      calc.wilcox(data = small_adat, response = "SampleGroup")
      Data Frame                small_adat
      Data Dims                 20 x 11
      Table Dims                10 x 5
      Statistical Test          Wilcoxon rank-sum test (Mann-Whitney)
      Paired Samples            FALSE
      Outliers Removed          FALSE
      Response                  SampleGroup
      Response Counts           F=11 vs M=9
    
    -- Stat Table ------------------------------------------------------------------
                 U      p.value          fdr p.bonferroni rank
    seq.4330.4  98 2.381519e-05 0.0002381519 0.0002381519    1
    seq.3004.67 92 5.358419e-04 0.0026792093 0.0053584187    2
    seq.2696.87 90 1.155037e-03 0.0028875923 0.0115503691    3
    seq.2819.23 90 1.155037e-03 0.0028875923 0.0115503691    4
    seq.2953.31 13 4.239105e-03 0.0060558636 0.0423910455    5
    seq.3073.51 86 4.239105e-03 0.0060558636 0.0423910455    6

