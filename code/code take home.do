*============================================================================
*
*                   Economics of European Integration
*                          Final Report 2025/2026
*
*   Course:        20269 Economics of European Integration
*   Institution:   Bocconi University
*   Authors:       Adisha Tasnim, Agnese Porro, Alex Vigna Lobbia, Andrea Boscolo, 
*                  Giorgio Ucropina
*   Date:          March 2026
*
*   Description:   This is the main analysis file for the Economics of
*                  European Integration final report. It contains analysis
*                  covering 7 problems across 2 parts:
*                  - Part 1: Production function estimation (OLS, WRDG, LP)
*                  - Part 2: China shock analysis, IV regressions, ESS survey
*============================================================================

************************************************************
* Set-up
************************************************************
/* For commands */

*ssc install outreg2, replace
*ssc install estout, replace
*search levpet
*(and install ALL the packages)
*search prodest
*(and install ALL the packages)


/* For charts and Latex */

*ssc install grstyle, replace
*ssc install coefplot, replace
*graph set window fontface "Lato"
*grstyle init
*grstyle set plain, horizontal
*/








************************************************************
* 1) PART I
************************************************************

cd "C:\Users\aexvi\Desktop\UNI\BOCCONI-ESS\I anno\II sem\Economics of European Integration\Assignment\Take Home"

use "EEI_TH_P1_2026.dta", clear
************************************************************
* Variables for production function estimation (Part I: Problem II (a),
* Problem II (b) and Problem III(a) and so on...)
************************************************************

gen ln_real_VA = .
replace ln_real_VA = ln(real_VA) if real_VA > 0

gen ln_real_sales = .
replace ln_real_sales = ln(real_sales) if real_sales > 0

gen ln_real_K = .
replace ln_real_K = ln(real_K) if real_K > 0

gen ln_real_M = .
replace ln_real_M = ln(real_M) if real_M > 0

gen ln_L = .
replace ln_L = ln(L) if L > 0

************************************************************
* 1) Problem I (a): Focus on both countries. Starting from balance-sheet data, 
* provide some descriptive statistics (e.g. n. of firms, average capital, 
* revenues, number of employees, value added, exporters, FDI) in 2007 comparing 
* firms in sector 22 (Publishing, printing and reproduction of recorded media) 
* and firms in sector 36 (Manufacture of furniture) for the two countries. 
************************************************************

preserve
    keep if year == 2007
    keep if country == "FRA" | country == "ITA"
    keep if nace == 22 | nace == 36

    gen country_sector = ""
    replace country_sector = "FRA22" if country=="FRA" & nace==22
    replace country_sector = "FRA36" if country=="FRA" & nace==36
    replace country_sector = "ITA22" if country=="ITA" & nace==22
    replace country_sector = "ITA36" if country=="ITA" & nace==36

    * Mean table
    dtable real_K real_sales L real_VA exporter FDI, by(country_sector) ///
        continuous(real_K real_sales L real_VA exporter FDI, statistics(mean)) ///
        nformat(%9.2f mean) ///
        title(Descriptive statistics: means, 2007) ///
        export("table_problem1_mean.tex", replace)

    * Standard deviation table
    dtable real_K real_sales L real_VA exporter FDI, by(country_sector) ///
        continuous(real_K real_sales L real_VA exporter FDI, statistics(sd)) ///
        nformat(%9.2f sd) ///
        title(Descriptive statistics: standard deviations, 2007) ///
        export("table_problem1_sd.tex", replace)

    * Median table
    dtable real_K real_sales L real_VA exporter FDI, by(country_sector) ///
        continuous(real_K real_sales L real_VA exporter FDI, statistics(p50)) ///
        nformat(%9.2f p50) ///
        title(Descriptive statistics: medians, 2007) ///
        export("table_problem1_median.tex", replace)

restore

************************************************************
* 2) Problem II (a): Consider now both countries together.
* Estimate for the two industries available in NACE Rev. 1.1
* 2-digit format the production function coefficients, by
* using standard OLS, the Wooldridge (WRDG) and the
* Levinsohn & Petrin (LP) procedure. How do you treat the fact that data come from different countries in different years in the produc�vity es�ma�on? 
************************************************************

preserve
    keep if nace == 22 | nace == 36

    * Panel declaration
    xtset mark year

    ********************************************************
    * Sector 22
    ********************************************************

    * OLS
    xi: reg ln_real_VA ln_L ln_real_K i.country i.year if nace == 22
    estimates store ols_22

	
    * WRDG
    xi: prodest ln_real_VA if nace == 22, ///
        met(wrdg) ///
        free(ln_L) ///
        proxy(ln_real_M) ///
        state(ln_real_K) ///
        control(i.country) ///
        va
    estimates store wrdg_22

    * LP
    xi: levpet ln_real_VA if nace == 22, ///
        free(ln_L i.country i.year) ///
        proxy(ln_real_M) ///
        capital(ln_real_K) ///
        reps(50) level(99) va
    estimates store lp_22

    ********************************************************
    * Sector 36
    ********************************************************

    * OLS
    xi: reg ln_real_VA ln_L ln_real_K i.country i.year if nace == 36
    estimates store ols_36

    * WRDG
    xi: prodest ln_real_VA if nace == 36, ///
        met(wrdg) ///
        free(ln_L) ///
        proxy(ln_real_M) ///
        state(ln_real_K) ///
        control(i.country) ///
        va
    estimates store wrdg_36

    * LP
    xi: levpet ln_real_VA if nace == 36, ///
        free(ln_L i.country i.year) ///
        proxy(ln_real_M) ///
        capital(ln_real_K) ///
        reps(50) level(99) va
    estimates store lp_36

restore

************************************************************
* 2) Problem II (b): Present a Table (like the one below), where you compare the  coefficients obtained in the estimation 
* outputs, indica�ng their significance levels (*, ** or *** for 10, 5 and 1 per cent). 
* Is there any bias of the labour coefficients? What is the reason for that? 
************************************************************
label variable ln_L "log(Labour)"
label variable ln_real_K "log(Capital)"

esttab ols_22 wrdg_22 lp_22 ols_36 wrdg_36 lp_36 ///
    using "table_problem2b.tex", replace ///
    b(%9.3f) se(%9.4f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label ///
    mtitles("OLS" "WRDG" "LP" "OLS" "WRDG" "LP") ///
    mgroups("Sector 22" "Sector 36", pattern(1 0 0 1 0 0) span ///
        prefix(\multicolumn{@span}{c}{) suffix(})) ///
    stats(N, fmt(%9.0f) labels("Observations")) ///
    title("Production function estimates by sector and method") ///
    booktabs


	
	
	
	
************************************************************
* 4) Problem IV (a): Comment on the presence of "extreme" values in both industries. Clear the TFP estimates from these extreme values (1st and 99th percentiles) and save a "cleaned sample". From now on, focus on this sample. Plot the kdensity of the TFP distribution and the kdensity of the logarithmic transformation of TFP in each industry. What do you notice? Are there any differences if you rely on the LP or WRDG procedure? Comment. */



*************************************************
*TFP DEFINITION
*************************************************

*(i) OLS

* sector 22 
xi: reg ln_real_VA ln_L ln_real_K i.country i.year if nace==22
predict ln_TFP_OLS_22, residuals 

gen TFP_OLS_22= exp(ln_TFP_OLS_22)

* sector 36 
xi: reg ln_real_VA ln_L ln_real_K i.country i.year if nace==36
predict ln_TFP_OLS_36, residuals 

gen TFP_OLS_36= exp(ln_TFP_OLS_36)



* (ii) Wooldridge (WRDG)
* Sector 22
xi: prodest ln_real_VA if nace == 22, met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) control(i.country) va
predict ln_TFP_WRDG_22, resid

gen TFP_WRDG_22 = exp(ln_TFP_WRDG_22)


* Sector 36
xi: prodest ln_real_VA if nace == 36, met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) control(i.country) va
predict ln_TFP_WRDG_36, resid

gen TFP_WRDG_36 = exp(ln_TFP_WRDG_36)


* (iii) Levinsohn & Petrin (LP):


* Sector 22
xi: levpet ln_real_VA if nace == 22, ///
    free(ln_L i.country i.year) ///
    proxy(ln_real_M) ///
    capital(ln_real_K) ///
    reps(20) level(99) va

predict TFP_LP_22, omega


* Sector 36
xi: levpet ln_real_VA if nace == 36, ///
    free(ln_L i.country i.year) ///
    proxy(ln_real_M) ///
    capital(ln_real_K) ///
    reps(20) level(99) va

predict TFP_LP_36, omega




*************************************************
*** Clearing of extreme values
*************************************************

** WRDG estimates

foreach s in 22 36 {
sum TFP_WRDG_`s' if nace==`s', d
replace TFP_WRDG_`s'=. if !inrange(TFP_WRDG_`s', r(p1),r(p99)) & nace==`s'
sum TFP_WRDG_`s' if nace==`s', d
}

gen TFP_WRDG = .
replace TFP_WRDG=TFP_WRDG_22 if nace==22
replace TFP_WRDG=TFP_WRDG_36 if nace==36
gen ln_TFP_WRDG=ln(TFP_WRDG)

** LP estimates

foreach s in 22 36 {
sum TFP_LP_`s' if nace==`s', d
replace TFP_LP_`s'=. if !inrange(TFP_LP_`s', r(p1),r(p99)) & nace==`s'
sum TFP_LP_`s' if nace==`s', d
}

gen TFP_LP = .
replace TFP_LP=TFP_LP_22 if nace==22
replace TFP_LP=TFP_LP_36 if nace==36
gen ln_TFP_LP=ln(TFP_LP)

drop _Icountry_2 _Iyear_2002 _Iyear_2003 _Iyear_2004 _Iyear_2005 _Iyear_2006 _Iyear_2007 _Iyear_2008 _Iyear_2009



*************************************************
*graph:
*************************************************

tw (kdensity TFP_WRDG if nace==22, lcolor(sienna)) || (kdensity TFP_WRDG if nace==36, lcolor(black)), title("TFP Densities with WRDG") legend(label(1 "sec22") label(2 "sec36"))


tw (kdensity ln_TFP_WRDG if nace==22, lcolor(sienna)) || (kdensity ln_TFP_WRDG if nace==36, lcolor(black)), title("Log-TFP Densities with WRDG") legend(label(1 "sec22") label(2 "sec36"))



tw (kdensity TFP_LP if nace==22, lcolor(sienna)) || (kdensity TFP_LP if nace==36, lcolor(black)), title("TFP Densities with LP") legend(label(1 "sec22") label(2 "sec36"))


tw (kdensity ln_TFP_LP if nace==22, lcolor(sienna)) || (kdensity ln_TFP_LP if nace==36, lcolor(black)), title("Log-TFP Densities with LP") legend(label(1 "sec22") label(2 "sec36"))



save "EEI_TH_P1_2026_cleaned_sample.dta", replace

************************************************************
* 4) Problem IV (b): Focus now on the (Wooldridge) TFP distributions of industry 22 in Italy and France. Do you find changes in these two TFP distributions in 2001 vs 2007? Look at changes in skewness in the same time window (again, focus on industry 22 only in these two countries). What happens?
************************************************************

use "EEI_TH_P1_2026_cleaned_sample.dta", clear


preserve
    keep if nace == 22 & (country == "FRA" | country == "ITA")

    * Density France: 2001 vs 2007 
    tw (kdensity TFP_WRDG if country=="FRA" & year==2001, lcolor(navy) lwidth(medthick)) || (kdensity TFP_WRDG if country=="FRA" & year==2007, lcolor(orange) lwidth(medthick) lp(dash)), title("WRDG TFP - Sector 22, France") xtitle("TFP (WRDG)") ytitle("Density") legend(label(1 "2001") label(2 "2007"))
    graph save   "Q4b_WRDG_FRA.gph", replace
    graph export "Q4b_WRDG_FRA.png", replace

    * Density Italy: 2001 vs 2007 
    tw (kdensity TFP_WRDG if country=="ITA" & year==2001, lcolor(navy) lwidth(medthick)) || (kdensity TFP_WRDG if country=="ITA" & year==2007, lcolor(orange) lwidth(medthick) lp(dash)), title("WRDG TFP - Sector 22, Italy") xtitle("TFP (WRDG)") ytitle("Density") legend(label(1 "2001") label(2 "2007"))
    graph save   "Q4b_WRDG_ITA.gph", replace
    graph export "Q4b_WRDG_ITA.png", replace

    * Both
    graph combine "Q4b_WRDG_FRA.gph" "Q4b_WRDG_ITA.gph", title("WRDG TFP Distributions - Sector 22 (2001 vs 2007)")
    graph export "Q4b_combined.png", replace

    *  Skewness statistics
    foreach ctry in FRA ITA {
        foreach yr in 2001 2007 {
            quietly sum TFP_WRDG if country=="`ctry'" & year==`yr', detail
            display "Country: `ctry'  Year: `yr'"
            display "  N        = " r(N)
            display "  Mean     = " r(mean)
            display "  Median   = " r(p50)
            display "  Std dev  = " r(sd)
            display "  Skewness = " r(skewness)
            display "  Kurtosis = " r(kurtosis)
        }
    }

restore

********************************************************************************
* Problem IV (c) Do you find the shifts to be homogenous throughout the distribution? Once you have defined a specific parametrical distribution for the TFP, is there a way through which you can statistically measure the changes in the TFP distribution in the industry over time (2001 vs 2007)?
********************************************************************************

keep if nace == 22 & (country == "FRA" | country == "ITA")

* Build empirical CDF within country x year cells
sort country year TFP_WRDG
by country year: cumul TFP_WRDG, generate(cum_TFP_WRDG)

* Pareto RHS: log(1 - F) — exclude top observation to avoid log(0)
gen rhs_WRDG = log(1 - cum_TFP_WRDG) if cum_TFP_WRDG < 1

* France
preserve
    keep if country == "FRA"
    qui reg rhs_WRDG ln_TFP_WRDG
    outreg2 using "Pareto_FRA_22.tex", replace title("Pareto Shape - France, Sector 22") ctitle("All years")
    qui reg rhs_WRDG ln_TFP_WRDG if year == 2001
    outreg2 using "Pareto_FRA_22.tex", append ctitle("2001")
    qui reg rhs_WRDG ln_TFP_WRDG if year == 2007
    outreg2 using "Pareto_FRA_22.tex", append ctitle("2007")
restore

* Italy
preserve
    keep if country == "ITA"
    qui reg rhs_WRDG ln_TFP_WRDG
    outreg2 using "Pareto_ITA_22.tex", replace title("Pareto Shape - Italy, Sector 22") ctitle("All years")
    qui reg rhs_WRDG ln_TFP_WRDG if year == 2001
    outreg2 using "Pareto_ITA_22.tex", append ctitle("2001")
    qui reg rhs_WRDG ln_TFP_WRDG if year == 2007
    outreg2 using "Pareto_ITA_22.tex", append ctitle("2007")
restore

* Display Pareto coefficients in log
foreach ctry in FRA ITA {
    foreach yr in 2001 2007 {
        qui reg rhs_WRDG ln_TFP_WRDG if country=="`ctry'" & year==`yr'
        display "Pareto k  |  Country: `ctry'  Year: `yr'  ->  k = " _b[ln_TFP_WRDG] "  (se = " _se[ln_TFP_WRDG] ")"
    }
}



**********************************************************************************************
*COMMENTI:
*DA ORA IN POI IL DATASET DA UTILIZZARE E' "EEI_TH_P1_2026_cleaned_sample.dta"
*TFP_WRDG_22: TFP calcolata con WRDG SOLO per settore 22 - quindi settore 36 avrà missing values
*TFP_WRDG: TFP calcolata con WRDG (è la semplice unione di TFP_WRDG_22 e TFP_WRDG_36) - missing values qua quando missing sia per 22 che 36
*ln_TFP_WRDG: logaritmo di TFP_WRDG
*Uguale come sopra per LP
**********************************************************************************************



