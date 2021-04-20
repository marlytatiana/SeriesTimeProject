********************************************************************************
*     TITLE:   Assignment 1 Applied Macroeconometrics 2021
*                                                                              *
*     WRITTEN BY:             Marly Tatiana Celis Galvez		               *
*     VERSION :               											       *
*                                                                              *
*                                                                              *
*	The order of this dofile goes as follows: 		               			   *
/*		               			   	       									   *
	Descriptive graphs		line 71-159 		               			   	   *
	Import adjusted series 	line 167-290		               			   	   *
	Graphs new series		line 330-557		               			   	   *
	Dfuller 				line 582		               			   	       *
	KPSS 					line 779		               			   	       * 
	Granger 				line 940		               			   	       *
	Jonhhansen test 		line 957 		               			   	       *
	Beveridge-Nelson cycle  line 973  		               			   	       *
*/
********************************************************************************
********************************************************************************
clear all
set more off

*adopath + “C:\x13sam”
*sax12 Shipcalls, satype(single)

*cd "C:\Users\ASUS\Dropbox\UU_master\2nd_year\Macroeconometrics\1_assignment" 
global path "D:/1_master/app_macro/" 
global graphs "D:/1_master/app_macro/graphs/"
global other "D:/1_master/app_macro/other/"
di "$path"
cd "$path"
cap log close
log using "assignment_1", replace

********************************************************************************
********************************************************************************

/*
* Import original files from excel and save as Stata format
*Note1: this is the original data downloaded from nestr.rug 
*Note2: the file contains three additional columns, not in the orginal
*excel file. Time (combination year-month) and natural logs of cruise visitors
*and natural logs of stay over visitors 
import excel using "${path}tourism series.xlsx", firstrow
describe
save "${path}tourism_series.dta", replace
*/

********************************************************************************
********************************************************************************

use "${path}tourism_series.dta",clear

gen date= ym(Year,Month)
format date %tm
tsset date, monthly
lab var ln_cruisevisitors "Ln Cruise visitors"
lab var ln_stayovervisitors "Ln Stay-over visitors"
lab var date "Months"
********************************************************************************
********************************************************************************

*First, Informative graphs
*Design informative graphs of and describe patterns in the series of
*cruise visitors and stay-over visitors to Aruba.


********************************************************************************
********************************************************************************


foreach var of varlist Stayovervisitorsin1000 Visitorsnightsin1000 Cruisevisitorsin1000  Shipcalls ln_cruisevisitors ln_stayovervisitors  {
tw tsline `var', saving(`var',replace) xtitle("") xlabel(, noticks format(%tm) ///
labsize(small) grid)  scheme(s2mono)
graph export ${graphs}l`var'.png, replace 
}



// the corregram
// Autocorrelations, partial autocorrelations, and portmanteau (Q) statistics
 
corrgram Stayovervisitorsin1000 

pergram Stayovervisitorsin1000, graphregion(color(white)) ///
plotregion( color(white)) xlabel(, noticks format(%tm) ///
labsize(small) grid) xtitle("")  saving( ${graphs}pergram_1,replace) 
	graph export  ${graphs}pergram_1.png, replace

ac Stayovervisitorsin1000, graphregion(color(white)) ///
plotregion( color(white)) xlabel(, noticks format(%tm) ///
labsize(small) grid) xtitle("") saving( ${graphs}stay_ac_1,replace) 
	graph export  ${graphs}stay_ac_1.png, replace

pac Stayovervisitorsin1000, graphregion(color(white)) ///
plotregion( color(white)) xlabel(, noticks format(%tm) ///
labsize(small) grid) xtitle("") srv saving( ${graphs}stay_pac_1,replace) 
	graph export  ${graphs}stay_pac_1.png, replace




corrgram Cruisevisitorsin1000 

pergram Cruisevisitorsin1000 , graphregion(color(white)) ///
plotregion( color(white)) xlabel(, noticks format(%tm) ///
labsize(small) grid) xtitle("")  saving( ${graphs}pergram_2,replace) 
	graph export  ${graphs}pergram_2.png, replace


ac Cruisevisitorsin1000 , graphregion(color(white)) ///
plotregion( color(white)) xlabel(, noticks format(%tm) ///
labsize(small) grid) xtitle("") saving( ${graphs}cruise_ac_1,replace) 
	graph export  ${graphs}cruise_ac_1.png, replace

pac Cruisevisitorsin1000 , graphregion(color(white)) ///
plotregion( color(white)) xlabel(, noticks format(%tm) ///
labsize(small) grid) xtitle("") srv saving( ${graphs}cruise_pac_1,replace) 
	graph export  ${graphs}cruise_pac_1.png, replace

*Graph cumulative spectral distribution
*Because the data are monthly, there will be a pronounced
*jump in the cumulative sample spectral-distribution plot at the 1=12 value if there is an annual cycle
*in the data
cumsp Cruisevisitorsin1000 , xline(.083333333) graphregion(color(white)) saving( ${graphs}cruise_spect_1,replace) 
	graph export  ${graphs}cruise_spect_1.png, replace

cumsp Stayovervisitorsin1000 , xline(.083333333) graphregion(color(white)) saving( ${graphs}stay_spect_1,replace) 
	graph export  ${graphs}stay_spect_1.png, replace


// the timeline of the two series

tw tsline  Cruisevisitorsin1000 Stayovervisitorsin1000,  graphregion(color(white)) ///
plotregion( color(white)) xlabel(, noticks format(%tm) ///
labsize(small) grid) xtitle("") saving(${graphs}orginal_nologs,replace)
	graph export ${graphs}orginal_nologs.png, replace

tw (tsline ln_cruisevisitors , yaxis(1) ) (tsline  ln_stayovervisitors, yaxis(2) graphregion(color(white)) plotregion( color(white)) xtitle("") xlabel(, noticks format(%tm) labsize(small) grid) saving( ${graphs}series_originales,replace)  )
	graph export  ${graphs}series_originales.png, replace


// test if the log transformation should be used and a multiplicative adjustment performed

*Second, how would you proceedmodelling the relationship between the two variables
*tw tsline Stayovervisitorsin1000 Cruisevisitorsin1000 
*xcorr Cruisevisitorsin1000 Stayovervisitorsin1000 

// correlacion entre variables y el PIB departamental
graph matrix  Stayovervisitorsin1000 Cruisevisitorsin1000 ,graphregion(color(white)) ///
plotregion( color(white)) graphregion(color(white)) saving( ${graphs}correlation_1,replace) 
	graph export  ${graphs}correlation_1.png, replace
*half


reg Cruisevisitorsin1000 Stayovervisitorsin1000 date
reg Stayovervisitorsin1000 Cruisevisitorsin1000 date

reg Stayovervisitorsin1000 date
reg Cruisevisitorsin1000 date





*Compare outcomes for the seasonally adjusted series data.

*
preserve
import excel using "${path}series_adj_camplet_1.xlsx", firstrow  sheet("SA") clear
rename  ln_cruisevisitors  sa_ln_cruisevisitors
label var sa_ln_cruisevisitors "Adjusted Cruise Visitors"
rename  ln_stayovervisitors sa_ln_stayovervisitors
label var sa_ln_stayovervisitors "Adjusted Stay-Over Visitors"
drop  cruise_vistors stayover_vistors
save "${path}tourism_camplet_1_sa.dta", replace
restore

preserve
import excel using "${path}series_adj_camplet_1.xlsx", firstrow  sheet("Season") clear     
rename  ln_cruisevisitors  seas_ln_cruisevisitors
label var seas_ln_cruisevisitors "Seasonal Component Cruise Visitors"
rename  ln_stayovervisitors seas_ln_stayovervisitors
label var seas_ln_stayovervisitors "Seasonal Component StayOver Visitors"
drop  cruise_vistors stayover_vistors
save "${path}tourism_camplet_1_seas.dta", replace
restore

preserve
import excel using "${path}series_adj_camplet_2.xlsx", firstrow  sheet("SA") clear
rename  ln_cruisevisitors  sa2_ln_cruisevisitors
label var sa2_ln_cruisevisitors "Adjusted 2 Cruise Visitors"
rename  ln_stayovervisitors sa2_ln_stayovervisitors
label var sa2_ln_stayovervisitors "Adjusted 2 Stay-Over Visitors"
drop  cruise_vistors stayover_vistors
save "${path}tourism_camplet_2_sa.dta", replace
restore

preserve
import excel using "${path}series_adj_camplet_2.xlsx", firstrow  sheet("Season") clear     
rename  ln_cruisevisitors  seas2_ln_cruisevisitors
label var seas2_ln_cruisevisitors "Seasonal Component Cruise Visitors"
rename  ln_stayovervisitors seas2_ln_stayovervisitors
label var seas2_ln_stayovervisitors "Seasonal Component StayOver Visitors"
drop  cruise_vistors stayover_vistors
save "${path}tourism_camplet_2_seas.dta", replace
restore

preserve
import excel using "${path}series_1_stay_x13seats.xlsx", firstrow  clear     
gen month=month(date)
gen yr=year(date)
egen Time=concat(yr month), punct("-")

	rename FinalSEATSCombinedAdjustment stay1_comAdjust
	rename FinalSEATSIrregularComponent stay1_irrComp
	rename FinalSEATSSeasonalAdjustment stay1_seasAdj
	rename FinalSEATSSeasonalComponent stay1_seasComp
	rename FinalSEATSTrendComponent stay1_trendComp

save "${path}tourism_x13_stay_1.dta", replace
restore

preserve
import excel using "${path}series_1_cruise_x13seats.xlsx", firstrow  clear     
gen month=month(date)
gen yr=year(date)
egen Time=concat(yr month), punct("-")

	rename FinalSEATSCombinedAdjustment cruise1_comAdjust
	rename FinalSEATSIrregularComponent cruise1_irrComp
	rename FinalSEATSSeasonalAdjustment cruise1_seasAdj
	rename FinalSEATSSeasonalComponent cruise1_seasComp
	rename FinalSEATSTrendComponent cruise1_trendComp

save "${path}tourism_x13_cruise_1.dta", replace
restore

preserve
import excel using "${path}series_2_stay_x13seats.xlsx", firstrow  clear     
gen month=month(date)
gen yr=year(date)
egen Time=concat(yr month), punct("-")

	rename FinalSEATSCombinedAdjustment stay2_comAdjust
	rename FinalSEATSIrregularComponent stay2_irrComp
	rename FinalSEATSSeasonalAdjustment stay2_seasAdj
	rename FinalSEATSSeasonalComponent stay2_seasComp
	rename FinalSEATSTrendComponent stay2_trendComp

save "${path}tourism_x13_stay_2.dta", replace
restore

preserve
import excel using "${path}series_2_cruise_x13seats.xlsx", firstrow  clear     
gen month=month(date)
gen yr=year(date)
egen Time=concat(yr month), punct("-")

	rename FinalSEATSCombinedAdjustment cruise2_comAdjust
	rename FinalSEATSIrregularComponent cruise2_irrComp
	rename FinalSEATSSeasonalAdjustment cruise2_seasAdj
	rename FinalSEATSSeasonalComponent cruise2_seasComp
	rename FinalSEATSTrendComponent cruise2_trendComp
	
save "${path}tourism_x13_cruise_2.dta", replace
restore




merge 1:1 Time  using "${path}tourism_camplet_1_sa.dta",
	drop _merge
merge 1:1 Time  using "${path}tourism_camplet_1_seas.dta",
	drop _merge
merge 1:1 Time  using "${path}tourism_camplet_2_sa.dta",
	drop _merge
merge 1:1 Time  using "${path}tourism_camplet_2_seas.dta",
	drop _merge
merge 1:1 Time using "${path}tourism_x13_stay_1.dta",
	drop _merge
merge 1:1 Time using "${path}tourism_x13_cruise_1.dta",
	drop _merge
merge 1:1 Time using "${path}tourism_x13_stay_2.dta",
	drop _merge
merge 1:1 Time using "${path}tourism_x13_cruise_2.dta",
	drop _merge

save "${path}all_series.dta"	,replace
/*
*Orginal Series

Stayovervisitorsin1000
Cruisevisitorsin1000

*Log Series
ln_cruisevisitors
ln_stayovervisitors 


*Log Series Adjusted Camplet
	sa_ln_cruisevisitors
	sa_ln_stayovervisitors
	

*Log Series Adjusted X13
	cruise1_seasAdj
	stay1_seasAdj

*Log Series no4 months Camplet
sa2_ln_cruisevisitors
sa2_ln_stayovervisitors

*Log Series no4 months X13
cruise2_seasAdj
stay2_seasAdj
*/

*The whole series
label var sa_ln_cruisevisitors "Cruise Camplet Adj"
label var sa_ln_stayovervisitors "Stay-Over Camplet Adj"

label var cruise1_seasAdj "Cruise X13-Seats Adj"
label var stay1_seasAdj "Stay-Over X13-Seats Adj"

*Without the last four months
label var sa2_ln_cruisevisitors "Cruise2 Camplet Adj"
label var sa2_ln_stayovervisitors "Stay-Over2 Camplet Adj"

label var cruise2_seasAdj "Cruise2 X13-Seats Adj"
label var stay2_seasAdj "Stay-Over2 X13-Seats Adj"

	
// Camplet generates Seasonal Series and the Seasonal Components
*For the full series

/*
sa_ln_cruisevisitors  seas_ln_cruisevisitors

sa_ln_stayovervisitors	seas_ln_stayovervisitors

*For the series minues the last four months
sa2_ln_cruisevisitors seas2_ln_cruisevisitors

sa2_ln_stayovervisitors seas2_ln_stayovervisitors
*/
	
// X13 Arima generates much more information
tsline Cruisevisitorsin1000
tsline ln_cruisevisitors	

// X13 Seats Stay-Over
tsline stay1_comAdjust,  graphregion(color(white)) ///
plotregion( color(white)) xlabel(, noticks format(%tm) ///
labsize(large) grid) xtitle("")  ytitle("Stay - Combined Factors X13", size(large)) ylabel(, labsize(large)) ///
saving( ${graphs}x13_stay_1,replace) lcolor(cranberry)
	graph export  ${graphs}x13_stay_1.png, replace

tsline stay1_irrComp, graphregion(color(white)) ///
plotregion( color(white)) xlabel(, noticks format(%tm) ///
labsize(large) grid) xtitle("")  ytitle("Stay - Irregular X13", size(large)) ylabel(, labsize(large)) ///
saving( ${graphs}x13_stay_2,replace) lcolor(cranberry)
	graph export  ${graphs}x13_stay_2.png, replace

tsline stay1_seasComp, graphregion(color(white)) ///
plotregion( color(white)) xlabel(, noticks format(%tm) ///
labsize(large) grid) xtitle("")  ytitle("Stay - Seasonal X13", size(large)) ylabel(, labsize(large)) ///
saving( ${graphs}x13_stay_3,replace) lcolor(cranberry)
	graph export  ${graphs}x13_stay_3.png, replace

tsline stay1_trendComp, graphregion(color(white)) ///
plotregion( color(white)) xlabel(, noticks format(%tm) ///
labsize(large) grid) xtitle("")  ytitle("Stay - Trend X13", size(large)) ylabel(, labsize(large)) ///
saving( ${graphs}x13_stay_4,replace) lcolor(cranberry)
	graph export  ${graphs}x13_stay_4.png, replace

tsline stay1_seasAdj , graphregion(color(white)) ///
plotregion( color(white)) xlabel(, noticks format(%tm) ///
labsize(large) grid) xtitle("")  ytitle("Stay - Adjusted X13", size(large)) ylabel(, labsize(large)) ///
saving( ${graphs}x13_stay_5,replace) lcolor(cranberry)
	graph export  ${graphs}x13_stay_5.png, replace

	
// X13 Seats Cruise

tsline cruise1_comAdjust,  graphregion(color(white)) ///
plotregion( color(white)) xlabel(, noticks format(%tm) ///
labsize(large) grid) xtitle("")  ytitle("Cruise -Combined Factors X13", size(large)) ylabel(, labsize(large)) ///
saving( ${graphs}x13_crui_1,replace) 
	graph export  ${graphs}x13_crui_1.png, replace

tsline cruise1_irrComp, graphregion(color(white)) ///
plotregion( color(white)) xlabel(, noticks format(%tm) ///
labsize(large) grid) xtitle("")  ytitle("Cruise -Irregular X13", size(large)) ylabel(, labsize(large)) ///
saving( ${graphs}x13_crui_2,replace) 
	graph export  ${graphs}x13_crui_2.png, replace

tsline cruise1_seasComp, graphregion(color(white)) ///
plotregion( color(white)) xlabel(, noticks format(%tm) ///
labsize(large) grid) xtitle("")  ytitle("Cruise -Seasonal X13", size(large)) ylabel(, labsize(large)) ///
saving( ${graphs}x13_crui_3,replace) 
	graph export  ${graphs}x13_crui_3.png, replace

tsline cruise1_trendComp, graphregion(color(white)) ///
plotregion( color(white)) xlabel(, noticks format(%tm) ///
labsize(large) grid) xtitle("")  ytitle("Cruise - Trend X13", size(large)) ylabel(, labsize(large)) ///
saving( ${graphs}x13_crui_4,replace) 
	graph export  ${graphs}x13_crui_4.png, replace

tsline cruise1_seasAdj , graphregion(color(white)) ///
plotregion( color(white)) xlabel(, noticks format(%tm) ///
labsize(large) grid) xtitle("")  ytitle("Cruise - Adjusted X13", size(large)) ylabel(, labsize(large)) ///
saving( ${graphs}x13_crui_5,replace) 
	graph export  ${graphs}x13_crui_5.png, replace


// Camplet generates seasonal adjustment and seasonal component

*Do the seasonal adjustment filters produce similar seasonal patterns?
tsline sa_ln_cruisevisitors , graphregion(color(white)) ///
plotregion( color(white)) xlabel(, noticks format(%tm) ///
labsize(large) grid) xtitle("")  ytitle("Cruise - Adjusted Camplet", size(large)) ylabel(, labsize(large)) ///
saving( ${graphs}cam_crui_1,replace) 
	graph export  ${graphs}cam_crui_1.png, replace

tsline seas_ln_cruisevisitors , graphregion(color(white)) ///
plotregion( color(white)) xlabel(, noticks format(%tm) ///
labsize(large) grid) xtitle("")  ytitle("Cruise - Seasonal Comp Camplet", size(large)) ylabel(, labsize(large)) ///
saving( ${graphs}cam_crui_2,replace) 
	graph export  ${graphs}cam_crui_2.png, replace
		
tsline sa_ln_stayovervisitors, graphregion(color(white)) ///
plotregion( color(white)) xlabel(, noticks format(%tm) ///
labsize(large) grid) xtitle("")  ytitle("Stay - Adjusted Camplet", size(large)) ylabel(, labsize(large)) ///
saving( ${graphs}cam_stay_1,replace) lcolor(cranberry)
	graph export  ${graphs}cam_stay_1.png, replace
	
tsline seas_ln_stayovervisitors, graphregion(color(white)) ///
plotregion( color(white)) xlabel(, noticks format(%tm) ///
labsize(large) grid) xtitle("")  ytitle("Stay - Adjusted Camplet", size(large)) ylabel(, labsize(large)) ///
saving( ${graphs}cam_stay_2,replace) lcolor(cranberry)
	graph export  ${graphs}cam_stay_2.png, replace
	
// About the relation between the series
// Do the seasonal adjustment filters produce similar seasonal patterns?

// Another way Camplet Cruise vs X13 Cruise
tw (tsline sa_ln_cruisevisitors , yaxis(1) lcolor(navy)  lpattern(dash) legend(label(1 "Camplet")) )  ///
(tsline cruise1_seasAdj , yaxis(2)   ytitle("", axis(2))  lcolor(gray) graphregion(color(white)) plotregion( color(white)) xtitle("")  xlabel(, noticks format(%tm) labsize(small) grid) legend(label(2 "X13")) saving( ${graphs}camp_vs_x13_1,replace) ) 
	graph export  ${graphs}camp_vs_x13_1.png, replace

// Another way Camplet Stay vs X13 Stay
tw (tsline sa_ln_stayovervisitors , yaxis(1) lcolor(cranberry)  lpattern(dash) legend(label(1 "Camplet")) )  ///
(tsline stay1_seasAdj , yaxis(2)   ytitle("", axis(2))  lcolor(gray%70) graphregion(color(white)) plotregion( color(white)) xtitle("")  xlabel(, noticks format(%tm) labsize(small) grid) legend(label(2 "X13")) saving( ${graphs}camp_vs_x13_2,replace) ) 
	graph export  ${graphs}camp_vs_x13_2.png, replace

// Another way Camplet Cruise vs X13 Cruise "SEASONAL COMPONENT"
tw (tsline seas_ln_cruisevisitors , yaxis(1) lcolor(navy)  lpattern(dash) legend(label(1 "Camplet")) )  ///
(tsline cruise1_seasComp , yaxis(2)   ytitle("", axis(2))  lcolor(gray) graphregion(color(white)) plotregion( color(white)) xtitle("")  xlabel(, noticks format(%tm) labsize(small) grid) legend(label(2 "X13")) saving( ${graphs}camp_vs_x13_3,replace) ) 
	graph export  ${graphs}camp_vs_x13_3.png, replace

// Another way Camplet Stay vs X13 Stay "SEASONAL COMPONENT"
tw (tsline seas_ln_stayovervisitors , yaxis(1) lcolor(cranberry)  lpattern(dash) legend(label(1 "Camplet")) )  ///
(tsline stay1_seasComp , yaxis(2)   ytitle("", axis(2))  lcolor(gray%70) graphregion(color(white)) plotregion( color(white)) xtitle("")  xlabel(, noticks format(%tm) labsize(small) grid) legend(label(2 "X13")) saving( ${graphs}camp_vs_x13_2,replace) ) 
	graph export  ${graphs}camp_vs_x13_4.png, replace

	
	
	
// 	One way Camplet Cruise vs Stay

tw (tsline sa_ln_cruisevisitors , yaxis(1) legend(label(1 "Cruise")) ) ///
(tsline sa_ln_stayovervisitors  , yaxis(2) legend(label(2 "Stay-Over")) graphregion(color(white)) ///
plotregion( color(white)) xtitle("") xlabel(, noticks format(%tm) labsize(large) grid) saving( ${graphs}cruise_stay_camplet_1,replace) ) 
	graph export  ${graphs}cruise_stay_camplet_1.png, replace

// 	One way X13 Cruise vs Stay

tw (tsline cruise1_seasAdj	, yaxis(1) legend(label(1 "Cruise")	) 	) ///
(tsline  stay1_seasAdj		, yaxis(2) legend(label(2 "Stay-Over")) 	graphregion(color(white)) ///
plotregion( color(white)) xtitle("") xlabel(, noticks format(%tm) labsize(small) grid)  saving( ${graphs}cruise_stay_x13_1,replace) ) 
	graph export  ${graphs}cruise_stay_x13_1.png, replace


	
/*
tw rarea sa_ln_stayovervisitors stay1_seasAdj date
tw rarea sa_ln_cruisevisitors cruise1_seasAdj date
// Ofcourse scales are different
tw rarea sa_ln_cruisevisitors sa_ln_stayovervisitors date
tw rarea cruise1_seasAdj stay1_seasAdj date

tsrline sa_ln_stayovervisitors stay1_seasAdj
tsrline cruise1_seasAdj stay1_seasAdj 
tsline sa_ln_stayovervisitors stay1_seasAdj
**
tsline seas_ln_cruisevisitors

tsline seas_ln_stayovervisitors
*/


*What happens if the last year of quarterly observations is discarded in the seasonal adjustment?
*series_2_cruise_x13seats

*series_2_stay_x13seats


*Second round
tsline sa2_ln_cruisevisitors cruise2_seasAdj, graphregion(color(white)) ///
plotregion( color(white)) xtitle("") xlabel(, noticks format(%tm) ///
labsize(small) grid)  


tsline sa2_ln_stayovervisitors stay2_seasAdj, graphregion(color(white)) ///
plotregion( color(white)) xtitle("") xlabel(, noticks format(%tm) ///
labsize(small) grid)  

*between series

tsline sa2_ln_cruisevisitors sa2_ln_stayovervisitors, graphregion(color(white)) ///
plotregion( color(white)) xtitle("") xlabel(, noticks format(%tm) ///
labsize(small) grid)  

tw (tsline sa2_ln_cruisevisitors , yaxis(1) ) (tsline  sa2_ln_stayovervisitors, yaxis(2) graphregion(color(white)) plotregion( color(white)) xtitle("") xlabel(, noticks format(%tm) labsize(small) grid) )

tw (tsline cruise2_seasAdj , yaxis(1) ) (tsline  stay2_seasAdj, yaxis(2) graphregion(color(white)) plotregion( color(white)) xtitle("") xlabel(, noticks format(%tm) labsize(small) grid) )




// Another way Camplet Cruise vs X13 Cruise
tw (tsline sa2_ln_cruisevisitors , yaxis(1) lcolor(navy)  lpattern(dash) legend(label(1 "Camplet 2")) )  ///
(tsline cruise2_seasAdj , yaxis(2)   ytitle("", axis(2))  lcolor(gray) graphregion(color(white)) plotregion( color(white)) xtitle("")  xlabel(, noticks format(%tm) labsize(small) grid) legend(label(2 "X13 2")) saving( ${graphs}camp_vs_x13_1_b,replace) ) 
	graph export  ${graphs}camp_vs_x13_1_b.png, replace

// Another way Camplet Stay vs X13 Stay
tw (tsline sa2_ln_stayovervisitors , yaxis(1) lcolor(cranberry)  lpattern(dash) legend(label(1 "Camplet 2")) )  ///
(tsline stay2_seasAdj , yaxis(2)   ytitle("", axis(2))  lcolor(gray%70) graphregion(color(white)) plotregion( color(white)) xtitle("")  xlabel(, noticks format(%tm) labsize(small) grid) legend(label(2 "X13 2")) saving( ${graphs}camp_vs_x13_2_b,replace) ) 
	graph export  ${graphs}camp_vs_x13_2_b.png, replace
	
	
// 	One way Camplet Cruise vs Stay

tw (tsline sa2_ln_cruisevisitors , yaxis(1) legend(label(1 "Cruise2")) ) ///
(tsline sa2_ln_stayovervisitors  , yaxis(2) legend(label(2 "Stay-Over2")) graphregion(color(white)) ///
plotregion( color(white)) xtitle("") xlabel(, noticks format(%tm) labsize(large) grid) saving( ${graphs}cruise_stay_camplet_1_b,replace) ) 
	graph export  ${graphs}cruise_stay_camplet_1_b.png, replace

// 	One way X13 Cruise vs Stay

tw (tsline cruise2_seasAdj	, yaxis(1) legend(label(1 "Cruise2")	) 	) ///
(tsline  stay2_seasAdj		, yaxis(2) legend(label(2 "Stay-Over2")) 	graphregion(color(white)) ///
plotregion( color(white)) xtitle("") xlabel(, noticks format(%tm) labsize(small) grid)  saving( ${graphs}cruise_stay_x13_1_b,replace) ) 
	graph export  ${graphs}cruise_stay_x13_1_b.png, replace


	
	

********************************************************************************
********************************************************************************
*                                                                              *
*                                                                              *
*Do the seasonally adjusted data lead to changes in your modelling 
*approach described above?
*
*Exercise 2. Stationarity and Granger-causality
*******Test both visitors series for unit roots using ADF and KPSS tests.
*What are your findings?
*******Test the two seasonally adjusted visitors series for Granger-causality.
*What do you find? Do you think this outcome is plausible? Motivate
*your answer.
/*
*ADF
The null hypothesis is that the variable contains a unit root, and the alternative
    is that the variable was generated by a stationary process.  
	You may optionally exclude the constant, include a trend term, 
	and include lagged values of the difference of the
    variable in the regression.
*/
*                                                                              *
*                                                                              *
********************************************************************************
********************************************************************************



  
  // Test for stationarity

matrix unit_roots = J(8,4,0)
matrix rowname unit_roots  = "UnitRoot:Zt" "UnitRoot:p" "Trend:Zt" "Trend:p" "Drift:Zt" "Drift:p" "Constant:Zt" "Constant:p"

matrix colnames unit_roots  = cruise_cam cruise_x13 stay_cam stay_x13 

	dfuller sa_ln_cruisevisitors 
	
	matrix unit_roots[1,1] = r(Zt)
	matrix unit_roots[2,1] = r(p)
	
	dfuller sa_ln_cruisevisitors, trend 

	matrix unit_roots[3,1] = r(Zt)
	matrix unit_roots[4,1] = r(p)
	
	dfuller sa_ln_cruisevisitors, drift 

	matrix unit_roots[5,1] = r(Zt)
	matrix unit_roots[6,1] = r(p)

	dfuller sa_ln_cruisevisitors, constant 

	matrix unit_roots[7,1] = r(Zt)
	matrix unit_roots[8,1] = r(p)

	
	dfuller cruise1_seasAdj
	
	matrix unit_roots[1,2] = r(Zt)
	matrix unit_roots[2,2] = r(p)

	dfuller cruise1_seasAdj, trend
	
	matrix unit_roots[3,2] = r(Zt)
	matrix unit_roots[4,2] = r(p)
		
	dfuller cruise1_seasAdj, drift
	
	matrix unit_roots[5,2] = r(Zt)
	matrix unit_roots[6,2] = r(p)
		
	dfuller cruise1_seasAdj, constant
	
	matrix unit_roots[7,2] = r(Zt)
	matrix unit_roots[8,2] = r(p)
						
	dfuller sa_ln_stayovervisitors
	
	matrix unit_roots[1,3] = r(Zt)
	matrix unit_roots[2,3] = r(p)
	
	dfuller sa_ln_stayovervisitors, trend
	
	matrix unit_roots[3,3] = r(Zt)
	matrix unit_roots[4,3] = r(p)

	dfuller sa_ln_stayovervisitors, drift
	
	matrix unit_roots[5,3] = r(Zt)
	matrix unit_roots[6,3] = r(p)
	
	dfuller sa_ln_stayovervisitors, constant
	
	matrix unit_roots[7,3] = r(Zt)
	matrix unit_roots[8,3] = r(p)
	
	
	dfuller stay1_seasAdj	
		
	matrix unit_roots[1,4] = r(Zt)
	matrix unit_roots[2,4] = r(p)

	dfuller stay1_seasAdj, trend
	
	matrix unit_roots[3,4] = r(Zt)
	matrix unit_roots[4,4] = r(p)

	dfuller stay1_seasAdj, drift

	matrix unit_roots[5,4] = r(Zt)
	matrix unit_roots[6,4] = r(p)

	dfuller stay1_seasAdj, constant
	
	matrix unit_roots[7,4] = r(Zt)
	matrix unit_roots[8,4] = r(p)

	estadd matrix unit_roots 
	
	esttab matrix(unit_roots, fmt(3 3 3 3)) , cells((cruise_cam(label(Camplet))) (cruise_x13(label(X13))) (stay_cam(label(Camplet2))) (stay_x13(label(X132)))) collabels("Cruise C" "Cruise X13" "StayO C" "StayO X13 ") 
	
	esttab matrix(unit_roots) using ${other}example.tex, ///
	cells("cruise_cam(fmt(a2) label(Mean)) cruise_x13(fmt(a2) label(Std.\ Dev.))  stay_cam(fmt(a2) label(25\%))  stay_x13(fmt(a2) label(50\%))") nostar nonumbers nomtitle label booktabs width(38em) collabels("Cruise C" "Cruise X13" "StayO C" "StayO X13 ")  replace

	estout matrix(unit_roots, fmt(3 3 3 3)) using example2.tex, replace cells( cruise_cam cruise_x13 stay_cam stay_x13) collabels("Cruise C" "Cruise X13" "StayO C" "StayO X13 ") mgroups(Cruise StayO) style(tex)
		
  *With the seasonal adjusted series by Camplet I can reject the null hypothesis that log cruise visistors exhibits a unit root.
  
  * With the seasonal adjusted series by X13 Arima I cannot reject the null hypothesis that the cruise and stay over exihibit a unit root
  

matrix unit_roots_d1 = J(8,4,0)
matrix rowname unit_roots_d1  = "UnitRoot:Zt" "UnitRoot:p" "Trend:Zt" "Trend:p" "Drift:Zt" "Drift:p" "Constant:Zt" "Constant:p"
matrix colnames unit_roots_d1  = cruise_cam cruise_x13 stay_cam stay_x13 


	dfuller D1.sa_ln_cruisevisitors ,reg
	
	matrix unit_roots_d1[1,1] = r(Zt)
	matrix unit_roots_d1[2,1] = r(p)
	
	dfuller D1.sa_ln_cruisevisitors, trend 

	matrix unit_roots_d1[3,1] = r(Zt)
	matrix unit_roots_d1[4,1] = r(p)
	
	dfuller D1.sa_ln_cruisevisitors, drift 

	matrix unit_roots_d1[5,1] = r(Zt)
	matrix unit_roots_d1[6,1] = r(p)

	dfuller D1.sa_ln_cruisevisitors, constant 

	matrix unit_roots_d1[7,1] = r(Zt)
	matrix unit_roots_d1[8,1] = r(p)

	
	dfuller D1.cruise1_seasAdj
	
	matrix unit_roots_d1[1,2] = r(Zt)
	matrix unit_roots_d1[2,2] = r(p)

	dfuller D1.cruise1_seasAdj, trend
	
	matrix unit_roots_d1[3,2] = r(Zt)
	matrix unit_roots_d1[4,2] = r(p)
		
	dfuller D1.cruise1_seasAdj, drift
	
	matrix unit_roots_d1[5,2] = r(Zt)
	matrix unit_roots_d1[6,2] = r(p)
		
	dfuller D1.cruise1_seasAdj, constant
	
	matrix unit_roots_d1[7,2] = r(Zt)
	matrix unit_roots_d1[8,2] = r(p)
						
	dfuller D1.sa_ln_stayovervisitors
	
	matrix unit_roots_d1[1,3] = r(Zt)
	matrix unit_roots_d1[2,3] = r(p)
	
	dfuller D1.sa_ln_stayovervisitors, trend
	
	matrix unit_roots_d1[3,3] = r(Zt)
	matrix unit_roots_d1[4,3] = r(p)

	dfuller D1.sa_ln_stayovervisitors, drift
	
	matrix unit_roots_d1[5,3] = r(Zt)
	matrix unit_roots_d1[6,3] = r(p)
	
	dfuller D1.sa_ln_stayovervisitors, constant
	
	matrix unit_roots_d1[7,3] = r(Zt)
	matrix unit_roots_d1[8,3] = r(p)
	
	
	dfuller D1.stay1_seasAdj	
		
	matrix unit_roots_d1[1,4] = r(Zt)
	matrix unit_roots_d1[2,4] = r(p)

	dfuller D1.stay1_seasAdj, trend
	
	matrix unit_roots_d1[3,4] = r(Zt)
	matrix unit_roots_d1[4,4] = r(p)

	dfuller D1.stay1_seasAdj, drift

	matrix unit_roots_d1[5,4] = r(Zt)
	matrix unit_roots_d1[6,4] = r(p)

	dfuller D1.stay1_seasAdj, constant
	
	matrix unit_roots_d1[7,4] = r(Zt)
	matrix unit_roots_d1[8,4] = r(p)
  
  estadd matrix unit_roots_d1
	
	esttab matrix(unit_roots_d1, fmt(3 3 3 3)) , cells((cruise_cam(label(Camplet))) (cruise_x13(label(X13))) (stay_cam(label(Camplet2))) (stay_x13(label(X132)))) collabels("Cruise C" "Cruise X13" "StayO C" "StayO X13 ") 
  
  *The null hypothesis of the ADF test is that your variable has a unit root. The test statistic Z(t)=−greater is in absolute value greater than all of the critical values. Hence, you CAN now reject the null hypothesis.
  estout matrix(unit_roots_d1, fmt(3 3 3 3)) using example3.tex, replace cells( cruise_cam cruise_x13 stay_cam stay_x13) collabels("Cruise C" "Cruise X13" "StayO C" "StayO X13 ") mgroups(Cruise StayO) style(tex)
  
  
  
// KPSS test for stationarity

	matrix kpss_roots =J(4,4,0)
	
	matrix rowname kpss_roots = "LN:Lag(0)" "LN:Lag(13)" "D1:Lag(0)" "D1:Lag(13)"
	matrix colnames kpss_roots   = cruise_cam cruise_x13 stay_cam stay_x13 

	kpss sa_ln_cruisevisitors 
	
	matrix kpss_roots[1,1] = r(kpss0)
	matrix kpss_roots[2,1] = r(kpss13)
	
	kpss D1.sa_ln_cruisevisitors 
	
	matrix kpss_roots[3,1] = r(kpss0)
	matrix kpss_roots[4,1] = r(kpss13)
	
	kpss cruise1_seasAdj
	
	matrix kpss_roots[1,2] = r(kpss0)
	matrix kpss_roots[2,2] = r(kpss13)
	
	kpss D1.cruise1_seasAdj
	
	matrix kpss_roots[3,2] = r(kpss0)
	matrix kpss_roots[4,2] = r(kpss13)
	
	kpss sa_ln_stayovervisitors
	
	matrix kpss_roots[1,3] = r(kpss0)
	matrix kpss_roots[2,3] = r(kpss13)
	
	kpss D1.sa_ln_stayovervisitors
	
	matrix kpss_roots[3,3] = r(kpss0)
	matrix kpss_roots[4,3] = r(kpss13)

	kpss stay1_seasAdj
	
	matrix kpss_roots[1,4] = r(kpss0)
	matrix kpss_roots[2,4] = r(kpss13)

	kpss D1.stay1_seasAdj
	
	matrix kpss_roots[3,4] = r(kpss0)
	matrix kpss_roots[4,4] = r(kpss13)

	estadd matrix kpss_roots
	
	 estout matrix(kpss_roots, fmt(3 3 3 3)) using example4.tex, replace cells( cruise_cam cruise_x13 stay_cam stay_x13) collabels("Cruise C" "Cruise X13" "StayO C" "StayO X13 ") mgroups(Cruise StayO) style(tex)
  

		
// 	One way Camplet Cruise vs Stay

tw (tsline D1.sa_ln_cruisevisitors , yaxis(1) legend(label(1 "Cruise")) ) ///
(tsline D1.sa_ln_stayovervisitors  , yaxis(2) legend(label(2 "Stay-Over")) graphregion(color(white)) ///
plotregion( color(white)) xtitle("") xlabel(, noticks format(%tm) labsize(large) grid) saving( ${graphs}cruise_stay_camplet_1_c,replace) ) 
	graph export  ${graphs}cruise_stay_camplet_1_c.png, replace

// 	One way X13 Cruise vs Stay

tw (tsline D1.cruise1_seasAdj	, yaxis(1) legend(label(1 "Cruise")	) 	) ///
(tsline  D1.stay1_seasAdj		, yaxis(2) legend(label(2 "Stay-Over")) 	graphregion(color(white)) ///
plotregion( color(white)) xtitle("") xlabel(, noticks format(%tm) labsize(small) grid)  saving( ${graphs}cruise_stay_x13_1_c,replace) ) 
	graph export  ${graphs}cruise_stay_x13_1_c.png, replace



********************************************************************************
********************************************************************************
*                                                                              *
*                                                                              *
/*	
	Test the two seasonally adjusted visitors series for Granger-causality.
What do you find? Do you think this outcome is plausible? Motivate
your answer.
*/

/*
The first is a Wald test that the coefficients on the two lags of stay1_seasAdj 
that appear in the equation for cruise1_seasAdj are jointly zero.
Then the null hypothesis that stay-over visitors does not Granger-cause cruise 
cannot be rejected so we cannot reject the hypothesis that stay-over visitors 
does not Grangercause  cruise visitors
Because we failed to reject most of these null hypotheses, we might be interested 
in imposing
some constraints on the coefficients
	
*/
*                                                                              *
*                                                                              *
********************************************************************************
********************************************************************************



	var cruise1_seasAdj stay1_seasAdj
	estimates store var_x13
	
	vargranger, estimates(var_x13)
	estimates store granger_x13
	
	var sa_ln_cruisevisitors sa_ln_stayovervisitors
	estimates store var_cam
	
	vargranger, estimates(var_cam)
	estimates store granger
	matrix list  r(gstats)
	*estadd matrix r(gstats)
	
	estadd beta : var_x13 var_cam
	estout var_x13 var_cam, cells(beta) 
	
esttab var_x13 using ${other}var_x13.tex, label title(Regression table\label{var_x13}) replace
esttab var_cam using ${other}var_cam.tex, label title(Regression table\label{var_cam}) replace
esttab granger using ${other}granger.tex, label title(Regression table\label{granger}) replace
esttab using ${other}granger_2.tex, label cells(gstats) title(Regression table\label{granger}) replace


*Long run steady state equilibirums
	gen change_stay= D.stay1_seasAdj/L.stay1_seasAdj
	gen change_cruise= D.cruise1_seasAdj/L.cruise1_seasAdj


	dfuller stay1_seasAdj
	dfuller D.stay1_seasAdj

*Non stationary
	dfuller change_stay

	dfuller cruise1_seasAdj
	dfuller D.cruise1_seasAdj
*Non stationary
	dfuller change_cruise

*Share the same order of integration
	reg stay1_seasAdj cruise1_seasAdj
	predict s, residuals
	tsline s

*The level of deviation of stay from 
*we predict a corection
	dfuller s
	dfuller s, noconstant 

	
	
/* 
*Engle granger criticar values
*Lookup for it in google
*50
*100 3.03 
*200
*Cointegration at least of 90% confidence
*/

reg change_stay change_cruise l.s
	*We expect a negative an significant coeficient
		*ssc install egranger

	egranger stay1_seasAdj cruise1_seasAdj, ecm regress
	egranger sa_ln_cruisevisitors sa_ln_stayovervisitors
*                                                                              *
*                                                                              *		
********************************************************************************
********************************************************************************



	
	
********************************************************************************
********************************************************************************
*                                                                              *
*                                                                              *
// Johnhansen test
	vecrank stay1_seasAdj cruise1_seasAdj
	vecrank sa_ln_cruisevisitors sa_ln_stayovervisitors
*                                                                              *
*                                                                              *
********************************************************************************
********************************************************************************








*******************************************************************************
********************************************************************************
********************************************************************************
*                                                                              *
*                                                                              *
/*
*/
// I follow the steps indicated in here
// http://blog.eviews.com/2020/02/beveridge-nelson-filter.html


fredsearch real gross national product, tags(usa)

import fred A191RL1Q225SBEA GDPC1 GDPPOT, daterange(1990-01-01 2019-12-31) clear


// Format the series
	generate dateq = qofd(daten)
	format %tq dateq
	tsset dateq

// rename it properly
	rename GDPC1   gdp
	rename GDPPOT gdppot

//create gap for comparison and further analysis
	gen cbogap = 100*(gdp-gdppot)/gdppot

// Initial graphs
	tsline gdp
	tsline cbogap

// Variables to use for estimation
	gen loggdp = ln(gdp)*100
	gen d_loggdp = D1.loggdp


//
*Drift: errors that acumulate over time
*assuming a unit root plus drift
//

	arima d_loggdp , ar(2)
		ereturn list

// Paramaters used to calculate cycle and trend
	scalar alpha_hat = e(b)[1,1]
	scalar phi_hat = e(b)[1,2]
	scalar mu_hat = alpha_hat/(1-phi_hat)

// Trend = tau

*gen tau_hat = (gdp+(phi_hat/(1- phi_hat)*D1.gdp))-(phi_hat/(1-phi_hat))*mu_hat
	gen tau_hat = (gdp+(phi_hat/(1- phi_hat)*d_loggdp))-(phi_hat/(1-phi_hat))*mu_hat

* 
*gen trend = loggdp + (d_loggdp - mu_hat)*phi_hat/(1- phi_hat)

// Cycle 
	gen cycle = gdp-tau_hat

*gen cycle2 = gdp+tau_hat
// Cycle alternative calculation
* gen cycle_2 = loggdp -  trend
* gen x =  cycle - cycle_2
* tsline x
* tw (tsline cycle_2 ) (tsline cycle, yaxis(2))

	tw (tsline cycle ) (tsline tau_hat, yaxis(2))
	tw (tsline cycle ) (tsline cbogap, yaxis(2))

// The cylce and the gap
tw (tsline cycle , yaxis(1) lcolor(navy)  lpattern(dash) legend(label(1 "Beveridge-Nelson cycle ")) )  ///
(tsline cbogap , yaxis(2)   ytitle("Cycle", axis(2))  lcolor(gray) graphregion(color(white)) plotregion( color(white)) xtitle("")  xlabel(, noticks format(%tm) labsize(small) grid) legend(label(2 "GDP gap")) saving( ${graphs}camp_vs_x13_1_b,replace) ) 
	graph export  ${graphs}bn_decompostion.png, replace

	
	// The cylce and the trend
tw (tsline cycle , yaxis(1) lcolor(navy)  lpattern(dash) legend(label(1 "Beveridge-Nelson cycle ")) )  ///
(tsline tau_hat , yaxis(2)   ytitle("Trend", axis(2))  lcolor(dkgreen) graphregion(color(white)) plotregion( color(white)) xtitle("")  xlabel(, noticks format(%tm) labsize(small) grid) legend(label(2 "Trend")) saving( ${graphs}camp_vs_x13_1_b,replace) ) 
	graph export  ${graphs}bn_cycletrend.png, replace

	
// Comparing wiht Hodrick-Prescott 

tsfilter hp hp_vars=d_loggdp, smooth(1)

tw (tsline cycle ) (tsline hp_vars, yaxis(2))

tw (tsline cycle , yaxis(1) lcolor(navy)  lpattern(dash) legend(label(1 "Beveridge-Nelson cycle ")) )  ///
(tsline hp_vars , yaxis(2)   ytitle("Hodrick-Prescott ", axis(2))  lcolor(stone ) graphregion(color(white)) plotregion( color(white)) xtitle("")  xlabel(, noticks format(%tm) labsize(small) grid) legend(label(2 "Hodrick-Prescott")) saving( ${graphs}camp_vs_x13_1_b,replace) ) 
	graph export  ${graphs}bn_hp_decom.png, replace

	

