#Parse a user-provided CSV data file.
#The following variables (<- example value) must be set in the environment before sourcing this script:
#userdataSource = ("../examples/example1.csv")
#cond1colsIn (<- "P1.mzXML,P2.mzXML,P3.mzXML,P4.mzXML,P5.mzXML,P6.mzXML,P7.mzXML,P8.mzXML,P9.mzXML,P10.mzXML")
#cond2colsIn (<- "B1.mzXML,B2.mzXML,B3.mzXML,B4.mzXML,B5.mzXML,B6.mzXML,B7.mzXML,B8.mzXML,B9.mzXML,B10.mzXML")
#playerName (<- argymeg)
#alias( <- testdata)

library(jsonlite)

outputSink = paste0("../../cache/userData_", playerName, "-", alias, ".json")

userdata <- read.csv(userdataSource, stringsAsFactors = FALSE)
userdata[is.na(userdata)] <- 2000

cond1cols <- as.vector(read.csv(text = gsub(" ", "", cond1colsIn, fixed = TRUE), header = FALSE, stringsAsFactors = FALSE), mode = "character")
cond2cols <- as.vector(read.csv(text = gsub(" ", "", cond2colsIn, fixed = TRUE), header = FALSE, stringsAsFactors = FALSE), mode = "character")
datacols <- c(cond2cols, cond1cols)

#Perform one-tailed t-test for each case
#GREATER MEANS GREATER IN THE FIRST SET OF VALUES!
# => LESS MEANS SMALLER IN THE FIRST SET OF VALUES!
greaters <- apply(userdata[,datacols], 1, function(x) {t.test(x[cond2cols], x[cond1cols], alternative = "greater")$p.value})
lessers <- apply(userdata[,datacols], 1, function(x) {t.test(x[cond2cols], x[cond1cols], alternative = "less")$p.value})

#Apply FDR correction
greaters <- p.adjust(greaters, method = "BH")
lessers <- p.adjust(lessers, method = "BH")

#Discard all peaks with p-values greater than 0.05
greaters <- greaters < 0.05
lessers <- lessers < 0.05

#Compile lists of up- and down-regulated and ambiguous inchikeys
inksup <- userdata[greaters,]$InChI.Key
inksdown <- userdata[lessers,]$InChI.Key
inksup <- unique(unlist(strsplit(inksup, ",")))
inksdown <- unique(unlist(strsplit(inksdown, ",")))
inksambig <- intersect(inksup, inksdown)

#Do one-tailed t-tests for average of all potentially matching peaks for ambiguous inchikeys and append to list accordingly
for(thisink in inksambig){
  candidates <- userdata[grep(thisink, userdata$InChI.Key, fixed = TRUE),]
  candidates <- candidates[,datacols]
  if (t.test(candidates[cond2cols], candidates[cond1cols], alternative = "greater")$p.value < 0.05){
    inksup <- c(inksup, thisink)
  } else if (t.test(candidates[cond2cols], candidates[cond1cols], alternative = "less")$p.value < 0.05) {
    inksdown <- c(inksdown, thisink)
  }
}

inksup <- as.data.frame(inksup, stringsAsFactors = FALSE)
inksup[,2] <- TRUE
colnames(inksup) <- c("ink", "pos")

inksdown <- as.data.frame(inksdown, stringsAsFactors = FALSE)
inksdown[,2] <- FALSE
colnames(inksdown) <- c("ink", "pos")

inksall <- rbind(inksup, inksdown)

#Write the final result file to cache
write_json(inksall, outputSink, pretty = TRUE)
