
* Read in data: 
import delimited using "/Users/sw3947/Desktop/FALL2024/Research Method B/assignment/2/vaping-ban-panel.csv",varname(1) clear

label variable vapingban "Anti-Vaping Law x Post"

gen year_2021=year>=2021
bysort stateid: egen treat_state=max(vapingban) //here I create a dummy variable indicating whether a state is treated state. 

estout clear

* Evaulating parallel pe-trend requirement using a regression
ppmlhdfe lunghospitalizations i.treat_state##i.year if year<2021, a(stateid)
eststo r1

**# DiD Plot

ppmlhdfe lunghospitalizations i.year##ib0.treat_state, a(stateid) d /// i use poisson because the DV is a count variable

margins treat_state#year


marginsplot, noci xdimension(year) legend(order(1 "Control Group" 2 "Treatment Group")) title("Difference-in-Differences") xlabel(,angle(45)) ytitle(Estimated Lung Hospitalizations)
graph export "/Users/sw3947/Desktop/FALL2024/Research Method B/assignment/2/diff_in_diff_plot.png", as(png) name("Graph")
**# treatment effect



ppmlhdfe lunghospitalizations vapingban, a(stateid year) 

eststo r2


**********************************
estadd local fe " ",replace: r1 r2 
estadd local yfe "Yes", replace: r1 r2  
estadd local sfe "Yes", replace: r1 r2  


esttab r1 r2  using"/Users/sw3947/Desktop/FALL2024/Research Method B/assignment/2/table.tex", replace label se  wrap width(\hsize)title("\label{tab:assignment2} The Effect of Anti-vaping Law on Lung Hospitalizations") mgroups("Poission:Lung Hospitalizations", pattern(1 0 0 ) prefix(\multicolumn{@span}{c}{) suffix(}) span ) nomtitles keep(vapingban 1.treat_state#*.year) order(vapingban 1.treat_state#*.year )   scalar("fe Fixed Effects:" "yfe Year" "sfe State")

