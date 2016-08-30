# Michael Chirico
# August 30, 2016
# PSCI 692
# Stats Lab 1

# Preliminaries ####

## Clear workspace
rm(list = ls(all = TRUE))

## Set working directory
##   (where R looks for files by default hereafter)
setwd("~/Dropbox/Teaching/PSCI692")

# Hello World/Basics ####
print("Hello World")

## alternatively
cat("Hello World")

## Simple calculations
4 + 5

## Help files
?print

## Package installation
##   By default, this looks to CRAN,
##   (https://cran.r-project.org/)
##   (Comprehensive R Archive Network)
##   which is a managed plethora of packages,
##   all of which have to meet some minimum
##   standards of quality/documentation
install.packages("data.table")

## Loading the library
library(data.table)

# Reading Data, Basic Manipulation ####

## fread stands for **f**ast read. It is
##   typically several orders of magnitude faster
##   than the native read.csv available in R; 
##   you won't typically notice unless the file has
##   in excess of 100,000 observations.
toy_data <- fread("ToyDataset_Jun30.csv")

## Summarize the data to get a quick glance
summary(toy_data)

## Renaming variables
##   *note -- this is the way to do this with the
##            data.table package. subtle differences.
setnames(toy_data, "Location of senior year in high school", "hsloc")

## Can do several at once
setnames(toy_data,
         c("Year at Stanford", "Hair length (in inches)"),
         c("styear", "hairlength"))

## Rename according to a pattern
flight_vars <- grep("^flights", names(toy_data), value = TRUE)
setnames(toy_data,
         flight_vars, gsub("^flights", "plane", flight_vars))

toy_data_long <- melt(toy_data, measure.vars = patterns("^plane"),
                      variable.name = "year", value.name = "plane")

## Aggregation
toy_data_long[ , sum(plane), by = year]

## Reorder data
setorder(toy_data_long, Timestamp, Name, Birthday, Birthplace)

## Manipulating variables to be easier to use
##   *note: := is data.table-specific. See
##          http://stackoverflow.com/questions/7029944/ and
##          https://rawgit.com/wiki/Rdatatable/data.table/vignettes/datatable-reference-semantics.html

### Height as a string is pretty useless. Better as a decimal.
###   First, split roughly into feet and inches
###   (learned by inspection how the data is structured)
toy_data[ , height_1 := gsub("^([0-9]+).*", "\\1", Height)]
toy_data[ , height_2 := gsub("^[0-9]+[^0-9]+([0-9]+).*", "\\1", Height)]
toy_data[ , height_num := as.numeric(height_1) + as.numeric(height_2)/12]
### missed those expressed in inches alone or centimeters
toy_data[grepl("cm", Height), 
         height_num := as.numeric(gsub("[^0-9]", "", Height)) / 2.54 / 12]
toy_data[grepl("inches", Height) & !grepl("feet", Height),
         height_num := as.numeric(gsub("[^0-9]", "", Height)) / 12]

### remove temporary variables
toy_data[ , paste0("height_", 1:2) := NULL]

### Ditto hair length (luckily cleaner, but inspect!!)
toy_data[ , hairlength_num := as.integer(gsub("[^0-9]", "", hairlength))]

#### By inspection, some dates appear to have slipped into the hairlenght column.
toy_data[hairlength_num > 36, hairlength_num := NA]

### Gender dummy
toy_data[ , male := Gender == "Male"]

### Converting Birthday to Date (see ?as.Date and ?strptime)
#### First, fix outlier
toy_data[grepl("2991", Birthday),
         Birthday := gsub("2991", "1991", Birthday)]
toy_data[ , bday := as.Date(Birthday, format = "%m/%d/%Y")]
toy_data[is.na(bday), bday := 
           as.Date(gsub("([0-9])+(st|nd|rd|th)", "\\1", Birthday),
                   format = "%B %e %Y")]

# Descriptive Stats ####

toy_data[ , table(gender)]
toy_data[ , summary(height_num), by = male]
toy_data[ , summary(hairlength_num), by = male]

# Merging ####
install.packages("haven")
library(haven)
names <- setDT(read_dta("Names.dta"))

toy_data <- names[toy_data, on = c(name = "Name")]

# Graphing ####
## Basic Lines
x <- seq(0, 10, length.out = 1000)
plot(x, x^2, type = "l")

plot(x, x^2, type = "l", xlim = c(0, 5))

plot(x, x^2, type = "l", xlim = c(0, 2))
lines(x, x^(1/2))

plot(x, log(x), xlim = c(0, 5))

## Scatterplots
toy_data[ , plot(hairlength_num, height_num)]

### (this should be easier, but there's currently a bug
###  in RStudio: https://support.rstudio.com/hc/en-us/community/posts/208778048-RStudioGD-has-some-bug-when-used-within-j-of-data-table-also-dplyr- )
toy_data[ , plot(NULL, xlim = range(hairlength_num, na.rm = TRUE),
                 ylim = range(height_num, na.rm = TRUE))]
toy_data[(!male), points(hairlength_num, height_num, col = 1)]
toy_data[(male), points(hairlength_num, height_num, col = 2)]

### Fancier version
toy_data[ , plot(NULL, xlim = range(hairlength_num, na.rm = TRUE),
                 ylim = range(height_num, na.rm = TRUE),
                 main = "Height, hair length, and gender",
                 xlab = "Hair Length (inches)",
                 ylab = "Height (inches)")]
toy_data[(!male), points(hairlength_num, height_num, col = 1)]
toy_data[(male), points(hairlength_num, height_num, col = 2)]
legend("bottomleft", legend = c("Male", "Female"), col = c(2, 1), pch = 1)