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

if "`c(username)'" == "aexvi" {
    cd "C:\Users\aexvi\Desktop\UNI\BOCCONI-ESS\I anno\II sem\Economics of European Integration\Assignment\Take Home"
}
else if "`c(username)'" == "porro" {
    cd "C:\Users\porro\OneDrive\Desktop\ESS\EEI gp"
}
*else if "`c(username)'" == "INSERISCI TUO NOME" {
*    cd "C:\Users\inserisci tua working directory"
*}
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
* Levinsohn & Petrin (LP) procedure. How do you treat the fact that data come from different countries in different years in the productivity estimation? 
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
* 4) Problem IV (a): Comment on the presence of "extreme" values in both industries. Clear the TFP estimates from these extreme values (1st and 99th percentiles) and save a "cleaned sample". From now on, focus on this sample. Plot the kdensity of the TFP distribution and the kdensity of the logarithmic transformation of TFP in each industry. What do you notice? Are there any differences if you rely on the LP or WRDG procedure? Comment. 



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


* Check how many observations per country-sector cell
tab country nace if TFP_WRDG != .

* Check if the bimodality disappears when you separate by country
tw (kdensity ln_TFP_WRDG if nace==22 & country=="FRA") ///
   (kdensity ln_TFP_WRDG if nace==22 & country=="ITA"), ///
   title("Log-WRDG TFP sector 22 by country")

   
tw (kdensity ln_TFP_WRDG if nace==22 & country=="FRA", ///
    lcolor(navy) lwidth(medthick)) ///
   (kdensity ln_TFP_WRDG if nace==22 & country=="ITA", ///
    lcolor(orange) lwidth(medthick) lp(dash)), ///
   title("Log-WRDG TFP sector 22 by country") ///
   legend(label(1 "France") label(2 "Italy")) ///
   xtitle("log TFP (WRDG)") ytitle("Density")

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

preserve

    keep if nace == 22 & (country == "FRA" | country == "ITA")

    * Build empirical CDF within country x year cells
    sort country year TFP_WRDG
    by country year: cumul TFP_WRDG, generate(cum_TFP_WRDG)

    * Pareto RHS: log(1 - F) — exclude top observation to avoid log(0)
    gen rhs_WRDG = log(1 - cum_TFP_WRDG) if cum_TFP_WRDG < 1

    * France
    qui reg rhs_WRDG ln_TFP_WRDG if country == "FRA"
    outreg2 using "Pareto_FRA_22.tex", replace title("Pareto Shape - France, Sector 22") ctitle("All years")
    qui reg rhs_WRDG ln_TFP_WRDG if country == "FRA" & year == 2001
    outreg2 using "Pareto_FRA_22.tex", append ctitle("2001")
    qui reg rhs_WRDG ln_TFP_WRDG if country == "FRA" & year == 2007
    outreg2 using "Pareto_FRA_22.tex", append ctitle("2007")

    * Italy
    qui reg rhs_WRDG ln_TFP_WRDG if country == "ITA"
    outreg2 using "Pareto_ITA_22.tex", replace title("Pareto Shape - Italy, Sector 22") ctitle("All years")
    qui reg rhs_WRDG ln_TFP_WRDG if country == "ITA" & year == 2001
    outreg2 using "Pareto_ITA_22.tex", append ctitle("2001")
    qui reg rhs_WRDG ln_TFP_WRDG if country == "ITA" & year == 2007
    outreg2 using "Pareto_ITA_22.tex", append ctitle("2007")

    * Display Pareto coefficients
    foreach ctry in FRA ITA {
        foreach yr in 2001 2007 {
            qui reg rhs_WRDG ln_TFP_WRDG if country=="`ctry'" & year==`yr'
            display "Pareto k  |  Country: `ctry'  Year: `yr'  ->  k = " _b[ln_TFP_WRDG] "  (se = " _se[ln_TFP_WRDG] ")"
        }
    }

restore

************************************************************
* Problem IV (d): Combine LP TFP for sectors 22 and 36 and
* estimate the export & FDI premium
************************************************************

* Note: TFP_LP (combining sectors 22 and 36) and ln_TFP_LP were already created during Problem IV (a) and are available in the cleaned sample.
* The outer preserve/restore of IV(c) ensures the full dataset is still here.

*---------------------------------------------------------
* Step 1: Define export status (crucial for correct comparison)
* 0 = domestic only, 1 = exporter only, 2 = exporter + FDI
*---------------------------------------------------------

gen export_status = .
replace export_status = 0 if exporter == 0 & FDI == 0
replace export_status = 1 if exporter == 1 & FDI == 0
replace export_status = 2 if exporter == 1 & FDI == 1

*---------------------------------------------------------
* Step 2: Visualise productivity distributions by status
*---------------------------------------------------------

twoway ///
    (kdensity ln_TFP_LP if export_status == 2, lw(medthick) lcolor(green)) ///
    (kdensity ln_TFP_LP if export_status == 1, lw(medthin)  lcolor(sienna)) ///
    (kdensity ln_TFP_LP if export_status == 0, lw(medthin)  lcolor(blue) lp(dash)), ///
    title("LP TFP distributions by export status") ///
    xtitle("log TFP (LP)") ytitle("Density") ///
    legend(label(1 "Multinationals (Exporters + FDI)") label(2 "Exporters only") label(3 "Domestic only"))

graph export "Q4d_TFP_by_status.png", replace

* Diagnostic: decomposing the compositional bias
* in the export status TFP plot
tab country export_status
tab nace export_status
tab country nace if export_status == 0	
tab country nace if export_status == 1

* country x sector interaction
egen country_nace = group(country nace), label
tabstat ln_TFP_LP, by(country_nace) stat(mean median sd n)
* Revise the claim
tabstat ln_TFP_LP, by(nace) stat(mean median sd n)
*---------------------------------------------------------
* Step 3: Export premium regression
* Compare exporters (1) vs domestic only (0)
* IMPORTANT: exclude multinationals (export_status == 2) from this regression,
* otherwise the exporter group is contaminated by multinationals,
* which are much more productive than pure exporters and would
* inflate the export premium coefficient
*---------------------------------------------------------
xi: reg ln_TFP_LP exporter i.year i.nace ///
    if export_status == 0 | export_status == 1, robust
estimates store export_premium

outreg2 using "table_Q4d_premium.tex", replace ///
    title("Export and FDI Premium") ctitle("Export premium") ///
    addtext(Year FE, YES, Sector FE, YES) ///
    drop(_Iyear* _Inace*)

*---------------------------------------------------------
* Step 4: FDI premium regression
* Compare multinationals (2) vs domestic only (0)
* IMPORTANT: exclude pure exporters (export_status == 1),
* otherwise the domestic baseline is contaminated by exporters
*---------------------------------------------------------
xi: reg ln_TFP_LP FDI i.year i.nace ///
    if export_status == 0 | export_status == 2, robust
estimates store fdi_premium

outreg2 using "table_Q4d_premium.tex", append ///
    ctitle("FDI premium") ///
    addtext(Year FE, YES, Sector FE, YES) ///
    drop(_Iyear* _Inace*)

************************************************************
* Problem V (a): PCM and DLW markup estimation
************************************************************

*---------------------------------------------------------
* Step 1: Recover beta_L from LP estimation for each sector
*---------------------------------------------------------

* Sector 22
xi: levpet ln_real_VA if nace == 22, ///
    free(ln_L i.country i.year) ///
    proxy(ln_real_M) ///
    capital(ln_real_K) ///
    reps(50) level(99) va

scalar beta_L_22 = _b[ln_L]
display "beta_L sector 22 (LP) = " beta_L_22

* Sector 36
xi: levpet ln_real_VA if nace == 36, ///
    free(ln_L i.country i.year) ///
    proxy(ln_real_M) ///
    capital(ln_real_K) ///
    reps(50) level(99) va

scalar beta_L_36 = _b[ln_L]
display "beta_L sector 36 (LP) = " beta_L_36

* In the constant-markup Melitz world, markups should be roughly constant.
* In real data, they are not. A simple accounting proxy is:
* PCM = (sales - wages - materials) / sales
*
* This is not a full structural markup estimate, but it is informative.
*---------------------------------------------------------
* Step 2: PCM markup
* variable_costs = M + W
* In the constant-markup Melitz world, markups should be roughly constant.
* In real data, they are not. A simple accounting proxy is:
* PCM = (sales - wages - materials) / sales
*
* This is not a full structural markup estimate, but it is informative.
*---------------------------------------------------------

gen PCM = (sales - M - W) / sales

sum PCM, d
replace PCM = . if !inrange(PCM, r(p1), r(p99))

gen markup_PCM = 1 / (1 - PCM)

*---------------------------------------------------------
* Step 3: DLW markup
* alpha_L = W / real_sales  (labour share of revenue)
* markup_DLW = beta_L / alpha_L
*---------------------------------------------------------

gen alpha_L = W / real_sales

gen markup_DLW = .
replace markup_DLW = beta_L_22 / alpha_L if nace == 22
replace markup_DLW = beta_L_36 / alpha_L if nace == 36

foreach s in 22 36 {
    sum markup_DLW if nace == `s', d
    replace markup_DLW = . if !inrange(markup_DLW, r(p1), r(p99)) & nace == `s'
}

*---------------------------------------------------------
* Step 4: Plot both distributions
*---------------------------------------------------------

* Then plot both markups together
twoway ///
    (kdensity markup_DLW, lcolor(green) lwidth(medthick)) ///
    (kdensity markup_PCM, lcolor(sienna) lwidth(medthick)), ///
    title("DLW markup vs PCM") ///
    xtitle("Markup") ytitle("Density") ///
    legend(label(1 "DLW markup") label(2 "PCM markup"))

graph export "Q5a_markup_DLW_vs_PCM.png", replace
* Markups differ across firms, so firms do not all have the same degree
* of market power. Differences across firms therefore reflect not only
* productivity differences, but also differences in the ability to charge
* prices above marginal cost.
*
* If the most productive firms also set higher markups, then the cost
* savings generated by higher productivity are not fully passed on to
* consumers through lower prices. Instead, part of these gains is kept
* by firms as higher profits. This means that the standard trade-model
* prediction of full pass-through from productivity gains to lower prices
* may not hold.
tabstat markup_PCM markup_DLW, stat(mean median p25 p75 sd) columns(statistics)
* Gap between the two markups by sector
gen markup_gap = markup_PCM - markup_DLW

tabstat markup_gap, by(nace) stat(mean median sd n)

* Also check capital intensity by sector as background
tabstat real_K, by(nace) stat(mean median)
tabstat alpha_L, by(nace) stat(mean median)
tabstat alpha_L W real_M, by(nace) stat(mean)
gen K_intensity = real_K / L

tabstat K_intensity, by(nace) stat(mean median)
gen total_costs = W + real_M + real_K
gen alpha_K_share = real_K / total_costs
gen alpha_M_share = real_M / total_costs
gen alpha_W_share = W / total_costs

tabstat alpha_K_share alpha_M_share alpha_W_share, by(nace) stat(mean)

* Is the bimodality in DLW driven by sectors?
twoway ///
    (kdensity markup_DLW if nace == 22, lcolor(sienna)) ///
    (kdensity markup_DLW if nace == 36, lcolor(black)), ///
    title("DLW markup by sector") ///
    legend(label(1 "Sector 22") label(2 "Sector 36"))

* Same for PCM
twoway ///
    (kdensity markup_PCM if nace == 22, lcolor(sienna)) ///
    (kdensity markup_PCM if nace == 36, lcolor(black)), ///
    title("PCM markup by sector") ///
    legend(label(1 "Sector 22") label(2 "Sector 36"))
	
* Gap by sector — already done, confirms sector 22 drives the bias
tabstat markup_gap, by(nace) stat(mean median)

* Gap by country
tabstat markup_gap, by(country) stat(mean median)

* Gap by year — is the bias growing over time?
tabstat markup_gap, by(year) stat(mean median)
tabstat markup_gap, by(country_nace) stat(mean median)
tabstat markup_DLW markup_PCM alpha_L, by(country_nace) stat(mean)
************************************************************
* Problem V (b): Exporters, DLW markup, and productivity
************************************************************

*---------------------------------------------------------
* 1) DLW markup on exporter dummy
*---------------------------------------------------------
reg markup_DLW exporter i.year i.nace, robust
estimates store q5b_1

reg markup_DLW exporter ln_L i.year i.nace, robust
estimates store q5b_2

*---------------------------------------------------------
* 2) Wooldridge productivity on DLW markup
*---------------------------------------------------------
reg ln_TFP_WRDG markup_DLW i.year i.nace, robust
estimates store q5b_3

*---------------------------------------------------------
* 3) Export regression table
*---------------------------------------------------------
reg markup_DLW exporter i.year i.nace, robust
outreg2 using "table_problem5b.tex", replace tex ///
    ctitle("Markup: no size") ///
    addtext(Year FE, YES, Sector FE, YES)

reg markup_DLW exporter ln_L i.year i.nace, robust
outreg2 using "table_problem5b.tex", append tex ///
    ctitle("Markup: + size") ///
    addtext(Year FE, YES, Sector FE, YES)

reg ln_TFP_WRDG markup_DLW i.year i.nace, robust
outreg2 using "table_problem5b.tex", append tex ///
    ctitle("TFP on markup") ///
    addtext(Year FE, YES, Sector FE, YES)

	
**********************************************************************************************
*COMMENTI:
*TFP_WRDG_22: TFP calcolata con WRDG SOLO per settore 22 - quindi settore 36 avrà missing values
*TFP_WRDG: TFP calcolata con WRDG (è la semplice unione di TFP_WRDG_22 e TFP_WRDG_36) - missing values qua quando missing sia per 22 che 36
*ln_TFP_WRDG: logaritmo di TFP_WRDG
*Uguale come sopra per LP
**********************************************************************************************



