# `calc.cor()` with `method = pearson` generates correct values

    
    == Stat Table Info: Pearson's product-moment correlation ===========================================
      Call                      calc.cor(data = log10(small_adat), response = "HybControlNormScale", method = "pearson")
      Data Frame                log10(small_adat)
      Data Dims                 20 x 11
      Table Dims                10 x 8
      Statistical Test          Pearson's product-moment correlation
      Response                  HybControlNormScale
      Log Transform             TRUE
      Number of samples         20
      Independent Variable      HybControlNormScale
    
    -- Stat Table --------------------------------------------------------------------------------------
                         r    t.stat     loCI95     upCI95      p.value         fdr p.bonferroni rank
    seq.3186.2  -0.6879025 -4.021095 -0.8666158 -0.3527684 0.0008012871 0.005221463  0.008012871    1
    seq.3590.8  -0.6769595 -3.902196 -0.8614245 -0.3347062 0.0010442926 0.005221463  0.010442926    2
    seq.2643.57  0.6021846  3.200139  0.2176678  0.8248895 0.0049609746 0.015295921  0.049609746    3
    seq.5242.37  0.5789233  3.012285  0.1833824  0.8131315 0.0074827327 0.015295921  0.074827327    4
    seq.5317.3   0.5776384  3.002246  0.1815162  0.8124764 0.0076479607 0.015295921  0.076479607    5
    seq.5340.24  0.5632478  2.892040  0.1608083  0.8050987 0.0097108617 0.016184769  0.097108617    6

# `calc.cor()` with `method = spearman` generates correct values

    
    == Stat Table Info: Spearman's rank correlation rho ================================================
      Call                      calc.cor(data = small_adat, response = "HybControlNormScale")
      Data Frame                small_adat
      Data Dims                 20 x 11
      Table Dims                10 x 8
      Statistical Test          Spearman's rank correlation rho
      Response                  HybControlNormScale
      Log Transform             FALSE
      Number of samples         20
      Independent Variable      HybControlNormScale
    
    -- Stat Table --------------------------------------------------------------------------------------
                       rho    S    t.stat      p.value       cov         fdr p.bonferroni rank
    seq.3590.8  -0.7022556 2264 -4.185018 0.0007877796 -24.57895 0.007788859  0.007877796    1
    seq.3186.2  -0.6721805 2224 -3.851795 0.0015577719 -23.52632 0.007788859  0.015577719    2
    seq.2643.57  0.6375940  482  3.511395 0.0031156744  22.31579 0.010385581  0.031156744    3
    seq.5317.3   0.5774436  562  3.000728 0.0087703998  20.21053 0.016815085  0.087703998    4
    seq.5340.24  0.5744361  566  2.977372 0.0091932137  20.10526 0.016815085  0.091932137    5
    seq.5242.37  0.5684211  574  2.931197 0.0100890509  19.89474 0.016815085  0.100890509    6

# `calc.cor()` with `method = kendall` generates correct values

    
    == Stat Table Info: Kendall's rank correlation tau =============================
      Call                      calc.cor(data = small_adat, response = "HybControlNormScale", method = "kendall")
      Data Frame                small_adat
      Data Dims                 20 x 11
      Table Dims                10 x 6
      Statistical Test          Kendall's rank correlation tau
      Response                  HybControlNormScale
      Log Transform             FALSE
      Number of samples         20
      Independent Variable      HybControlNormScale
    
    -- Stat Table ------------------------------------------------------------------
                       tau   T      p.value         fdr p.bonferroni rank
    seq.3590.8  -0.5473684  43 0.0004805755 0.004805755  0.004805755    1
    seq.3186.2  -0.5157895  46 0.0010995222 0.005497611  0.010995222    2
    seq.2643.57  0.4631579 139 0.0037826646 0.012608882  0.037826646    3
    seq.5317.3   0.4421053 137 0.0059237973 0.014809493  0.059237973    4
    seq.5340.24  0.4000000 133 0.0135323737 0.027064747  0.135323737    5
    seq.5242.37  0.3789474 131 0.0197844031 0.031476253  0.197844031    6

