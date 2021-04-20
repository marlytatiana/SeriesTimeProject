	return list 
	scalar z_statistic = r(Zt)
	scalar p_value = r(p)
	
			
	esttab matrix(unit_roots) using ${other}example.tex, cells(r1 r2 r3 r4) replace  nonumber nomtitle collabels("Camplet" "X13" "Camplet 2" "X13 2") booktabs label 
	
	
	booktabs label   ///
	mgroups(A B, pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))    
		
	alignment(D{.}{.}{-1}) page(dcolumn) nonumber
	
	estout matrix(unit_roots) using ${other}example2.tex,replace
	
	
esttab using "${OUTPATH}numberresponsesw.tex", ///
	cells("mean(fmt(a2) label(Mean)) sd(fmt(a2) label(Std.\ Dev.)) p25(fmt(a2) label(25\%)) p50(fmt(a2) label(50\%)) p75(fmt(a2) label(75\%))  p95(fmt(a2) label(95\%)) max(fmt(a2) label(Max.)) anys(fmt(a2) label(Frac.\ $>0$))") ///
	nostar nonumbers nomtitle label booktabs width(38em) replace

	dfuller sa_ln_cruisevisitors , trend
  dfuller cruise1_seasAdj , trend

  dfuller sa_ln_cruisevisitors , drift
  dfuller cruise1_seasAdj , drift
  
    dfuller sa_ln_cruisevisitors , constant
  dfuller cruise1_seasAdj , constant
  
  // Test for stay
  
	dfuller sa_ln_stayovervisitors 
	dfuller stay1_seasAdj
  * I cannot reject the null hypothesis that log Stay Over vistors exhibits a unit root.
	
	dfuller sa_ln_stayovervisitors , trend
	dfuller stay1_seasAdj , trend
	
	dfuller sa_ln_stayovervisitors , drift
	dfuller stay1_seasAdj , drift

	dfuller sa_ln_stayovervisitors , noconstant
	dfuller stay1_seasAdj , noconstant
esttab matrix(unit_roots, fmt(3 3 3 3))


local i=1
foreach var of varlist sa_ln_cruisevisitors {
	dfuller `var' 
	matrix unit_roots_d1[`i',1] = r(Zt)
	matrix unit_roots_d1[`i',2] = r(p)
	
	dfuller `var', trend
	matrix unit_roots_d1[++`i',1] = r(Zt)
	matrix unit_roots_d1[++`i',2] = r(p)

	dfuller `var', drift
	matrix unit_roots_d1[`i',1] = r(Zt)
	matrix unit_roots_d1[`i',2] = r(p)

	dfuller `var', constant
	matrix unit_roots_d1[`i',1] = r(Zt)
	matrix unit_roots_d1[`i',2] = r(p)
	
 local ++i
}
  