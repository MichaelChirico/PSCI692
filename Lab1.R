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
##install.packages("data.table")

## Loading the library
library(data.table)

# Reading Data, Basic Manipulation ####

## fread stands for **f**ast read. It is
##   typically several orders of magnitude faster
##   than the native read.csv available in R; 
##   you won't typically notice unless the file has
##   in excess of 100,000 observations.
## Recommended reading: Getting started guides for data.table
##   https://github.com/Rdatatable/data.table/wiki/Getting-started
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

## Reshaping -- goal is to aggregate all of the
##   flights column into one for each individual
### First, reshape long -- each individual now has one row for
###   each of the flight* columns
toy_data_long <- melt(toy_data, measure.vars = patterns("^plane"),
                      variable.name = "year", value.name = "plane")

### Remove the year column in order to aggregate concisely, see
###   discussion here: https://github.com/Rdatatable/data.table/issues/1833
toy_data_long[ , year := NULL]

## Now reshape wide again, specifying to aggregate plane1 by summing
toy_data <- dcast(toy_data_long, ... ~ ., value.var = "plane", fun.aggregate = sum)
setnames(toy_data, ".", "plane")

###**Advanced**
###  As an alternative, we could have skipped the reshaping and just
###    done the following on the original table:
###    toy_data[ , plane := Reduce("+", .SD),
###             .SDcols = grep("^plane", names(toy_data), value = TRUE)]
###  Then removed the old columns with
###    toy_data[ , grep("^plane.+", names(toy_data), value = TRUE) := NULL]

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
toy_data[ , {
  x <- summary(height_num)
  .(names(x), x)}, by = male
  ][ , dcast(.SD, V1 ~ male, value.var = "V2")]
toy_data[ , {
  x <- summary(hairlength_num)
  .(names(x), x)}, by = male
  ][ , dcast(.SD, V1 ~ male, value.var = "V2")]

# Merging ####
##install.packages("haven")
library(haven)
name_dt <- setDT(read_dta("Names.dta"))

toy_data <- name_dt[toy_data, on = c(name = "Name")]

## We missed about half of the matches!
##   String data is the worst. But it's ubiquitous.
##   Luckily, there's fuzzy matching!
##   Basically, to clean up, we will use the
##   Levenshtein Edit Distance
##   (https://en.wikipedia.org/wiki/Levenshtein_distance)
##   to try and match any stragglers. This is much
##   slower in general than is straight up matching,
##   since we need to compute n(n+1)/2 distances.

matched <- toy_data[!is.na(firstname), unique(name)]

lev_mat <- 
  adist(toy_data[ , setdiff(name, matched)],
        name_dt[ , setdiff(name, matched)],
        ignore.case = TRUE)
rownames(lev_mat) <- toy_data[ , setdiff(name, matched)]
colnames(lev_mat) <- name_dt[ , setdiff(name, matched)]
cbind(colnames(lev_mat)[apply(lev_mat, 1L, which.min)],
      apply(lev_mat, 1L, min))

### Observing, we see most strings have matched quite well,
###   but there are a few that are clearly non-matches.
###   We can take care of that in this case by setting
###   a matching threshold -- 9 will work fine here.
lev_mat[lev_mat > 9] <- NA
fuz_match <- apply(lev_mat, 1L, which.min)
fuz_match <- fuz_match[lengths(fuz_match) > 0]

toy_data[ , fuz_name := name]
toy_data[data.table(name = names(fuz_match),
                    fuz_name = sapply(fuz_match, names)),
         fuz_name := i.fuz_name, on = "name"]

toy_data <- name_dt[toy_data, on = c(name = "fuz_name")]

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
