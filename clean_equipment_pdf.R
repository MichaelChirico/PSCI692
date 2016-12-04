library(pdftools)
library(data.table)
library(stringi)
library(zoo)

pdfx = pdf_text("voting_equipment_by_municipality_2_pdf_15114.pdf")

#trim header
pdfx = gsub(".*Equipment by\n", "", pdfx)

#trim footer
pdfx = gsub("\nWednesday.*", "", pdfx)

data = rbindlist(lapply(1:length(pdfx), function(ii) {
  if (!grepl("\n", pdfx[ii])) return(data.table(NULL))
  print(ii)
  #luckily the table appears in fixed width when converted
  #  to text; using the fread approach detailed here:
  #  http://stackoverflow.com/questions/34190156
  
  #get column widths given starts of first line
  #  (this unfortunately varies page-to-page)
  header = strsplit(gsub("\n.*", "", pdfx[ii]), split = "")[[1L]]
  
  tbl = fread(pdfx[ii], sep = "\n", header = FALSE, strip.white = FALSE)
  
  #rle identifies the strings of spaces which identify column changes
  beg = c(1L, with(rle(header), cumsum(lengths)[which(values == " ") + 1L]))
  #final column name (ACCESSIBLE EQUIPMENT) has a space, so delete
  beg = beg[-length(beg)]
  cols = list(beg = beg, end = c(beg[-1L] - 1L, max(nchar(tbl$V1))))
  
  out = tbl[-1L, lapply(1:length(cols$beg),
                        function(jj)
                          stri_sub(V1, cols$beg[jj], cols$end[jj]))]
  setnames(out, c("county", "munic_type", "municipality", 
                  "system", "vendor", "equipment", "equipment_acc"))
  out}))
  
#whitespace strip
data[ , (names(data)) := lapply(.SD, function(x) gsub("^\\s*|\\s*$", "", x))]

#ex-post:
#  * MANITOWISH WATERS was split to two lines (WATERS deleted here)
#  * ARPIN (combined w/ Village) losing part of parenthetical
#  * AUBURNDALE (combined w/ Village) idem
#  * HEWITT (combined w/ marshfield) idem
#Besides this, most of these rows were caused by 
#  Eagle (no modem and w/ modem) being split to two lines
data = data[!(system == "" & county == "")]

#clean-up
#  mostly comes from bad parsing of COUNTY vs. TYPE
data[munic_type == "E", c("county", "munic_type") :=
       .(gsub("\\s?VILLAG", "", county), "VILLAGE")]
data[grepl("CITY", county) & munic_type == "",
     c("county", "munic_type") := 
       .(gsub("\\s?CITY", "", county), "CITY")]
data[grepl("VILLAGE", county) & munic_type == "",
     c("county", "munic_type") := 
       .(gsub("\\s?VILLAGE", "", county), "VILLAGE")]

#more ad-hoc/idiosyncratic due to bad spacing in PDF
data[municipality == "CITY",
     c("munic_type", "municipality", "system", "vendor",
       "equipment", "equipment_acc") :=
       .(municipality, system, vendor, equipment, 
         #if it matters, can split these out later
         equipment_acc, equipment_acc)]
data[municipality == "VILLAGE",
     c("munic_type", "municipality", "system", "vendor",
       "equipment", "equipment_acc") :=
       .(municipality, system, vendor, equipment, 
         equipment_acc, equipment_acc)]

#the rest are places where county was wrapped
#  to a second line, or where SYSTEM
#  is Direct Recording Electronic
data = data[munic_type != ""]
data[system == "Direct Recording",
     system := "Direct Recording Electronic"]
data[county == "", county := NA_character_]

#county only recorded once per page;
#  cascade forward to fill this out
data[ , county := na.locf(county)]

#see above
data[municipality == "MANITOWISH",
     municipality := "MANITOWISH WATERS"]

fwrite(data, "equipment_by_municipality_2012.csv")
