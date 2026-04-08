# 20269 EEI Take Home
# 20269 Economics of European Integration — Take Home 2025/26

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Overview

This repository contains the complete analysis for the Economics of European Integration (20269) Take Home assignment at Bocconi University (Academic Year 2025/26). The project covers production function estimation and markup analysis for French and Italian firms, followed by an investigation of the China import shock on European regions and its political economy implications for France.

## Collaborators

- **Adisha Tasnim**
- **Agnese Porro** ([agneseporro](https://github.com/agneseporro))
- **Alex Vigna Lobbia**
- **Andrea Boscolo**
- **Giorgio Ucropina**

## Repository Structure

```
20269-EEI-take_home/
├── code/               # Stata analysis code
├── data/               # Input datasets
├── output/
│   ├── figures/        # Maps, density plots, regression plots
│   └── tables/         # Regression and descriptive statistics tables
├── docs/               # Assignment text and reference papers
├── report/             # Final submitted report
└── README.md
```

## Project Contents

### Part I: Firm-Level Analysis (Problems 1–5)

Data: French and Italian firms in two NACE rev. 1.1 sectors over 2001–2009:
- **Sector 22** — Publishing, printing and reproduction of recorded media
- **Sector 36** — Manufacture of furniture

**Problem 1:** Descriptive statistics comparing firms across sectors and countries in 2007 (capital, revenues, employees, value added, exporter and FDI shares).

**Problem 2:** Production function estimation using three methods:
- OLS (Ordinary Least Squares)
- Wooldridge (WRDG) via `prodest`
- Levinsohn-Petrin (LP) via `levpet`

**Problem 3:** Theoretical discussion on estimating production functions using revenues vs. value added under the Cobb-Douglas framework.

**Problem 4:** TFP distribution analysis — outlier cleaning, kernel density plots, distributional shifts (2001 vs. 2007), and export & FDI premium estimation.

**Problem 5:** Markup estimation using the PMC and DLW approaches; regression of markups on exporter status, firm size, and TFP.

---

### Part II: China Shock and Political Economy (Problems 6–7)

**Problem 6:** Construction of the China import shock at the NUTS-2 regional level (Italy, France, Spain) following Colantone & Stanig (AJPS, 2018), including:
- Regional import exposure (1988–2007)
- Instrumental variable using US-China trade flows
- Maps of regional China shock and manufacturing employment shares

**Problem 7:** Political economy implications for **French regions**, using European Social Survey (ESS) Round 8:
- Impact of China shock on attitudes toward social benefits and equality
- Party voting behaviour in the 2012 French national election
- Weighted regressions with demographic controls

---

## How to Run

### Prerequisites

**Software:** Stata 17 or higher

**Required Stata packages:**
```stata
ssc install prodest,  replace
ssc install levpet,   replace
ssc install outreg2,  replace
ssc install estout,   replace
ssc install spmap,    replace
ssc install shp2dta,  replace
ssc install ivreg2,   replace
```

### Execution

1. Clone the repository:
```bash
git clone https://github.com/agneseporro/20269-EEI-take_home.git
cd 20269-EEI-take_home
```

2. Open Stata and run the main do-file:
```stata
do code/main_analysis.do
```

3. Output will be saved to `output/figures/` and `output/tables/`.

> **Note:** Edit the global path variables at the top of `main_analysis.do` to match your local directory before running.

---

## Data Sources

| Dataset | Source |
|---|---|
| `EEI_TH_P1_2026.dta` | Course Blackboard (firm-level balance sheet data) |
| `EEI_TH_P6_2026.dta` | Course Blackboard (regional TFP and wages, 2000–2017) |
| `Employment_Shares_Take_Home.dta` | Course Blackboard / Eurostat |
| `Imports_China_Take_Home.dta` | Course Blackboard / UN Comtrade |
| `Imports_US_China_Take_Home.dta` | Course Blackboard / UN Comtrade |
| ESS Round 8 (2016) | [European Social Survey](https://www.europeansocialsurvey.org/) |
| NUTS-2 shapefiles | [Eurostat GISCO](https://ec.europa.eu/eurostat/web/gisco) |

---

## Key References

- Wooldridge, J.M. (2009). On estimating firm-level production functions using proxy variables to control for unobservables. *Economics Letters*, 104(3).
- Levinsohn, J. & Petrin, A. (2003). Estimating production functions using inputs to control for unobservables. *Review of Economic Studies*, 70(2).
- De Loecker, J. & Warzynski, F. (2012). Markups and firm-level export status. *American Economic Review*, 102(6).
- Colantone, I. & Stanig, P. (2018). The trade origins of economic nationalism. *American Journal of Political Science*, 62(4).
- Melitz, M.J. (2003). The impact of trade on intra-industry reallocations and aggregate industry productivity. *Econometrica*, 71(6).

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgments

Course instructors and TAs for Economics of European Integration (20269) at Bocconi University.
