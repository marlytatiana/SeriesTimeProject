#D:\1_master\app_macro\series_copy_cruise2.spc was created on 3/16/2021 6:49:35 PM
#Created using X-13A-S version 1.1 build 39

series{ 
    file = "series_copy_cruise2.dat"
    period = 12
    format = Datevalue
}
transform{ 
    function = none
}
regression{ 
    variables = ( td1coef  AO2012.May )
    #aictest = ( td easter )
    #savelog = aictest
}
outlier{ 
    types = ( AO LS )
}
arima{ 
    model =  (1 0 0)(1 1 1)
}
forecast{ 
    maxlead = 12
    print = none
}
estimate{ 
    print = (roots regcmatrix acm)
    savelog = (aicc aic bic hq afc)
}
check{ 
    print = all
    savelog = (lbq nrm)
}
seats{ }
slidingspans{ 
    savelog = percent
    additivesa = percent
}
history{ 
    estimates = (fcst aic sadj sadjchng trend trendchng)
    savelog = (asa ach atr atc)
}
