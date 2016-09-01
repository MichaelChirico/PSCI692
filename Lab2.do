	

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
**     including all variables in your extract request.
**     and begin a new Do file by using this .dta data.
	
	


		

			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
	


*-------------------------------------------------------------------------------
* check out the data
*-------------------------------------------------------------------------------


	
** (4) Use describe, br, su, and other commands 
**     to get a sense of the structure of the data.
**     (http://cps.ipums.org/cps-action/variables/WTSUPP)
**      the population that is married.     

	
** (8) Create a binary variable that takes a value of 1 if an 
**     individual lives in California and 0 otherwise.


		




			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
	


*-------------------------------------------------------------------------------
* distribution of income
*-------------------------------------------------------------------------------



**      divided by the square root of the number 
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
	
				    	    **  End of do file **