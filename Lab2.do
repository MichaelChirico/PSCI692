	

	******************************************************************
	**
	**
	**		NAME:		DOROTHY KRONICK
	**		DATE: 		August 29, 2016
	**		PROJECT: 	PSCI 692
	**
	**		DETAILS: 	Pseudocode for working with 
	**                  Current Population Survey data.
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
* download and read in data from the 2010 CPS March supplement
*-------------------------------------------------------------------------------

	
** (1) Download the IPUMS sample of the 2010 CPS March supplement, 
**     including all variables in your extract request.** (2) Read the file into Stata using the code provided by IPUMS.** (3) Save the data set as a Stata (.dta) file, 
**     and begin a new Do file by using this .dta data.	
	
	


		

			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
	


*-------------------------------------------------------------------------------
* check out the data
*-------------------------------------------------------------------------------


	
** (4) Use describe, br, su, and other commands 
**     to get a sense of the structure of the data.** (5) Read the IPUMS comments on survey weights 
**     (http://cps.ipums.org/cps-action/variables/WTSUPP)**     and Stata help files on applying weights ("help weight").** (6a) What percent of survey respondents are married?** (6b) Use the svy commands to estimate the percent of 
**      the population that is married.     ** (7) Repeat (6b) for household heads only.	

	
** (8) Create a binary variable that takes a value of 1 if an 
**     individual lives in California and 0 otherwise.** (9) Estimate the percent of individuals who live in California.


		




			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
	


*-------------------------------------------------------------------------------
* distribution of income
*-------------------------------------------------------------------------------


** (10) Create an individual income variable equal to household income 
**      divided by the square root of the number **      of individuals in the household.  Call this variable "iincome".** (11) Use the "hist" and "kdensity" commands to draw a histogram**      and a density of your income variable for the entire sample.** (12) Generate and save a histogram of the income distribution for each state.**      You'll need to write a loop---I'll help with this step.			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
	
				    	    **  End of do file **
