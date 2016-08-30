	

	******************************************************************
	**
	**
	**		NAME:		DOROTHY KRONICK
	**		DATE: 		August 29, 2016
	**		PROJECT: 	PSCI 692
	**
	**		DETAILS: 	This file performs a series of.
	**			        simple tasks using a toy data set,
	**                  for the purposes of demonstration
	**                  in the first lab session of
	**                  PSCI 692. 
	**                  
	**                  You may also want to consult the 
	**                  online resources available from UCLA:
	**                  http://bit.ly/2bMV9zP and you will
	**                  almost certainly use Statalist Archive:
	**                  http://www.stata.com/statalist/archive/.
	**
	**
	**				
	**		Version: 	Stata MP 12
	**
	******************************************************************
	
	
	


		

			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
	


*-------------------------------------------------------------------------------
* preliminaries
*-------------------------------------------------------------------------------



* clear
*------

clear



* set more off
*-------------

set more off



* directory
*----------

cd "/Users/djkronick/Dropbox/Classes/692/Labs/1"

	
	
	


		

			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
	


*-------------------------------------------------------------------------------
* Hello World
*-------------------------------------------------------------------------------



* an essential command: "display"
*-------------------------------

di "Hello World"



* Stata as calculator
*--------------------

di 4 + 5



* another essential command: "help"
*---------------------------------

h di 



* installing a new package 
*-------------------------

ssc install reclink
	
findit renvars
	
	


		


			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
	


*-------------------------------------------------------------------------------
* importing and organizing a toy data set 
*-------------------------------------------------------------------------------



* reading in a comma-delimited data set
*--------------------------------------
insheet using "ToyDataset_Jun30.csv", clear* looking at the data (note: the command window vs. the Do file)
*---------------------------------------------------------------	/* Note how to recognize variable types.
	
	   */
	   br describe list list name



* renaming variables
*-------------------
rename locationofsenioryearinhighschool hslocrename yearatstanford styearrename hairlengthininches hairlength* renaming variables all at once
*-------------------------------renvars flights*, presub(flights plane)* reshaping data: wide to long
*-----------------------------	/* Enter the following in the command line:
	   
	   br name plane* 
	   
	   */
	   reshape long plane, i(name) j(year)* collapsing data*----------------
collapse (sum) plane (first) timestamp-hairlength styear, ///
         by(name)* reorder variables
*------------------
order timestamp name birthday birthplace	
	


		


			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
	


*-------------------------------------------------------------------------------
* creating new variables 
*-------------------------------------------------------------------------------



* creating a numeric variable for height
*---------------------------------------
split height, p(' ft feet)destring height1 height2, replace force ignore(c m i n c h e s ,)gen heightnum = 12 * height1 if height1 <= 7replace heightnum = heightnum + height2replace heightnum = 64 if height == "64 inches"replace heightnum = height1 * 0.3937 if regexm(height, "cm")
drop height1 height2 height3* creating a numeric variable for hair length
*--------------------------------------------destring hairlength, gen(hairnum) force ig(i n c h e s ')* creating a numeric variable for gender
*---------------------------------------
gen male = (gender == "Male")* working with date variables
*----------------------------

	/* Note: "help dates" is your friend here!
	
	   */
	   replace birthday = "8/4/1990" if birthday == "August 4th 1990"replace birthday = "5/14/1990" if birthday == "May 14th 1990"replace birthday = "8/4/1991" if birthday == "8/4/2012"replace birthday = subinstr(birthday, "2991", "1991", .)gen birthdate = date(birthday, "MDY")format birthdate %td
	


		


			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
	


*-------------------------------------------------------------------------------
* some basic descriptives
*-------------------------------------------------------------------------------


* tabs, crosstabs, summary statistics
*------------------------------------tab gendertab male, su(heightnum)tab male, su(hairnum)su heightnum, d	


		




			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
	


*-------------------------------------------------------------------------------
* merging on strings
*-------------------------------------------------------------------------------


* merging
*--------merge 1:1 name using "Names.dta"br name _m 
list name if _m==1list name if _m==2* merging: a better way
*----------------------

	* Let's start over by dropping the names we just brought in:
	   
	   drop if _m == 2
	   
	   drop firstname lastname idu _m 

	   	   gen idm = _nreclink name using "Names.dta", idm(idm) idu(idu) gen(match)sort match 
list name Uname matchdrop match _m


		




			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
	


*-------------------------------------------------------------------------------
* a few simple graphs
*-------------------------------------------------------------------------------



* graphing a function
*--------------------

twoway function y = x^2

twoway function y = x^2, range(0 10)

twoway (function y = x^2, range(0 2)) ///
       (function y = x^(1/2), range(0 2))

twoway function y = ln(x), range(0 5) 




* graph
*------twoway scatter hairnum heightnumtwoway (scatter hairnum heightnum if male==0) ///
       (scatter hairnum heightnum if male==1)* graph formatting
*-----------------
#delimit;twoway (scatter hairnum heightnum if male==0, mcolor(pink))        (scatter hairnum heightnum if male==1, mcolor(midblue)),graphregion(fcolor(white) lcolor(white) margin(zero))plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))xsize(6) ysize(4) title("Height, hair length, and gender",color(black) placement(west) justification(left)) ylabel(,glwidth(thin) labsize(med) glcolor(gs10) angle(horizontal)) ytitle("Hair Length (inches)")xlabel(,labsize(med))xtitle("Height (inches)")legend(pos(8) ring(0) label(1 "Female") label(2 "Male") cols(1) size(vsmall));			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
	
				    	    **  End of do file **



