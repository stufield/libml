# `calc.jt()` generates the correct output

    
    == Stat Table Info: Mack-Wolfe (JT) Test =======================================
      Call                      calc.mackwolfe(data = small_adat, response = "group", peak = "jt")
      Data Frame                small_adat
      Data Dims                 20 x 11
      Table Dims                10 x 8
      Statistical Test          Mack-Wolfe (JT) Test
      Response                  group
      Response Counts           A=5 vs B=5 vs C=5 vs D=5
      Factor order              A-B-C-D
      Peak                      jt
    
    -- Stat Table ------------------------------------------------------------------
                 Ap     Astar  n      peak      p.value         fdr p.bonferroni
    seq.3332.57  25 -3.364633 20 D | k = 4 0.0007664555 0.007664555  0.007664555
    seq.3804.66  31 -2.960877 20 D | k = 4 0.0030676445 0.011726943  0.030676445
    seq.2670.67  32 -2.893584 20 D | k = 4 0.0038087202 0.011726943  0.038087202
    seq.3401.8   34 -2.758999 20 D | k = 4 0.0057978713 0.011726943  0.057978713
    seq.2632.5   35 -2.691706 20 D | k = 4 0.0071087509 0.011726943  0.071087509
    seq.2789.26 115  2.691706 20 D | k = 4 0.0071087509 0.011726943  0.071087509
                rank
    seq.3332.57    1
    seq.3804.66    2
    seq.2670.67    3
    seq.3401.8     4
    seq.2632.5     5
    seq.2789.26    6

# `calc.mackwolfe()` generates the correct output

    
    == Stat Table Info: Mack-Wolfe Test ============================================
      Call                      calc.mackwolfe(data = small_adat, response = "group", peak = "B")
      Data Frame                small_adat
      Data Dims                 20 x 11
      Table Dims                10 x 8
      Statistical Test          Mack-Wolfe Test
      Response                  group
      Response Counts           A=5 vs B=5 vs C=5 vs D=5
      Factor order              A-B-C-D
      Peak                      B
    
    -- Stat Table ------------------------------------------------------------------
                Ap     Astar  n      peak    p.value       fdr p.bonferroni rank
    seq.2632.5  73  1.852391 20 B | k = 2 0.06396974 0.4198612    0.6396974    1
    seq.3804.66 71  1.691313 20 B | k = 2 0.09077699 0.4198612    0.9077699    2
    seq.3580.25 31 -1.530236 20 B | k = 2 0.12595837 0.4198612    1.0000000    3
    seq.2875.15 66  1.288620 20 B | k = 2 0.19753036 0.4938259    1.0000000    4
    seq.3332.57 64  1.127542 20 B | k = 2 0.25951332 0.5190266    1.0000000    5
    seq.2670.67 61  0.885926 20 B | k = 2 0.37565741 0.5770828    1.0000000    6

