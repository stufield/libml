# `mack_wolfe()` returns correctly with peak known at 'B'

    == Mack-Wolfe test for umbrella alternatives (peak known) ======================
    
    • Ap       = '324'
    • Ap*      = '3.5796'
    • n        = '40'
    • p_value  = '0.00034416'
    • Acrit    = '1.6449'
    • alpha    = '0.05'
    • groups   = 'A', 'B', 'C', 'D'
    • peak     = 'B | k = 2'
    
    ================================================================================

# `mack_wolfe()` with peak *unknown* and a true peak at 'B'

    == Mack-Wolfe test for umbrella alternatives (peak unknown) ====================
    
    • Ap*      = '3.5796'
    • n        = '40'
    • p_value  = '0.00034416'
    • Acrit    = '1.6449'
    • alpha    = '0.05'
    • groups   = 'A', 'B', 'C', 'D'
    • peak     = 'B | k = 2'
    
    ================================================================================

# `mack_wolfe()` generates the expected output when `rm_outliers = TRUE`

    == Mack-Wolfe test for umbrella alternatives (peak known) ======================
    
    • Ap       = '277'
    • Ap*      = '3.2125'
    • n        = '38'
    • p_value  = '0.0013157'
    • Acrit    = '1.6449'
    • alpha    = '0.05'
    • groups   = 'A', 'B', 'C', 'D'
    • peak     = 'B | k = 2'
    
    ================================================================================

