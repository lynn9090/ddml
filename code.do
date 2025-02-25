clear
use "C:\Users\LENOVO\Desktop\lin\data.dta"
*************************************************************************************
#delimit ;
global controls "age age_sq edu farmtime health party labor plant_demons farmland_area consolidation certification income agtraing emtraing insurance loan water coll_economic distance capabilities drought frost credit policy technology_support" ;
#delimit cr
*************************************************************************************

//4.1 Benchmark regression results
*(1)~(2) OLS
reg resilience digital
reg resilience digital $controls
*(3)~(7) use Python.
*(8)ensemble
global Y resilience
global D digital
global X $controls
set seed 42
ddml init partial, kfolds(5) reps(1) //rep(2)
ddml E[Y|X]: pystacked $Y $X || method(ols) || method(lassocv) || method(ridgecv) || method(rf)  || method(nnet)  , type(reg)
ddml E[D|X]: pystacked $D $X || method(ols) || method(lassocv) || method(ridgecv) || method(rf)  || method(nnet)  , type(reg)
ddml crossfit
ddml estimate, robust

*************************************************************************************
//4.2 Robustness test
//4.2.1 Substituting key variables
global Y resilience
global C digital
global X $controls
set seed 42
ddml init partial, kfolds(5) reps(1)
ddml E[Y|X]: reg $Y $X
ddml E[D|X]: reg $C $X
ddml crossfit
ddml estimate, robust
//4.2.2 Redesigning the DDML model
*interactive model
ddml init interactive, kfolds(5) reps(1)
ddml E[Y|X,D]: pystacked $Y $X, type(reg) method(rf)
ddml E[D|X]: pystacked $D $X, type(reg) method(rf)
ddml crossfit
ddml estimate, trim(0.35) robust
//4.2.3 addressing endogenous issue
*partial linear IV
gen byte touse = !missing($D)
bysort villege: egen totMPf1 = total($D) if touse==1
sum totMPf1
by villege: egen cMPf1 = count($D) if touse==1
generate avgMPf1 = (totMPf1 - $D) / (cMPf1 - 1)
global Z avgMPf1
ddml init iv, kfolds(5) reps(1)
ddml E[Y|X]: pystacked $Y $X, type(reg) method(rf)
ddml E[Z|X]: pystacked $Z $X, type(reg) method(rf)
ddml E[D|X]: pystacked $D $X, type(reg) method(rf)
ddml crossfit
ddml estimate, robust
*sensitivity approach - ols
sensemakr resilience digital $controls , ///
 treat(digital) gbenchmark(labor farmland_area income insurance credit policy) gname(all) contourplot
 treat(digital) gbenchmark(labor farmland_area income insurance credit policy) gname(all) tcontourplot
//4.2.4 Sample re-processing
*(1)Trimmed treatment-1%/5%
winsor2 resilience digital $controls, replace cuts(1 99) trim
winsor2 resilience digital $controls, replace cuts(5 95) trim
*(2)Sample reselection
*drop if county==2,4,5,6,7,8,9,13,16,18,19
global Y resilience
global D digital
global X $controls
set seed 42
ddml init partial, kfolds(5) reps(1)
ddml E[Y|X]: pystacked $Y $X, type(reg) method(rf)
ddml E[D|X]: pystacked $D $X, type(reg) method(rf)
ddml crossfit
ddml estimate, robust
*************************************************************************************
*************************************************************************************
//5.1 Mechanism analysis
bootstrap r(ind_eff) r(dir_eff), reps(5000) : sgmediation resilience , mv( social_captical ) iv( digital ) 
bootstrap r(ind_eff) r(dir_eff), reps(5000) : sgmediation resilience , mv( information_channel ) iv( digital ) 
bootstrap r(ind_eff) r(dir_eff), reps(5000) : sgmediation resilience , mv( public_service_equal ) iv( digital ) 
*************************************************************************************
//5.2 Heterogeneity analysis
keep if inlist(income_class,1) 
keep if inlist(income_class,0)
keep if inlist(education_class,1)  
keep if inlist(education_class,2) 
keep if inlist(education_class,3)  
keep if inlist(publicservice_class,1) 
keep if inlist(publicservice_class,0) 
*ddml
global Y resilience
global D digital
global X $controls
set seed 42
ddml init partial, kfolds(5)  reps(1)
ddml E[Y|X]: pystacked $Y $X, type(reg) method(rf)
ddml E[D|X]: pystacked $D $X, type(reg) method(rf)
ddml crossfit
ddml estimate, robust
*************************************************************************************
*5.3 Mechanism analysis under Heterogeneity analysis
keep if inlist(income_class,1) 
keep if inlist(income_class,0) 
keep if inlist(education_class,1) 
keep if inlist(education_class,2) 
keep if inlist(education_class,3)  
keep if inlist(publicservice_class,1) 
keep if inlist(publicservice_class,0) 
*mechanism
bootstrap r(ind_eff) r(dir_eff), reps(5000) : sgmediation resilience , mv( social_captical ) iv( digital ) 
bootstrap r(ind_eff) r(dir_eff), reps(5000) : sgmediation resilience , mv( information_channel ) iv( digital ) 
bootstrap r(ind_eff) r(dir_eff), reps(5000) : sgmediation resilience , mv( public_service_equal ) iv( digital ) 
*************************************************************************************
*Table D1
*************************************************************************************
*MSE-out-of-sample
*OLS
set seed 42
gen sample_split = runiform()
gen training = sample_split < 0.8
reg resilience digital $controls if training
predict yhat if !training
gen residuals = resilience - yhat if !training
gen residuals_sq = residuals^2
summarize residuals_sq, meanonly
display "The MSE for the test set is: " r(mean)
*DDML  method(ols) | method(rf) | method(nnet) | method(gradboost) | method(ridgecv) | method(lassocv)
set seed 42
gen training = runiform() < 0.8
ddml init partial, kfolds(5) reps(1) //rep(2)
ddml E[Y|X]: pystacked $Y $X if training, type(reg) method(lassocv)
ddml E[D|X]: pystacked $D $X if training, type(reg) method(lassocv) 
ddml crossfit
ddml estimate, robust if !training
predict yhat if !training
gen mse = (Y - yhat)^2 if !training
sum mse
