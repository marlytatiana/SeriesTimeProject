#D:\1_master\app_macro\stayover_vistors.spc was created on 3/9/2021 5:31:23 PM
#Created using X-13A-S version 1.1 build 39

series{ 
    file = "stayover_vistors.dat"
    period = 12
    format = Datevalue
}
transform{ 
    function = log
}
regression{ 
    variables = ( td   easter[8] )
    #aictest = ( td easter )
    #savelog = aictest
}
outlier{ 
    types = ( AO LS )
}
arima{ 
    model =  (0 1 0)(0 1 1)
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
