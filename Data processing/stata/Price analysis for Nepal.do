* Extract Nepal price data from WFP dataset
* N Minot
* February 2023  
* Sources: https://data.humdata.org/dataset/wfp-food-prices-for-nepal
*          https://data.humdata.org/dataset/wfp-food-prices-for-india
* Starting with March 2023 bulletin
*   Geo focus changes from Karnali to western Nepal (3 provinces)
*   Drop Bagmati price analysis
* Starting with April 2023 bulletin
*   Use global macros to simply monthly update of do file
*   Fix mention of "Karnali" in western Nepal results
*   Change format of changes in price from 3.736578383% to 3.7%
* July 2023 fixed bug in calculating % change since last month
* March 2024 removed hardcoding of months so that it requires less revision
*   in January-March of new year 

* Month of the bulletin 
global m_bul    "04"
* Year of the bulletin
global y_bul    2024
* Month of the most recent data (normally m_bul-2) 
global m_data =  2
* Year of most recent data (normally same as y_bul)
global y_data   2024
* Month of month before most recent data
if $m_data!=1 {
	global m_mbef =  $m_data-1
}
if $m_data==1 {
	global m_mbef = 12
}
* Year of month before most recent data
if $m_data!=1 {
	global y_mbef = $y_data
}
if $m_data==1 {
	global y_mbef = $y_data-1
}
* Month of 12 months before most recent data
global m_yrago = $m_data
* Year of 12 months before most recent data
global y_yrago = $y_data-1 

global datapath "C:\Users\NMINOT\Dropbox (IFPRI)\Nepal USAID\Price analysis\Data"
global outpath  "C:\Users\NMINOT\Dropbox (IFPRI)\Nepal USAID\Price analysis\Output"
capture log close
log using "$outpath/Nepal price changes to M$m_data $y_data", text replace

clear
import delimited "$datapath/wfp_food_prices_npl ($y_bul $m_bul)", varnames(1)
drop in 1
destring price, replace
destring usdprice, replace
recode price (0=.)
gen year = substr(date,1,4)
gen month= substr(date,6,2)
destring year, replace
destring month, replace
gen yr_mon = year+(month/100)
format yr_mon %7.2f
gen monnbr = (year-2000)*12+month
sort yr_mon
order monnbr year month yr_mon
* 23 commodities (21 food and 2 fuel)
tab commodity
* 42 markets
tab market 
* 7 provinces (numbered)
tab admin1
* FTF focus is on western Nepal (3 provinces)
gen WestNepal = 0
replace WestNepal = 1 if admin1=="Province No. 5" | admin1=="Province No. 6" | admin1=="Province No. 7"
* 8 markets in Karnali (province 6)
tab admin1 if WestNepal==1
tab market admin1 if WestNepal==1 
* 21 commodities in all three western provinces (all the foods)
tab commodity if admin1=="Province No. 5"
tab commodity if admin1=="Province No. 6"
tab commodity if admin1=="Province No. 7"
lab var market Market
lab var yr_mon "Month"
foreach prod in "Rice (coarse)" "Wheat flour" "Lentils (broken)" "Beans (black)" ///
    "Potatoes (red)" "Tomatoes" "Bananas" "Apples" "Oil (soybean)" "Oil (mustard)" {
	disp ""
	disp "Prices of `prod' over past 12 months in Nepal"
	table market yr_mon, stat(mean price), ///
      if commodity=="`prod'" & ///
         ((year>=$y_yrago & month>=$m_yrago) | year==$y_data) , ///
	  nformat(%4.0fc) totals(yr_mon)
	* Calculate pct change in average price in Nepal
	* compared to previous month and one yr ago
	sum price if commodity=="`prod'" & year==$y_yrago & month==$m_yrago
	local P_yrago   = r(mean)
	sum price if commodity=="`prod'" & year==$y_mbef & month==$m_mbef
	local P_lastmon = r(mean)
	sum price if commodity=="`prod'" & year==$y_data & month==$m_data
	local P_thismon = r(mean)
    * Calculate pct change since last month at national level 
	local mpctch = 100*(`P_thismon'-`P_lastmon')/`P_lastmon'
	* Calculate pct change since 12 months ago at national level
	local ypctch = 100*(`P_thismon'-`P_yrago')/`P_yrago'
	disp ""
	disp "======================================================================================"
	disp "NATIONAL average price of `prod' in $m_data /$y_data was " %4.1f `mpctch' "% higher than previous month"
	disp "NATIONAL average price of `prod' in $m_data /$y_data was " %4.1f `ypctch' "% higher than one year before"
	disp "======================================================================================"
	disp ""
	disp "Prices of `prod' over past 12 months in western Nepal"
	disp "(defined as Lumbini, Karnali, and Sudurpashchim)"
	table market yr_mon, stat(mean price), ///
      if WestNepal==1 & commodity=="`prod'" &  ///
         ((year>=$y_yrago & month>=$m_yrago) | year==$y_data) , ///
	  nformat(%4.0fc) totals(yr_mon)
	* Calculate pct change in average price in western provinces
	* compared to previous month and one yr ago
	sum price if WestNepal==1 & commodity=="`prod'" & year==$y_yrago & month==$m_yrago
	local P_yrago   = r(mean)
	sum price if WestNepal==1 & commodity=="`prod'" & year==$y_mbef & month==$m_mbef
	local P_lastmon = r(mean)
	sum price if WestNepal==1 & commodity=="`prod'" & year==$y_data & month==$m_data
	local P_thismon = r(mean)
    * Calculate pct change since last month for western provinces 
	local mpctch = 100*(`P_thismon'-`P_lastmon')/`P_lastmon'
	* Calculate pct change since 12 months ago for western provinces
	local ypctch = 100*(`P_thismon'-`P_yrago')/`P_yrago'
	disp ""
	disp "======================================================================================"
	disp "WESTERN Nepal price of `prod' in $m_data /$y_data was " %4.1f `mpctch' "% higher than previous month"
	disp "WESTERN Nepal price of `prod' in $m_data /$y_data was " %4.1f `ypctch' "% higher than one year before"
	disp "======================================================================================"
	disp ""
} 

* Seasonality of prices for each commodity 
* This part is based on historical data (2002-2023) and does not change from one month to another
* First five commodities
preserve
keep if commodity=="Rice (coarse)" | commodity=="Wheat flour" | ///
        commodity=="Lentils (broken)" | commodity=="Beans (black)" | ///
		commodity=="Potatoes (red)" 
keep if year>=2002 & year<=$y_yrago
egen avgprice = mean(price), by(year commodity market)
gen sindex = 100*price/avgprice
lab var commodity Commodity
lab var month     Month
disp ""
disp "Seasonal price indices for Nepal"
table month commodity, stat(mean sindex) nformat(%5.1f) totals(commodity)
disp ""
disp "Seasonal price indices for western Nepal"
table month commodity, stat(mean sindex) nformat(%5.1f) totals(commodity), if WestNepal==1
restore
* Second five commodities
preserve
keep if commodity=="Tomatoes" | commodity=="Bananas" | commodity=="Apples" | ///
        commodity=="Oil (soybean)" | commodity=="Oil (mustard)"
keep if year>=2002 & year<=$y_yrago
egen avgprice = mean(price), by(year commodity market)
gen sindex = 100*price/avgprice
lab var commodity Commodity
lab var month     Month
disp ""
disp "Seasonal price indices for Nepal"
table month commodity, stat(mean sindex) nformat(%5.1f) totals(commodity)
disp ""
disp "Seasonal price indices for western Nepal"
table month commodity, stat(mean sindex) nformat(%5.1f) totals(commodity), if WestNepal==1
disp ""
restore
log close

* Food prices in northern India
global datapath "C:\Users\NMINOT\Dropbox (IFPRI)\Nepal USAID\Price analysis\Data"
global outpath  "C:\Users\NMINOT\Dropbox (IFPRI)\Nepal USAID\Price analysis\Output"
capture log close
log using "$outpath/India price changes to M$m_data $y_data", text replace

clear
import delimited "$datapath/wfp_food_prices_ind ($y_bul $m_bul)", varnames(1)
drop in 1
destring price, replace
destring usdprice, replace
recode price (0=.)
gen year = substr(date,1,4)
gen month= substr(date,6,2)
destring year, replace
destring month, replace
gen yr_mon = year+(month/100)
format yr_mon %7.2f
gen monnbr = (year-2000)*12+month
sort yr_mon
keep if admin2=="Lucknow"
disp ""
disp "Prices in Lucknow, India over the last 12 months"
table commodity month, stat(mean price), ///
    if (year>=$y_yrago & month>=$m_yrago) | year==$y_data 
disp ""
log close

