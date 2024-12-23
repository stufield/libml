# `kfold_cv()` generates correct output for various model types

    Code
      args$model_type <- "lr"
      withr::with_seed(101, summary(do.call(kfold_cv, args)))
    Output
             truth      predicted            fold     
       setosa   :50   Min.   :0.08712   Min.   :1.00  
       virginica:50   1st Qu.:0.25338   1st Qu.:1.00  
                      Median :0.45333   Median :2.00  
                      Mean   :0.49175   Mean   :1.99  
                      3rd Qu.:0.71442   3rd Qu.:3.00  
                      Max.   :0.92809   Max.   :3.00  

---

    Code
      args$model_type <- "nb"
      withr::with_seed(101, summary(do.call(kfold_cv, args)))
    Output
             truth      predicted              fold     
       setosa   :50   Min.   :0.0000064   Min.   :1.00  
       virginica:50   1st Qu.:0.0008608   1st Qu.:1.00  
                      Median :0.5889413   Median :2.00  
                      Mean   :0.5071542   Mean   :1.99  
                      3rd Qu.:0.9992074   3rd Qu.:3.00  
                      Max.   :0.9999999   Max.   :3.00  

---

    Code
      args$model_type <- "rf"
      withr::with_seed(101, summary(do.call(kfold_cv, args)))
    Output
             truth      predicted           fold     
       setosa   :50   Min.   :0.0360   Min.   :1.00  
       virginica:50   1st Qu.:0.2590   1st Qu.:1.00  
                      Median :0.4400   Median :2.00  
                      Mean   :0.4760   Mean   :1.99  
                      3rd Qu.:0.7005   3rd Qu.:3.00  
                      Max.   :0.9660   Max.   :3.00  

---

    Code
      args$model_type <- "svm"
      withr::with_seed(101, summary(do.call(kfold_cv, args)))
    Output
             truth      predicted           fold     
       setosa   :50   Min.   :0.2270   Min.   :1.00  
       virginica:50   1st Qu.:0.2839   1st Qu.:1.00  
                      Median :0.3842   Median :2.00  
                      Mean   :0.4864   Mean   :1.99  
                      3rd Qu.:0.6877   3rd Qu.:3.00  
                      Max.   :0.8306   Max.   :3.00  

---

    Code
      args$model_type <- "gbm"
      withr::with_seed(101, summary(do.call(kfold_cv, args)))
    Output
      Distribution not specified, assuming bernoulli ...
      Distribution not specified, assuming bernoulli ...
      Distribution not specified, assuming bernoulli ...
             truth      predicted            fold     
       setosa   :50   Min.   :0.08452   Min.   :1.00  
       virginica:50   1st Qu.:0.26564   1st Qu.:1.00  
                      Median :0.57463   Median :2.00  
                      Mean   :0.52213   Mean   :1.99  
                      3rd Qu.:0.76505   3rd Qu.:3.00  
                      Max.   :0.94849   Max.   :3.00  

---

    Code
      args$model_type <- "kknn"
      args$k_neighbors <- 5
      withr::with_seed(101, summary(do.call(kfold_cv, args)))
    Output
             truth      predicted           fold     
       setosa   :50   Min.   :0.0000   Min.   :1.00  
       virginica:50   1st Qu.:0.2614   1st Qu.:1.00  
                      Median :0.4345   Median :2.00  
                      Mean   :0.4870   Mean   :1.99  
                      3rd Qu.:0.7363   3rd Qu.:3.00  
                      Max.   :1.0000   Max.   :3.00  

