# Michael Chirico
# September 10, 2016
# PSCI 692
# Stats Lab 2

library(data.table)
#iotools is the fastest option for
#  reading in fixed-width files; see
#  http://stackoverflow.com/questions/24715894/
#  However, it's nice to have a progress bar on
#  the input reading, so we'll use the 
#  fread + stringr option for doing so
library(stringi)

rm(list = ls(all = TRUE))
setwd("~/Dropbox/Teaching/PSCI692")

data.path <- "~/Dropbox/2/data/cps_00002.dat"

#The raw data is in fixed-width format, which is
#  a nightmare to deal with. We need a "dictionary"
#  file which says where each column begins and ends,
#  or else what the width of each file is. See the
#  StackOverflow question -- different options use one
#  or the other of these approaches. Here we'll use
#  the beginning + end version.

do.file <- readLines("~/Dropbox/2/code/CPS_March2010.do")
#I opened this file and scanned through to find the 
#  line number where the column definitions terminate.
#  We could have done this more robustly by reading
#  in the whole file and telling it to stop either:
#    a) when it finds the number 3463, which we know
#       is the width of the data file, either by
#       manual inspection or with a command line tool
#       to determine the width
#    b) when it finds using `"cps_0002.dat"` -- this 
#       also requires having opened the file and
#       inspected to know where the column-width
#       dictionary ends, but is robust to the exact
#       line number changing -- perhaps if some 
#       comments or new commands are added earlier
#       in the code, etc.
dict <- do.file[1L:571L]

## trimming irrelevant lines (demonstrating
##   partially how we could have robustly identified
##   the lines relevant to the dictionary)
dict <- dict[-grep("quietly infix", dict):-1L]

dict <- 
  #transpose so that each list element is a column;
  #  before, each list element was a row.
  transpose(lapply(strsplit(dict, split = "\\s+|-"), 
                   #first and last entries are garbage
                   function(x) x[-c(1L, 6L)]))
names(dict) <- c("type", "colname", "beg", "end")

cps_data <- 
  fread(data.path, header = FALSE, sep = "\n"
        )[ , lapply(1:length(dict$beg),
                    function(ii)
                      stri_sub(V1, dict$beg[ii], dict$end[ii]))]

setnames(cps_data, dict$colname)

## type conversion -- this .do file
##   lists column types in language Stata
##   understands; here we first convert
##   those keywords to R-friendly versions
type_map <- c(int = "integer",
              long = "numeric",
              byte = "integer",
              float = "numeric",
              double = "numeric")

dict$type <- unname(type_map[dict$type])

## batch conversions
int <- dict$colname[dict$type == "integer"]
cps_data[ , (int) := lapply(.SD, as.integer), .SDcols = int]

num <- dict$colname[dict$type == "numeric"]
cps_data[ , (num) := lapply(.SD, as.numeric), .SDcols = num]

## a bunch of variables must be replaced by a
##   normalized version of themselves (dividing by 10^k)
rep.lines <- do.file[grep("^replace", do.file)]

## convert these lines to a list where the first element
##   is the column name, and the second is the number
##   by which we have to normalize for that column.
rep.list <- setNames(transpose(lapply(strsplit(gsub(
  "\\s", "", rep.lines), split = "[=/]"), `[`, -1L)),
  c("col", "divisor"))

cps_data[ , rep.list$col := 
            lapply(1L:length(rep.list$col), function(ii)
              get(rep.list$col[ii]) / 
                #divisor is currently stored as character
                as.numeric(rep.list$divisor[ii]))]

## converting labeled variables to factor with
##   appropriate corresponding labels
fktr_def <- transpose(strsplit(sub(
  #a bit tricky here -- some of the label
  #  definitions themselves include spaces,
  #  so we can't just split on spaces.
  #  instead we use sub (which only finds the first
  #  match) to convert the first two spaces to
  #  newline characters (any character not found in
  #  a value label would have sufficed) and
  #  then we can split on that successfully.
  " ", "\n", sub(" ", "\n", gsub(
  "label define ", "", 
  #trim the ", add" part that goes with every
  #  line defining a label besides the first
  gsub("(.*), add", "\\1", 
       #grabbing all the lines defining labels
       do.file[grep("^label define", do.file)])))),
  split = "\n"))
fktr_def[[3L]] <- 
  #Since there are apostrophes in some value labels,
  #  we can't just dive right in and destroy all
  #  apostrophes (the goal here is to have the third
  #  element be a normal R string containing what
  #  was between ` and ' in the .do file); first,
  #  we destroy all the backticks and quotation marks
  #  (having first inspected to be sure that there are
  #  no strays of these within the labels themselves),
  #  then we destroy any element-final apostrophes.
  gsub("(.*)'$", "\\1", gsub("[`\"]", "", fktr_def[[3L]]))
### converting this list to a data.table for what comes
###   next which, if I do say so myself, is an excellent
###   example of just how awesome data.table is.
setDT(fktr_def)
setnames(fktr_def, c("var", "val", "lab"))

### the variables we're converting don't have the _lbl tag
fktr_def[ , var := gsub("_lbl$", "", var)]

### Now the master stroke: by = var runs the operation
###   between the braces for every value of var -- each
###   of which corresponds to a single variable in
###   the cps_data data.table. For each of these variables,
###   we access the cps_data set and convert that variable
###   to a factor with levels (underlying values)
###   specified by the integer given in val (comes after
###   var_lbl in the .do file), and taking labels given
###   by the stuff between ` and ' in the .do file, lab.
###   The last minor point is that the OUTER `[.data.table` 
###   gets confused since we're not actually returning
###   something consistent for each by operation -- so we
###   tell each operation to return NULL after adding the
###   factor labels so we have control over what's
###   being returned. NULL is the most memory-efficient
###   thing to return, but we could have returned anything.
fktr_def[ , 
          {cps_data[ , .BY$var := 
                       factor(get(.BY$var), levels = val,  labels = lab)]
            NULL},
          by = var]

### fwrite is a brand new function only available in the
###   development version of data.table. The base alternative
###   will run much slower and is called write.csv.
###   Installation instructions for the development version
###   can be found here:
###   https://github.com/Rdatatable/data.table/wiki/Installation
fwrite(cps_data, "March2010.csv", quote = TRUE)
